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
import "./pills"
import "./windows"

ShellRoot { 
    Variants {
        model: Quickshell.screens
        PanelWindow { 
            id: panWinroot
	    required property var modelData
            screen: modelData
            anchors {
                left: true
                right: true 
                top: true 
            }
            implicitHeight: Theme.h1
            color: Theme.trans

            Item { 
                id: panWinrow
                anchors {
                    fill: parent
                    margins: Theme.outmrg
                }
                Rectangle { 
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
                    Row { 
                        id: leftPillrow
                        anchors {
                            centerIn: parent
                            margins: Theme.outmrg
                        }
                        spacing: Theme.spc2
                        Workspace {}
                        Cava {}
                    }
                }
                
                Item { Layout.fillWidth: true }
                
		Centerpill {
		    anchors.centerIn: parent
		}
                
                Item { Layout.fillWidth: true }
                
                Rectangle { 
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
                    Item { 
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
                        Audio {}
                        Wifi {}
                        Battery {}
                        Notify {}
                    }
                }
            }
        }
    }
    Applauncher { }
    NotificationCenter { }
}
