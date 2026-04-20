pragma Singleton
import Quickshell
import QtQuick
import "./current.qml"

Singleton {
	// Colors Bg
	readonly property color trans: "transparent"
	readonly property color bg0: Current.colors.bg0
	readonly property color bg1: Current.colors.bg1
	readonly property color bg2: Current.colors.bg2
	readonly property color bg3: Current.colors.bg3

	// Colors Ac
	readonly property color ac1: Current.colors.ac1
	readonly property color ac2: Current.colors.ac2
	readonly property color ac3: Current.colors.ac3
	readonly property color red: "#ff0000"

	// Spacings, Radius, implicitWidth, etc
	readonly property real rad: 20
	readonly property real spc1: 16
	readonly property real spc2: 8
	readonly property real outmrg: 4
	readonly property real impW: 12
	readonly property real h1: 48
	readonly property real h2: 40
	readonly property real h3: 32
	readonly property real h4: 24
	readonly property real h5: 16
	readonly property real h6: 8

	// Text
	readonly property var fnt: "GeistMono Nerd Font Propo" 
	readonly property real t1: 14
	readonly property real t2: 12 
	readonly property real t3: 10 
	readonly property real t4: 8 

	// Sondervariablen
	readonly property real cavaw: 8
}
