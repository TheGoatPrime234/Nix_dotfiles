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

// ShellRoot halt
ShellRoot { // ShellRoot halt
	//
	PanelWindow { // PanelWindow für das docking
		id: panWinroot
		anchors {
			left: true
			right: true 
			top: true 
		}
		implicitHeight: Theme.h1
		color: Theme.trans
		// Anordnung der Pills 
		Item { // Anordnung der Pills
			id: panWinrow
			anchors {
				fill: parent
				margins: Theme.outmrg
			}
			// Root der leftpill
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
				// Anordnung der Widgets in der leftpill
				Row { // Anordnung der Widgets in der leftpill
					id: leftPillrow
					anchors {
						centerIn: parent
						margins: Theme.outmrg
					}
					spacing: Theme.spc2
					// 
					Workspace {
					}
					Cava {

					}
				}
			}
			//
			Item {
				Layout.fillWidth: true
			}
			//
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
				//
				Row {
					id: centerPillrow
					anchors {
						centerIn: parent
						margins: Theme.outmrg
					}
					spacing: Theme.spc2
					//
					Uhr1 {

					}
					//
					Rectangle { // Icon Widget Root
						id: iuseNixosbtw
						anchors {
							verticalCenter: parent.verticalCenter
						}
						implicitHeight: Theme.h3 
						implicitWidth: iuseNixosbtwtext.implicitWidth + Theme.impW 
						radius: Theme.rad 
						color: Theme.trans 
						//
						Text { //Icon
							id: iuseNixosbtwtext
							anchors.centerIn: parent 
							text: "󱄅"
							color: "#ffffff"
							font {
								pixelSize: 35
								bold: true 
								family: Theme.fnt 
							}
						}
					}
					Uhr2 {

					}
				}
			}
			//
			Item {
				Layout.fillWidth: true
			}
			//
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
				//
				Item { //Rightpill Popupanchor 
					id: rightPillanchor
					anchors.fill: parent
				}
				//
				Row {
					id: rightPillrow
					anchors {
						centerIn: parent 
						margins: Theme.outmrg
					}
					spacing: Theme.spc2
					//
					Rectangle { //Audio Widget Root
						id: audioWidgetroot
						anchors.verticalCenter: parent.verticalCenter
						implicitHeight: Theme.h3
						implicitWidth: audioWidgettext.implicitWidth + Theme.impW
						border {
							width: 1
							color: Theme.bg2
						}
						radius: Theme.rad 
						color: Theme.bg1 
						//
						PwObjectTracker { //Pipewire Tracker 
							objects: [
								Pipewire.defaultAudioSink
							]
						}
						//
						Text { // Audio Volume display
							id: audioWidgettext
							anchors.centerIn: parent 
							font {
								pixelSize: Theme.t1
								bold: true
								family: Theme.fnt
							}
							color: Theme.ac1 
							text: Pipewire.defaultAudioSink != null && Pipewire.defaultAudioSink.audio != null 
									? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%" 
									: "0%"
						}
						//
						MouseArea { // Mute Button
							anchors.fill: parent 
							onClicked: {
								if (Pipewire.defaultAudioSink != null && Pipewire.defaultAudioSink.audio != null) {
									Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
								}
							}
						}
					}
					//
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
					//
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
					//
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
								// 
								NotificationServer { //NotificationServer
									id: notifyPopupserver
									onNotification: notification => {
										notification.tracked = true
									}								
								}
								//
								ListView { //Liste aller Notifications
									anchors {
										fill: parent 
										margins: Theme.outmrg
									}
									spacing: Theme.spc2
									clip: true
									model: notifyPopupserver.trackedNotifications.values 
									delegate: Rectangle {
										width: ListView.view.width 
										height: 80
										border {
											width: 1
											color: Theme.ac1
										}
										radius: Theme.rad
										color: Theme.bg1 
										//
										Column {
											anchors {
												fill: parent 
												margins: Theme.spc2
											}
											//
											Text {
												font {
													pixelSize: Theme.t1 
													bold: true 
													family: Theme.fnt
												}
												color: Theme.ac1 
												text: modelData.summary
											}
											//
											Text {
												font {
													pixelSize: Theme.t1 
													bold: false 
													family: Theme.fnt 
												}
												width: parent.width 
												color: "#999999"
												text: modelData.body 
												elide: Text.ElideRight
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}