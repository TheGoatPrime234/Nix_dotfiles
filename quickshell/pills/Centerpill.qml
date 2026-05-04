import Quickshell
import QtQuick
import QtQuick.Layouts
import "./../color"
import "./../widgets"

Rectangle {
    id: centerPillRoot
    property bool islandActive: IslandState.active
    property string islandText: IslandState.text
    implicitWidth: islandActive ? Math.max(250, islandTextItem.implicitWidth + 80) : cpill.implicitWidth + Theme.impW
    implicitHeight: Theme.h2
    radius: Theme.rad
    border {
        width: 1
        color: Theme.bg2
    }
    color: Theme.bg0
    Behavior on implicitWidth {
        NumberAnimation {
            duration: 400
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
        clip: true 
        opacity: centerPillRoot.islandActive ? 1.0 : 0.0
	Behavior on opacity {
            SequentialAnimation {
                PauseAnimation {
                    duration: centerPillRoot.islandActive ? 150 : 0
                }
                NumberAnimation {
                    duration: 300
                }
            }
        }
        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.spc1
            spacing: Theme.spc2
            Text {
                text: "" 
                font.family: Theme.fnt
                font.pixelSize: Theme.t1 + 2
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
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                elide: Text.ElideRight
            }
        }
    }
}
