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
import "./color"
import "./widgets"

// Generelle Ordnung
// 1. id
//2. Anchors
//3. Margins
//4. Spacing
//5. Width & Height
//6. Border
//7. Radius
//8. Colors

ShellRoot { // ShellRoot halt
	PanelWindow { // PanelWindow für das docking
		id: panWinroot
		anchors {
			left: true
			right: true 
			top: true 
		}
		implicitHeight: Theme.h1
		color: Theme.trans
		Item { // Anordnung der Pills
			id: panWinrow
			anchors {
				fill: parent
				margins: Theme.outmrg
			}
			Rectangle { // Root der leftpill
				id: leftPillroot
				anchors {
					left: parent.left 
					verticalCenter: parent.verticalCenter
				}
				implicitHeight: Theme.h2 
				implicitWidth: leftPillrow.implicitWidth + Theme.impW
				border {
					width: 1
					color: Theme.bg2
				}
				radius: Theme.rad 
				color: Theme.bg0
				Row { // Anordnung der Widgets in der leftpill
					id: leftPillrow
					anchors {
						centerIn: parent
						margins: Theme.outmrg
					}
					spacing: Theme.spc2
					Workspace {
					}
					Cava {
					}
				}
			}
			Item {
				Layout.fillWidth: true
			}
			Rectangle { // Root der centerpill
				id: centerPillroot
				anchors {
					horizontalCenter: parent.horizontalCenter
					verticalCenter: parent.verticalCenter
				}
				implicitHeight: Theme.h2 
				implicitWidth: centerPillrow.implicitWidth + Theme.impW
				border {
					width: 1
					color: Theme.bg2
				}
				radius: Theme.rad
				color: Theme.bg0
				Row {
					id: centerPillrow
					anchors {
						centerIn: parent
						margins: Theme.outmrg
					}
					spacing: Theme.spc2
					Uhr1 {
					}
					Iusenixosbtw {
					}
					Uhr2 {
					}
				}
			}
			Item {
				Layout.fillWidth: true
			}
			Rectangle { //Root der rightpill
				id: rightPillroot
				anchors {
					right: parent.right 
					verticalCenter: parent.verticalCenter
				}
				implicitHeight: Theme.h2 
				implicitWidth: rightPillrow.implicitWidth + Theme.impW
				border {
					width: 1
					color: Theme.bg2
				}
				radius: Theme.rad 
				color: Theme.bg0 
				Item { //Rightpill Popupanchor 
					id: rightPillanchor
					anchors.fill: parent
				}
				Row {
					id: rightPillrow
					anchors {
						centerIn: parent 
						margins: Theme.outmrg
					}
					spacing: Theme.spc2
					Audio {
					}
					Wifi {
					}
					Battery {
					}
					Notify {
					}
				}
			}
		}
	}
}