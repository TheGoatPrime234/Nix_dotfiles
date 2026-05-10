import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Io 
import QtQuick
import QtQuick.Layouts
import "./../color"

PanelWindow {
    id: dashWindow
    visible: GlobalDashboard.dashboardVisible
    color: "transparent"
    width: 650 
    height: dashBox.height
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.anchors.bottom: true
    WlrLayershell.margins.bottom: 16
    WlrLayershell.exclusionMode: ExclusionMode.Normal
    WlrLayershell.keyboardFocus: dashWindow.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    IpcHandler { target: "dashboard"; function toggle() { GlobalDashboard.toggle(); } }
    MouseArea { anchors.fill: parent; onClicked: GlobalDashboard.close() }
    Process {
        id: ipProcess
        command: ["bash", "-c", "ip route get 1.1.1.1 | grep -oP 'src \\K\\S+'"]
        running: dashWindow.visible
        property string currentIp: "Lade..."
        stdout: SplitParser { onRead: data => { ipProcess.currentIp = data.trim() } }
    }
    Process {
        id: userProcess
        command: ["bash", "-c", "echo $USER@$HOSTNAME"]
        running: true 
        property string userHost: "user@nixos"
        stdout: SplitParser { onRead: data => { userProcess.userHost = data.trim() } }
    }
    Process {
        id: sysDataProcess
        command: ["bash", "-c", "
            cpu=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf \"%02d%%\", usage}')
            ram=$(free -h | awk '/^Mem:/ {printf \"%s / %s (%.0f%%)\", $3, $2, $3/$2*100}')
            disk=$(df -h / | awk 'NR==2 {printf \"%s / %s (%s)\", $3, $2, $5}')
            echo \"$cpu|$ram|$disk\"
        "]
        running: dashWindow.visible 
        onExited: sysTimer.start() 
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split("|");
                if (parts.length >= 3) {
                    systemTab.cpuVal = parts[0].trim();
                    systemTab.ramVal = parts[1].trim();
                    systemTab.diskVal = parts[2].trim();
                }
            }
        }
    }
    Timer {
        id: sysTimer
        interval: 2000
        onTriggered: sysDataProcess.start()
    }
    Rectangle {
        id: dashBox
        width: parent.width
        height: 400
        color: Theme.bg0
        radius: Theme.rad
        border { width: 1; color: Theme.bg2 }
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        opacity: dashWindow.visible ? 1.0 : 0.0
        transform: Translate { y: dashWindow.visible ? 0 : 30 }
        Behavior on opacity { NumberAnimation { duration: 300 } }
        Behavior on transform { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }
        property int currentTab: 2 
        property var tabs: [
            { name: "System", icon: "" },
            { name: "Media", icon: "" },
            { name: "Start", icon: "󰣇" },
            { name: "Netzwerk", icon: "" },
            { name: "Wetter", icon: "" }
        ]
        onVisibleChanged: { 
            if (visible) { forceActiveFocus(); dashBox.currentTab = 2; }
        }
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                GlobalDashboard.close();
                event.accepted = true;
            } else if (event.key === Qt.Key_L || event.key === Qt.Key_Right) {
                dashBox.currentTab = (dashBox.currentTab + 1) % dashBox.tabs.length;
                event.accepted = true;
            } else if (event.key === Qt.Key_H || event.key === Qt.Key_Left) {
                dashBox.currentTab = (dashBox.currentTab - 1 + dashBox.tabs.length) % dashBox.tabs.length;
                event.accepted = true;
            }
        }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spc2
            spacing: Theme.spc2
	    StackLayout {
                Item {
                    id: systemTab
                    property string cpuVal: "00%"
                    property string ramVal: "Lade..."
                    property string diskVal: "Lade..."
                    property string gpuVal: "30%"
                    property var sysStats: [
                        { name: "CPU",  icon: "", val: systemTab.cpuVal,  color: Theme.ac1 },
                        { name: "RAM",  icon: "", val: systemTab.ramVal,  color: Theme.ac1 },
                        { name: "GPU",  icon: "󰢮", val: systemTab.gpuVal,  color: Theme.ac2 },
                        { name: "DISK", icon: "󰋊", val: systemTab.diskVal, color: Theme.ac2 }
                    ]
                    GridLayout {
                        anchors.fill: parent
                        columns: 2 
                        columnSpacing: Theme.spc2
                        rowSpacing: Theme.spc2
                        Repeater {
                            model: systemTab.sysStats
                            delegate: Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 60
                                color: Theme.bg1
                                radius: Theme.rad / 2
                                border { width: 1; color: Theme.bg2 }
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: Theme.spc2
                                    spacing: Theme.spc2
                                    Text { 
                                        text: modelData.icon
                                        font.family: Theme.fnt
                                        font.pixelSize: Theme.t1 + 4
                                        color: modelData.color 
                                    }
                                    Text { 
                                        text: modelData.name + ":"
                                        font.family: Theme.fnt; font.bold: true
                                        color: modelData.color; font.pixelSize: Theme.t1 
                                    }
                                    Text { 
                                        text: modelData.val
                                        font.family: Theme.fnt
                                        color: "#ffffff"
                                        Layout.fillWidth: true
                                        horizontalAlignment: Text.AlignRight
                                        elide: Text.ElideRight 
                                    }
                                }
                            }
                        }
                        Item { Layout.fillHeight: true; Layout.columnSpan: 2 } 
                    }
                }
		Layout.fillWidth: true
		Layout.fillHeight: true
		currentIndex: dashBox.currentTab
		Item {
                    id: mediaTab
                    
                    // ==========================================
                    // SMART PLAYER DETECTION
                    // ==========================================
                    property var player: {
                        // FIX 1: Wir MÜSSEN .values nutzen, da es ein ObjectModel ist!
                        var pList = Mpris.players.values; 
                        
                        if (!pList || pList.length === 0) return null;
                        
                        var fallback = pList[0]; // Merke dir den ersten Player, falls keiner spielt
                        
                        for (var i = 0; i < pList.length; i++) {
                            // FIX 2: Quickshell nutzt die smarte Eigenschaft "isPlaying"
                            if (pList[i].isPlaying) {
                                return pList[i];
                            }
                        }
                        return fallback;
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spc2
                        spacing: Theme.spc2

                        Text {
                            visible: !mediaTab.player
                            text: "Keine aktive Wiedergabe"
                            font.family: Theme.fnt
                            color: Theme.bg3
                            anchors.centerIn: parent
                        }

                        RowLayout {
                            visible: !!mediaTab.player
                            Layout.fillWidth: true
                            spacing: Theme.spc2 * 2

                            Rectangle {
                                Layout.preferredWidth: 160
                                Layout.preferredHeight: 160
                                radius: Theme.rad
                                color: Theme.bg1
                                clip: true
                                border { width: 1; color: Theme.bg2 }

                                Image {
                                    anchors.fill: parent
                                    // FIX 3: Direkter Zugriff auf trackArtUrl
                                    source: mediaTab.player && mediaTab.player.trackArtUrl ? mediaTab.player.trackArtUrl : ""
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    opacity: status === Image.Ready ? 1 : 0
                                    Behavior on opacity { NumberAnimation { duration: 300 } }
                                }
                                
                                Text {
                                    visible: parent.children[0].status !== Image.Ready
                                    anchors.centerIn: parent
                                    text: ""
                                    font.family: Theme.fnt
                                    font.pixelSize: 40
                                    color: Theme.bg2
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 10

                                ColumnLayout {
                                    spacing: 2
                                    Text {
                                        // FIX 4: Direkter Zugriff auf trackTitle, trackArtist & trackAlbum!
                                        text: mediaTab.player && mediaTab.player.trackTitle ? mediaTab.player.trackTitle : "Unbekannter Titel"
                                        font.family: Theme.fnt; font.pixelSize: Theme.t1 + 2; font.bold: true; color: "#ffffff"
                                        elide: Text.ElideRight; Layout.fillWidth: true
                                    }
                                    Text {
                                        text: mediaTab.player && mediaTab.player.trackArtist ? mediaTab.player.trackArtist : "Unbekannter Interpret"
                                        font.family: Theme.fnt; font.pixelSize: Theme.t1; color: Theme.ac1
                                        elide: Text.ElideRight; Layout.fillWidth: true
                                    }
                                    Text {
                                        text: mediaTab.player && mediaTab.player.trackAlbum ? mediaTab.player.trackAlbum : ""
                                        font.family: Theme.fnt; font.pixelSize: Theme.t2; color: Theme.bg3
                                        elide: Text.ElideRight; Layout.fillWidth: true
                                    }
                                }

                                Rectangle {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 4
                                    color: Theme.bg2
                                    radius: 2
                                    Rectangle {
                                        width: parent.width * 0.4
                                        height: parent.height
                                        color: Theme.ac1
                                        radius: 2
                                    }
                                }

                                RowLayout {
                                    spacing: 30
                                    Layout.alignment: Qt.AlignHCenter

                                    Text { 
                                        text: "󰒮"; font.family: Theme.fnt; font.pixelSize: 24; color: "#ffffff"
                                        MouseArea { anchors.fill: parent; onClicked: if(mediaTab.player) mediaTab.player.previous() }
                                    }
                                    Text { 
                                        text: mediaTab.player && mediaTab.player.isPlaying ? "󰏤" : "󰐊"
                                        font.family: Theme.fnt; font.pixelSize: 32; color: Theme.ac1
                                        // FIX 5: Die Quickshell Funktion heißt togglePlaying()
                                        MouseArea { anchors.fill: parent; onClicked: if(mediaTab.player) mediaTab.player.togglePlaying() }
                                    }
                                    Text { 
                                        text: "󰒭"; font.family: Theme.fnt; font.pixelSize: 24; color: "#ffffff"
                                        MouseArea { anchors.fill: parent; onClicked: if(mediaTab.player) mediaTab.player.next() }
                                    }
                                }
                            }
                        }
                    }
                }
		Item {
		    RowLayout {
			anchors.fill: parent; anchors.margins: Theme.spc2; spacing: Theme.spc2 * 2
			Item {
			    Layout.preferredWidth: parent.width / 2; Layout.fillHeight: true
			    Text { anchors.centerIn: parent; text: ""; font.family: Theme.fnt; font.pixelSize: 140; color: Theme.ac1 }
			}
			ColumnLayout {
			    Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: 20
			    ColumnLayout {
				spacing: Theme.spc
				Text { text: "Willkommen zurück,"; font.family: Theme.fnt; font.pixelSize: Theme.t2; color: Theme.bg3 }
				Text { text: userProcess.userHost; font.family: Theme.fnt; font.pixelSize: Theme.t1 + 6; font.bold: true; color: "#ffffff" }
			    }
			    Rectangle { Layout.preferredWidth: 40; Layout.preferredHeight: 2; color: Theme.ac2; radius: 1 }
			    ColumnLayout {
				spacing: Theme.spc
				Text { text: "Netzwerk IP"; font.family: Theme.fnt; font.pixelSize: Theme.t2; color: Theme.bg3 }
				RowLayout {
				    spacing: Theme.spc
				    Text { text: "󰩟"; font.family: Theme.fnt; font.pixelSize: Theme.t1 + 2; color: Theme.ac1 }
				    Text { text: ipProcess.currentIp; font.family: Theme.fnt; font.pixelSize: Theme.t1 + 2; font.bold: true; color: "#ffffff" }
				}
			    }
			}
		    }
		}
		Item { Text { anchors.centerIn: parent; text: "Netzwerk\nkommt hier hin!"; color: Theme.bg3; font.family: Theme.fnt; horizontalAlignment: Text.AlignHCenter } }
		Item { Text { anchors.centerIn: parent; text: "Wetter\nkommt hier hin!"; color: Theme.bg3; font.family: Theme.fnt; horizontalAlignment: Text.AlignHCenter } }
	    }
	    Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 46 
                Layout.maximumHeight: 46 
                Layout.alignment: Qt.AlignTop 
                radius: Theme.rad
                color: Theme.bg0
                border { width: 1; color: Theme.bg2 }
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Theme.outmrg
                    spacing: Theme.spc
                    Repeater {
                        model: dashBox.tabs
                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            radius: Theme.rad
                            property bool isSelected: dashBox.currentTab === index
                            color: Theme.bg1
                            border { 
                                width: 1
                                color: isSelected ? Theme.ac1 : Theme.bg2
                            }
                            RowLayout {
                                anchors.centerIn: parent
                                spacing: Theme.spc
				Text { 
				    text: modelData.icon; 
				    font {
					family: Theme.fnt
					pixelSize: Theme.t1
				    }
				    color: isSelected ? Theme.ac1 : Theme.bg3 
				}
                                Text { 
				    text: modelData.name; 
				    font {
					family: Theme.fnt
					pixelSize: Theme.t1
					bold: true
				    }
				    color: isSelected ? "#ffffff" : Theme.bg3 
				}
                            }
                            MouseArea { anchors.fill: parent; onClicked: dashBox.currentTab = index }
                        }
                    }
                }           
            }
        }
    }
}
