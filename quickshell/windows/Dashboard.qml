import Quickshell
import Quickshell.Wayland
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
        anchors.centerIn: parent
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
		Item { Text { anchors.centerIn: parent; text: "Media\nkommt hier hin!"; color: Theme.bg3; font.family: Theme.fnt; horizontalAlignment: Text.AlignHCenter } }
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
        }
    }
}
