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

Rectangle { // Notify Widget Root
	id: notifyWidgetroot
	anchors.verticalCenter: parent.verticalCenter
	implicitHeight: Theme.h3 
	implicitWidth: notifyWidgettext.implicitWidth + ( Theme.impW * 2 )
	border {
		width: 1
		color: Theme.bg2 
	}
	radius: Theme.rad 
	color: Theme.bg1 
	//
	Text { //Notify Bell
		id: notifyWidgettext
		anchors.centerIn: parent
		font {
			pixelSize: Theme.t1 
			bold: true 
			family: Theme.fnt 
		}	
		color: Theme.ac1 
		text: ""
	}
	//
	MouseArea { // NotifypopupButton
		id: notifyWidgetbutton
		anchors.fill: parent 
		onClicked: notifyPopupwind.visible = !notifyPopupwind.visible
	}
	NotificationServer { //NotificationServer
				id: notifyPopupserver
				onNotification: notification => {
					notification.tracked = true
					IslandState.trigger(notification.summary)
					console.log("BACKEND EMPFANGEN: " + notification.summary)
				}								
			}
	//
	PopupWindow {
		id: notifyPopupwind
		anchor {
			item: rightPillanchor
			edges: Edges.Right
			margins.top: Theme.h1
		}
		implicitWidth: notifyPopuproot.implicitWidth
		implicitHeight: notifyPopuproot.implicitHeight
		visible: false
		color: Theme.trans
		//
		Rectangle {
			id: notifyPopuproot
			anchors.fill: parent 
			implicitHeight: 500
			implicitWidth: 350
			border {
				width: 1
				color: Theme.bg2
			}
			radius: Theme.rad 
			color: Theme.bg0
		}
	}
}
