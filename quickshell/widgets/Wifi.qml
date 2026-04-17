import Quickshell
import Quickshell.Io
import QtQuick
import QtQml
import "./../color"

Rectangle {
    id: wifiwidget
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: rpillchild2.implicitWidth + Theme.impW
    implicitHeight: Theme.h3
    radius: Theme.rad
    property bool isConnected: false
    visible: isConnected
    border {
	width: 1
	color: Theme.bg2
    }
    color: Theme.bg1
    Timer {
	interval: 30000
	running: true
	repeat: true
	triggeredOnStart: true
	onTriggered: wifiCheck.running = true
    }
    Process {
	id: wifiCheck
	command: ["nmcli", "-t", "-f", "STATE", "general"]
	stdout: SplitParser {
	    onRead: data => {
		if (data.trim().includes("connected")) {
		    wifiwidget.isConnected = true
		} else {
		    wifiwidget.isConnected = false
		}
	    }
	}
    }
    Text {
        id: rpillchild2
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
        text: ""
    }
}
