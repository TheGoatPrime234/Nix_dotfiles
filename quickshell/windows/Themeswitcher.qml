import Quickshell
import QtQuick
import QtQuick.Layouts
import "./../color"

FloatingWindow {
    id: themeswitcher
    visible: false
    implicitWidth: 350
    implicitHeight: 450
    color: Theme.bg1

    ColumnLayout {
	anchors.fill: parent
	anchors.margins: 20
	spacing: 15
	Text {
	    text: "Theme Switcher"
	    color: "#cdd6f4"
	    font.pixelSize: 24
	    font.bold: true
	    Layout.alignment: Qt.AlignHCenter
	}
	ListView {
	    Layout.fillWidth: true
	    Layout.fillHeight: true
	    clip: true
	    spacing: 10
	    model: ListModel {
		ListElement { 
		    name: "Catppuccin"
		    scriptPath: "~/.config/rice/themes/catppuccin/apply_theme.sh"
		    bgColor: "#313244"
		    textColor: "#cdd6f4"
		}
		ListElement { 
		    name: "Dracula"
		    scriptPath: "~/.config/rice/themes/dracula/apply_theme.sh"
		    bgColor: "#f5e0dc"
		    textColor: "#11111b"
		}
		ListElement { 
		    name: "Everforest"
		    scriptPath: "~/.config/rice/themes/everforest/apply_theme.sh"
		    bgColor: "#f38ba8"
		    textColor: "#11111b"
		}
	    }
	    delegate: Rectangle {
		width: ListView.view.width
		height: 50
		color: bgColor
		radius: Theme.rad 
		
		Text {
		    anchors.centerIn: parent
		    text: name
		    font.pixelSize: 18
		    font.bold: true
		    color: textColor
		}
		MouseArea {
		    anchors.fill: parent
		    cursorShape: Qt.PointingHandCursor
		    onClicked: {
			Quickshell.execDetached(["bash", "-c", scriptPath])
			console.log("Theme gewechselt zu: " + name)
		    }
		}
	    }
	}
    }
}
