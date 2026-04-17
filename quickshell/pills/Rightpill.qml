import Quickshell
import QtQuick
import QtQuick.Layouts
import "./../color"
import "./../widgets"

Rectangle {
    property var topBar
    implicitWidth: rpill.implicitWidth + Theme.impW
    implicitHeight: Theme.h2
    signal notifyToggled()
    border {
	width: 1
	color: Theme.bg2
    }
    radius: Theme.rad
    color: Theme.bg0
    Row {
        id: rpill
	anchors.centerIn: parent
        spacing: Theme.spc2
        Audio {
        }
        Wifi {
        }
	Battery {
	}
	Notification {
	    topBar: topBar
	    onNotifyToggled: notifyToggled()
	}
    }
}
