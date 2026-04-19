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

Rectangle { // Root des Workspace Widgets in der left pill
	id: workspaceWidgetroot
	Layout.alignment: Qt.AlignLeft
	implicitHeight: Theme.h3
	implicitWidth: workspaceWidgetrow.implicitWidth + Theme.impW
	border {
		width: 1
		color: Theme.bg2 
	}
	radius: Theme.rad 
	color: Theme.bg1 
	//
	Row { // Anordnung der Workspaces
		id: workspaceWidgetrow 
		anchors.centerIn: parent 
		spacing: Theme.spc2 / 2
		//
		Repeater { // Clonung der Workspaces
			model: 9
			//
			Rectangle { //Einzelner Workspace
				id: workspaceWidgetsingle
				property var ws: Hyprland.workspaces.values.find(w=> w.id == index +1)
				property bool isActive: Hyprland.focusedWorkspace?.id == (index +1)
				visible: ws ? true : false 
				implicitHeight: Theme.h4 
				implicitWidth: isActive ? workspaceWidgettext.implicitWidth + Theme.impW * 4 : workspaceWidgettext.implicitWidth + Theme.impW * 2
				border {
					width: 1
					color: Theme.bg2
				}
				radius: Theme.rad
				color: isActive ? Theme.ac3 : (ws ? Theme.ac1 : Theme.ac1)
				//
				Text { // Nummerrierung der Workspaces
					id: workspaceWidgettext
					anchors.centerIn: parent 
					font {
						pixelSize: Theme.t1
						bold: true 
						family: Theme.fnt
					}
					text: index + 1
				}
				//
				MouseArea { // Workspace Switch on Click
					anchors.fill: parent
					onClicked: {
						Hyprland.dispatch("workspace " + (index + 1))
					}
				}
			}
		}
	}
}
