import Quickshell
import QtQuick
import "./../color"

Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: cpillchild1.implicitWidth + (Theme.impW * 2)
    implicitHeight: Theme.h3
    radius: Theme.rad
    border {
	width: 1
	color: Theme.bg2
    }
    color: Theme.bg1
    SystemClock {
	id: clock
	precision: SystemClock.Seconds
    }
    Text {
	id: cpillchild1
	anchors.centerIn: parent
	horizontalAlignment: Text.AlignHCenter
	verticalAlignment: Text.AlignVCenter
	font {
	    pixelSize: Theme.t1;
	    bold: true
	    family: Theme.fnt
	}
	color: Theme.ac1
	text: Qt.formatDateTime(clock.date, "hh:mm:ss")
    }
}
