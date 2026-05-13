import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Io 
import QtQuick
import QtQuick.Layouts
import "./../../color"

Item {
    id: mediaTab
    
    // === VIM FOCUS LAYER ===
    property bool isFocused: false
    property int selectedAction: 1 // 0 = Prev, 1 = Play/Pause, 2 = Next

    function handleKey(event) {
        if (event.key === Qt.Key_L || event.key === Qt.Key_Right) {
            selectedAction = Math.min(2, selectedAction + 1);
            event.accepted = true;
        } else if (event.key === Qt.Key_H || event.key === Qt.Key_Left) {
            selectedAction = Math.max(0, selectedAction - 1);
            event.accepted = true;
        } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Space || event.key === Qt.Key_Return) {
            if (!player) return;
            if (selectedAction === 0) player.previous();
            else if (selectedAction === 1) player.togglePlaying();
            else if (selectedAction === 2) player.next();
            event.accepted = true;
        }
    }

    // ==========================================
    // SMART PLAYER DETECTION
    // ==========================================
    property var player: {
        var pList = Mpris.players.values; 
        if (!pList || pList.length === 0) return null;
        var fallback = pList[0];
        for (var i = 0; i < pList.length; i++) {
            if (pList[i].isPlaying) { return pList[i]; }
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
            color: Theme.bg2
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
                color: Theme.bg0
                clip: true
                border { width: 1; color: Theme.bg1 }

                Image {
                    anchors.fill: parent
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
                    color: Theme.bg1
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                ColumnLayout {
                    spacing: 2
                    Text {
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
                        font.family: Theme.fnt; font.pixelSize: Theme.t2; color: Theme.bg2
                        elide: Text.ElideRight; Layout.fillWidth: true
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 4
                    color: Theme.bg1
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
                        text: "󰒮"; font.family: Theme.fnt; font.pixelSize: 24;
                        color: (mediaTab.isFocused && mediaTab.selectedAction === 0) ? Theme.ac1 : Theme.bg2
                        scale: (mediaTab.isFocused && mediaTab.selectedAction === 0) ? 1.2 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        MouseArea { anchors.fill: parent; onClicked: if(mediaTab.player) mediaTab.player.previous() }
                    }
                    Text { 
                        text: mediaTab.player && mediaTab.player.isPlaying ? "󰏤" : "󰐊"
                        font.family: Theme.fnt; font.pixelSize: 32; 
                        color: (mediaTab.isFocused && mediaTab.selectedAction === 1) ? Theme.ac1 : Theme.bg2
                        scale: (mediaTab.isFocused && mediaTab.selectedAction === 1) ? 1.2 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        MouseArea { anchors.fill: parent; onClicked: if(mediaTab.player) mediaTab.player.togglePlaying() }
                    }
                    Text { 
                        text: "󰒭"; font.family: Theme.fnt; font.pixelSize: 24; 
                        color: (mediaTab.isFocused && mediaTab.selectedAction === 2) ? Theme.ac1 : Theme.bg2
                        scale: (mediaTab.isFocused && mediaTab.selectedAction === 2) ? 1.2 : 1.0
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        MouseArea { anchors.fill: parent; onClicked: if(mediaTab.player) mediaTab.player.next() }
                    }
                }
            }
        }
    }
}
