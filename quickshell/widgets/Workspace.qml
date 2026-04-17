import Quickshell
import QtQuick
import Quickshell.Hyprland
import "./../color"

Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: lpillchild1.implicitWidth + Theme.impW
    implicitHeight: Theme.h3
    border {
        width: 1
        color: Theme.bg2
    }
    radius: Theme.rad
    color: Theme.bg1
    Row {
        id: lpillchild1
        anchors.centerIn: parent
        spacing: Theme.spc2 / 2
        Repeater {
            model: 9
            Rectangle {
                property var ws: Hyprland.workspaces.values.find(w=> w.id == index +1)
                property bool isActive: Hyprland.focusedWorkspace?.id == (index +1)
                visible: ws ? true : false
                implicitWidth: isActive ? lpillchildchild.implicitWidth + Theme.impW * 4 : lpillchildchild.implicitWidth + Theme.impW * 2
                implicitHeight: Theme.h4
                border {
                    width: 1
                    color: Theme.bg2
                }
                radius: Theme.rad
                color: isActive ? Theme.ac3 : (ws ? Theme.ac1 : Theme.ac1)
                Text {
                    id: lpillchildchild
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font {
                        pixelSize: Theme.t1;
                        bold: true
			family: Theme.fnt
                    }
                    text: index + 1
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + (index + 1))
                }
            }
        }
    }
}
