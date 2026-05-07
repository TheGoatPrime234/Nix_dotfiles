import Quickshell
import Quickshell.Wayland
import Quickshell.Io 
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import "./../color"

PanelWindow {
    id: ncWindow
    visible: GlobalNotifs.centerVisible
    color: "transparent"
    implicitWidth: ncBox.width
    implicitHeight: ncBox.height + (ncWindow.visible ? 0 : 50)

    anchors { bottom: true; right: true }
    margins { bottom: Theme.spc1 * 2; left: Theme.spc1 * 2 }
    
    WlrLayershell.layer: WlrLayer.Top

    IpcHandler {
        target: "notifcenter"
        function toggle() { GlobalNotifs.toggleCenter(); }
    }

    Rectangle {
        id: ncBox
        width: 420
        color: Theme.bg0
        radius: Theme.rad
        border { width: 1; color: Theme.bg2 }

        property int notifCount: GlobalNotifs.trackedNotifications.values.length
        
        // Magische Höhenberechnung basierend auf dem echten Inhalt
        property real targetHeight: 240 + (notifCount > 0 ? 40 : 0) + listView.contentHeight + (notifCount > 0 ? Theme.spc2 : 0)
        height: Math.min(800, targetHeight)
        
        opacity: ncWindow.visible ? 1.0 : 0.0
        transform: Translate { y: ncWindow.visible ? 0 : 50 }
        
        Behavior on height { NumberAnimation { duration: 500; easing.type: Easing.OutExpo } }
        Behavior on opacity { NumberAnimation { duration: 300 } }
        Behavior on transform { NumberAnimation { duration: 500; easing.type: Easing.OutExpo } }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.spc2
            spacing: Theme.spc2

            // BEREICH 1: Platzhalter für deine Quicksettings
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 200
                color: Theme.bg1; radius: Theme.rad; border { width: 1; color: Theme.bg2 }
                Text {
                    anchors.centerIn: parent
                    text: "Schnelleinstellungen"; color: Theme.bg3; font.family: Theme.fnt
                }
            }

            // BEREICH 2: Header mit "Alle löschen"
            Item {
                Layout.fillWidth: true; Layout.preferredHeight: 30
                visible: ncBox.notifCount > 0 

                Text {
                    anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                    text: "Benachrichtigungen"; font.family: Theme.fnt; font.pixelSize: Theme.t1 + 2; font.bold: true; color: Theme.ac1
                }

                Rectangle {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                    width: 90; height: 24; radius: Theme.rad / 2
                    color: clearMA.containsMouse ? Theme.bg2 : Theme.trans; border { width: 1; color: Theme.bg2 }
                    Text { anchors.centerIn: parent; text: "Alle löschen"; font.family: Theme.fnt; font.pixelSize: Theme.t2; color: Theme.bg3 }
                    MouseArea {
                        id: clearMA; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            let notifs = GlobalNotifs.trackedNotifications.values;
                            for (let i = 0; i < notifs.length; i++) { notifs[i].tracked = false; }
                        }
                    }
                }
            }

            // BEREICH 3: Die gruppierte Liste
            ListView {
                id: listView
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true; spacing: Theme.spc2
                model: GlobalNotifs.trackedNotifications.values

                section.property: "appName"
                section.delegate: Item {
                    width: listView.width; height: 24
                    RowLayout {
                        anchors.fill: parent; spacing: Theme.spc2
                        Text { text: GlobalNotifs.getAppIcon(section); font.family: Theme.fnt; color: Theme.ac1 }
                        Text { text: section ? section : "System"; font.family: Theme.fnt; font.bold: true; color: Theme.bg3; Layout.fillWidth: true }
                    }
                }

                delegate: Rectangle {
                    width: listView.width; height: 88; radius: Theme.rad; color: Theme.bg1; border { width: 1; color: Theme.bg2 }
                    RowLayout {
                        anchors.fill: parent; anchors.margins: Theme.spc2; spacing: Theme.spc2
                        Rectangle {
                            Layout.preferredWidth: 40; Layout.preferredHeight: 40; radius: 20; color: Theme.bg2
                            Text { anchors.centerIn: parent; text: ""; font.family: Theme.fnt; color: Theme.ac1 }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true; spacing: 4
                            Text { text: modelData.summary; font.family: Theme.fnt; font.bold: true; color: "#ffffff"; Layout.fillWidth: true; elide: Text.ElideRight }
                            Text { text: modelData.body; font.family: Theme.fnt; font.pixelSize: Theme.t2; color: Theme.bg3; Layout.fillWidth: true; elide: Text.ElideRight; maximumLineCount: 2; wrapMode: Text.Wrap }
                        }
                        Rectangle {
                            Layout.preferredWidth: 30; Layout.fillHeight: true; color: Theme.trans
                            Text { anchors.centerIn: parent; text: ""; font.family: Theme.fnt; color: Theme.bg3; font.pixelSize: Theme.t1 }
                            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: modelData.tracked = false }
                        }
                    }
                }
            }
        }
    }
}
