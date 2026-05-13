import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import Quickshell.Io 
import QtQuick
import QtQuick.Layouts
import "./../../color"

Item {
    // === VIM FOCUS LAYER ===
    property bool isFocused: false
    function handleKey(event) {
        // Hier können wir später Befehle für den StartTab einbauen
    }

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
    RowLayout {
        anchors.fill: parent;
        anchors.margins: Theme.spc2; spacing: Theme.spc2 * 2
        Item {
            Layout.preferredWidth: parent.width / 2;
            Layout.fillHeight: true
            Text { anchors.centerIn: parent; text: ""; font.family: Theme.fnt; font.pixelSize: 140;
            color: Theme.ac1 }
        }
        ColumnLayout {
            Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter;
            spacing: 20
            ColumnLayout {
                spacing: Theme.spc
                Text { text: "Willkommen zurück,"; font.family: Theme.fnt; font.pixelSize: Theme.t2;
                color: Theme.bg3 }
                Text { text: userProcess.userHost; font.family: Theme.fnt; font.pixelSize: Theme.t1 + 6; font.bold: true;
                color: "#ffffff" }
            }
            Rectangle { Layout.preferredWidth: 40; Layout.preferredHeight: 2; color: Theme.ac2;
            radius: 1 }
            ColumnLayout {
                spacing: Theme.spc
                Text { text: "Netzwerk IP"; font.family: Theme.fnt; font.pixelSize: Theme.t2;
                color: Theme.bg3 }
                RowLayout {
                    spacing: Theme.spc
                    Text { text: "󰩟"; font.family: Theme.fnt;
                    font.pixelSize: Theme.t1 + 2; color: Theme.ac1 }
                    Text { text: ipProcess.currentIp; font.family: Theme.fnt; font.pixelSize: Theme.t1 + 2;
                    font.bold: true; color: "#ffffff" }
                }
            }
        }
    }
}
