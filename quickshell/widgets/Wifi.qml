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

Rectangle { //Wifi Widget Root
	id: wifiWidgetroot
	property bool isConnectedtowifi: false
	visible: isConnectedtowifi
	anchors.verticalCenter: parent.verticalCenter
	implicitHeight: Theme.h3 
	implicitWidth: wifiWidgettext.implicitWidth + Theme.impW 
	border {
		width: 1
		color: Theme.bg2 
	}
	radius: Theme.rad 
	color: Theme.bg1
	//
	Timer {
		interval: 30000
		running: true 
		repeat: true
		triggeredOnStart: true 
		onTriggered: wifiWidgetprocess.running = true 
	}
	//
	Process {
		id: wifiWidgetprocess
		command: ["nmcli", "-t", "-f", "STATE", "general"]
		stdout: SplitParser {
			onRead: data => {
				if (data.trim().includes("connected")) {
					wifiWidgetroot.isConnectedtowifi = true 
				} else {
					wifiWidgetroot.isConnectedtowifi = false
				}
			}
		}
	}
	//
	Text { // Wifi Widget Output
		id: wifiWidgettext
		anchors.centerIn: parent 
		font {
			pixelSize: Theme.t1 
			bold: true
			family: Theme.fnt
		}
		color: Theme.ac1 
		text: ""
	}
}
