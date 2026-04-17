import Quickshell
import QtQuick
import "./../color"

Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: cpillchild3.implicitWidth + (Theme.impW * 2)
    implicitHeight: Theme.h3
    radius: Theme.rad
    color: Theme.bg1
    border {
	width: 1
	color: Theme.bg2
    }
    SystemClock {
	id: clock
	precision: SystemClock.Minutes
    }
    Text {
	id: cpillchild3
	anchors.centerIn: parent
	horizontalAlignment: Text.AlignHCenter
	verticalAlignment: Text.AlignVCenter
	font {
	    pixelSize: Theme.t1;
	    bold: true
	    family: Theme.fnt
	}
	color: Theme.ac1
	text: Qt.formatDateTime(clock.date, "dd ddd. MMM")
    }
}
