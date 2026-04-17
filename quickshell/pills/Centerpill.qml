import Quickshell
import QtQuick
import QtQuick.Layouts
import "./../color"
import "./../widgets"

Rectangle {
    implicitWidth: cpill.implicitWidth + Theme.impW
    implicitHeight: Theme.h2
    radius: Theme.rad
    border {
	width: 1
	color: Theme.bg2
    }
    color: Theme.bg0
    Row {
        id: cpill
	anchors {
	    centerIn: parent
	    margins: Theme.outmrg
	    verticalCenter: parent.verticalCenter
	}
        spacing: Theme.spc2
        Uhr1 {
        }
        Icon {
        }
        Uhr2 {
        }
    }
}
