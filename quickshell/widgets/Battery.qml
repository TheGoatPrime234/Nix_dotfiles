import Quickshell
import Quickshell.Services.UPower
import QtQuick
import "./../color"

Rectangle {
    id: batterywidget
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: rpillchild3.implicitWidth + Theme.impW
    implicitHeight: Theme.h3
    radius: Theme.rad
    border {
	width: 1
	color: Theme.bg2
    }
    color: Theme.bg1
    Text {
        id: rpillchild3
        anchors.centerIn: parent
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
	font {
	    pixelSize: Theme.t1;
	    bold: true
	    family: Theme.fnt
	}
	color: Theme.ac1
        text: UPower.displayDevice.ready ? Math.round((UPower.displayDevice.percentage) * 100) + "%" : "Holy Moly..."
    }
}
