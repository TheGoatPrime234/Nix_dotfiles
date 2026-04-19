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

Rectangle { // root des Cava Widgets
	id: cavaWidgetroot
	Layout.alignment: Qt.AlignRight
	implicitHeight: Theme.h3
	implicitWidth: ((Theme.cavaw + 2) * 16) + (Theme.impW * 2.5)
	border {
		width: 1
		color: Theme.bg2
	}
	radius: Theme.rad 
	color: Theme.bg1 
	//
	Item { // Item des Cava Widgets
		id: cavaWidgetItem
		anchors.fill: parent
		property var bars: []
		//
		Process { // Cava Balken-parse-Process
			id: cavaWidgetProcess
			command: ["cava", "-p", "/home/cato/.config/quickshell/widgets/commands/bar-config.conf"]
			running: true
			stdout: SplitParser {
				onRead: data => {
					var vals = data.trim().split(";").filter(x => x !== "")
					cavaWidgetItem.bars = vals.map(x => parseInt(x) / 50.0)
				}
			}
		}
		//
		Row { // Anordnung der Cavabars
			id: cavaWidgetbars
			anchors.centerIn: parent
			spacing: 2
			//
			Repeater { // Clonung der Cavabars
				model: cavaWidgetItem.bars
				//
				Rectangle { // Rohe Cavabars
					width: Theme.cavaw
					height: cavaWidgetItem.height
					color: Theme.trans
					//
					Rectangle { // Wahre Cavabars
					width: parent.width
					height: parent.height * modelData
					anchors.bottom: parent.bottom
					color: Theme.ac1
					}
				}
			}
		}
	}
	//
	MouseArea { // Cava Musicstopp
		anchors.fill: parent
		onClicked: {
			var activePlayers = Mpris.players.values
			if (activePlayers.length > 0) {
			activePlayers[0].togglePlaying()
			}
		}
	}
}
