import Quickshell
import Quickshell.Io
import QtQuick
import Quickshell.Services.Mpris
import "./../color"

Rectangle {
    anchors {
	verticalCenter: parent.verticalCenter
    }
    implicitHeight: Theme.h3
    implicitWidth: ((Theme.cavaw + 2) * 16) + (Theme.impW * 2.5)
    border {
        width: 1
        color: Theme.bg2
    }
    radius: Theme.rad 
    color: Theme.bg1 
    Item {
	id: cava
	anchors.fill: parent
	property var bars: []

	Process {
	    id: cavaProc
	    command: ["cava", "-p", "/home/cato/.config/quickshell/widgets/commands/bar-config.conf"]
	    running: true
	    stdout: SplitParser {
		onRead: data => {
		    var vals = data.trim().split(";").filter(x => x !== "")
		    cava.bars = vals.map(x => parseInt(x) / 50.0)
		}
	    }
	}

	Row {
	    id: cavabars
	    anchors.centerIn: parent
	    spacing: 2

	    Repeater {
		model: cava.bars
		Rectangle {
		    width: Theme.cavaw
		    height: cava.height
		    color: Theme.trans

		    Rectangle {
			width: parent.width
			height: parent.height * modelData
			anchors.bottom: parent.bottom
			color: Theme.ac1
		    }
		}
	    }
	}
    }
    MouseArea {
	anchors.fill: parent
	onClicked: {
	    var activePlayers = Mpris.players.values
	    if (activePlayers.length > 0) {
		activePlayers[0].togglePlaying()
	    }
	}
    }
}
