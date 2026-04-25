import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.Notifications
import "./../color"

Rectangle { // Battery Widget Root
	id: batteryWidgetroot
	anchors.verticalCenter: parent.verticalCenter
	implicitHeight: Theme.h3 
	implicitWidth: batteryWidgettext.implicitWidth + Theme.impW 
	border {
		width: 1
		color: Theme.bg2 
	}
	radius: Theme.rad 
	color: Theme.bg1 
	//
	Text { //Battery Icon
		id: batteryWidgettext
		anchors.centerIn: parent 
		font {
			pixelSize: Theme.t1 
			bold: true 
			family: Theme.fnt
		}
		color: Theme.ac1
		text: UPower.displayDevice.ready ? Math.round((UPower.displayDevice.percentage) * 100) + "%" : "Holy Moly..."
	}
}
