import Quickshell
import QtQuick
import QtQuick.Layouts
import "./../color"
import "./../widgets"

Rectangle {
    implicitWidth: lpill.implicitWidth + Theme.impW
    implicitHeight: Theme.h2
    border {
        width: 1
        color: Theme.bg2
    }
    radius: Theme.rad
    color: Theme.bg0
    Row {
        id: lpill
        anchors {
            fill: parent
            margins: Theme.outmrg
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.spc2
        Workspace {
        }
        Cava {
        }
    }
}
