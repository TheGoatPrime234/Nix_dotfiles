import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import "./../color"

Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    implicitWidth: rpillchild1.implicitWidth + Theme.impW
    implicitHeight: Theme.h3
    radius: Theme.rad
    border {
	width: 1
	color: Theme.bg2
    }
    color: Theme.bg1
    PwObjectTracker {
	objects: [ Pipewire.defaultAudioSink ]
    }
    Text {
        id: rpillchild1
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
	text: Pipewire.defaultAudioSink != null && Pipewire.defaultAudioSink.audio != null 
		      ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%" 
		      : "0%"
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (Pipewire.defaultAudioSink != null && Pipewire.defaultAudioSink.audio != null) {
                Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted
            }
        }
    }
}
