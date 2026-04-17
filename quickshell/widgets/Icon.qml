import Quickshell
import Quickshell.Io
import QtQuick
import "./../color"

Rectangle {
    anchors {
	verticalCenter: parent.verticalCenter
    }
    implicitWidth: cpillchild2.implicitWidth + Theme.impW
    implicitHeight: Theme.h3
    radius: Theme.rad
    color: Theme.trans
    Text {
	id: cpillchild2
	anchors.centerIn: parent
	horizontalAlignment: Text.AlignHCenter
	verticalAlignment: Text.AlignVCenter
	text: "󱄅"
	color: "#ffffff"
	font {
	    pixelSize: 30;
	    bold: true
	    family: Theme.fnt
	}
    }
}
