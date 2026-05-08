import Quickshell
import Quickshell.Wayland
import Quickshell.Io 
import QtQuick
import QtQuick.Layouts
import "./../color"

PanelWindow {
    id: dashWindow
    visible: GlobalDashboard.dashboardVisible
    color: Theme.trans
    width: 400
    height: dashBox.height
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: dashWindow.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    IpcHandler {
        target: "dashboard"
        function toggle() { GlobalDashboard.toggle(); }
    }
    MouseArea {
        anchors.fill: parent
        onClicked: GlobalDashboard.close()
    }
    Rectangle {
        id: dashBox
        width: parent.width
        height: 60 + listView.contentHeight + Theme.spc2
        
        color: Theme.bg0
        radius: Theme.rad
        border { width: 1; color: Theme.bg2 }
        anchors.centerIn: parent

        opacity: dashWindow.visible ? 1.0 : 0.0
        transform: Translate { y: dashWindow.visible ? 0 : 30 }
        Behavior on opacity { NumberAnimation { duration: 300 } }
        Behavior on transform { NumberAnimation { duration: 400; easing.type: Easing.OutExpo } }

        // ==========================================
        // VIM KEYBINDS
        // ==========================================
        focus: true
        onVisibleChanged: { if (visible) forceActiveFocus(); }

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape || event.key === Qt.Key_Q) {
                GlobalDashboard.close();
                event.accepted = true;
            } else if (event.key === Qt.Key_J) {
                listView.incrementCurrentIndex();
                event.accepted = true;
            } else if (event.key === Qt.Key_K) {
                listView.decrementCurrentIndex();
                event.accepted = true;
            } else if (event.key === Qt.Key_L || event.key === Qt.Key_Return || event.key === Qt.Key_Right) {
                // Ins Submenü gehen!
                console.log("Öffne Submenü: " + listView.model[listView.currentIndex].name);
                // Hier kommt später der Wechsel-Code hin!
                event.accepted = true;
            } else if (event.key === Qt.Key_H || event.key === Qt.Key_Left) {
                // Zurück ins Hauptmenü (falls wir im Submenü sind)
                GlobalDashboard.currentMenuLevel = 0;
                event.accepted = true;
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spc2
            spacing: Theme.spc2

            // Header
            Text {
                text: "Dashboard"
                font.family: Theme.fnt
                font.pixelSize: Theme.t1 + 4
                font.bold: true
                color: Theme.ac1
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: Theme.spc2
            }

            // Die Hauptmenü-Pillen
            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                interactive: false // Da wir eh mit Vim navigieren, Maus-Scrollen deaktivieren
                spacing: Theme.spc2

                model: [
                    { name: "System", icon: "", desc: "CPU, RAM & Speicher" },
                    { name: "Media", icon: "", desc: "Aktuelle Wiedergabe" },
                    { name: "Netzwerk", icon: "", desc: "WLAN & Bluetooth" },
                    { name: "Wetter", icon: "", desc: "Vorhersage & Radar" }
                ]

                delegate: Rectangle {
                    width: listView.width
                    height: 60
                    radius: Theme.rad
                    
                    // Markierungs-Logik
                    property bool isSelected: ListView.isCurrentItem
                    color: isSelected ? Theme.bg1 : Theme.trans
                    border { width: 1; color: isSelected ? Theme.ac1 : Theme.bg2 }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spc2
                        spacing: Theme.spc2

                        Text { 
                            text: modelData.icon
                            font.family: Theme.fnt
                            font.pixelSize: Theme.t1 + 4
                            color: isSelected ? Theme.ac1 : Theme.bg3 
                            Layout.preferredWidth: 30
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text { 
                                text: modelData.name
                                font.family: Theme.fnt
                                font.bold: true
                                font.pixelSize: Theme.t1
                                color: "#ffffff" 
                            }
                            Text { 
                                text: modelData.desc
                                font.family: Theme.fnt
                                font.pixelSize: Theme.t2
                                color: Theme.bg3 
                            }
                        }
                        
                        Text {
                            text: "" // Pfeil nach rechts
                            font.family: Theme.fnt
                            color: isSelected ? Theme.ac1 : Theme.trans
                        }
                    }
                }
            }
        }
    }
}
