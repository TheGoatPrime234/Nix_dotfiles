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

Rectangle {
	id: uhr2Widgetroot
	implicitHeight: Theme.h3 
	implicitWidth: uhr2Widgettext.implicitWidth + (Theme.impW * 3)
	radius: Theme.rad
	border {
		width: 1
		color: Theme.bg2 
	}
	color: Theme.bg1 
	//
	SystemClock { // Timegetter Clock1
		id: clock2 
		precision: SystemClock.Minutes
	}
	//
	Text { // Time of Clock 1 
		id: uhr2Widgettext
		anchors.centerIn: parent 
		font {
			pixelSize: Theme.t1
			bold: true 
			family: Theme.fnt 
		}
		color: Theme.ac1 
		text: Qt.formatDateTime(clock2.date, "dd ddd. MMM")
	}
}
