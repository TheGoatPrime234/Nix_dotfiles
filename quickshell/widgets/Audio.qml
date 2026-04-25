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
