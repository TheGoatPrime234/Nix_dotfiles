import Quickshell
import QtQuick
import QtQuick.Layouts
import "./../color"
import "./../widgets"

Rectangle {
    id: centerPillRoot
    property bool islandActive: IslandState.active
    property string islandText: IslandState.text
    property string islandAppName: IslandState.appName
    function getAppIcon(name) {
	var n = name.toLowerCatse();
	if (n.includes("spotify")) return "";
	if (n.includes("disdord") || n.includes("vesktop")) return "";
	if (n.includes("firefox") || n.includes("broswer")) return "";
	if (n.includes("rebuild") || n.includes("nix")) return "";
	return "";
    }

    implicitWidth: islandActive ? Math.max(300, islandTextItem.implicitWidth + 80) : cpill.implicitWidth + Theme.impW
    implicitHeight: islandActive ? (Theme.h2 + 2/(Theme.h1 - Theme.h2)) : Theme.h2
    radius: Theme.rad
    border {
        width: 1
        color: Theme.bg2
    }
    color: Theme.bg0
    Behavior on implicitWidth {
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutExpo 
        }
    }
    Behavior on implicitHeight {
	NumberAnimation {
	    duration: 500
	    easing.type: Easing.OutExpo
	}
    }
    Row {
        id: cpill
        anchors {
            centerIn: parent
            margins: Theme.outmrg
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.spc2
        opacity: centerPillRoot.islandActive ? 0.0 : 1.0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        Uhr1 {}
        Iusenixosbtw {} 
        Uhr2 {}
    }
    Item {
        id: islandContent
        anchors.fill: parent
	anchors.centerIn: parent
        clip: true 
        opacity: centerPillRoot.islandActive ? 1.0 : 0.0
	Behavior on opacity {
            SequentialAnimation {
                PauseAnimation {
                    duration: centerPillRoot.islandActive ? 150 : 0
                }
                NumberAnimation {
                    duration: 500
                }
            }
        }
        RowLayout {
	    anchors {
		fill: parent
	    }
            spacing: Theme.spc2
	    Text {
                text: centerPillRoot.getAppIcon(centerPillRoot.islandAppName)
                font.family: Theme.fnt
                font.pixelSize: Theme.t1 + 4 
                color: Theme.ac1
                Layout.alignment: Qt.AlignVCenter
	    }
            Text {
                id: islandTextItem
                text: centerPillRoot.islandText
                font.family: Theme.fnt
                font.pixelSize: Theme.t1
                font.bold: true
                color: "#ffffff" 
                Layout.fillWidth: true
		horizontalAlignment: Text.AlignHCenter
		verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
        }
    }
}
