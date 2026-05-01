import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "./../color"

PanelWindow {
    id: gearwheel
    visible: false
    implicitWidth: 700
    implicitHeight: 600
    WlrLayershell.layer: WlrLayer.Overlay
    aboveWindows: true 
    color: Theme.trans
    Item {
        id: wheelContainer
        width: gearwheel.implicitWidth 
        height: gearwheel.implicitHeight
        anchors.centerIn: parent
        property int segmentCount: 6
        property int currentIndex: 0

        MouseArea {
	    anchors.centerIn: parent
	    width: gearwheel.width
	    height: gearwheel.height
	    onWheel: {
		if (wheel.angleDelta.y > 0) {
		    wheelContainer.currentIndex = (wheelContainer.currentIndex - 1 + wheelContainer.segmentCount) % wheelContainer.segmentCount;
		} else if (wheel.angleDelta.y < 0) {
		    wheelContainer.currentIndex = (wheelContainer.currentIndex + 1) % wheelContainer.segmentCount;
		}
	    }
        }

        Repeater {
            model: wheelContainer.segmentCount

            Image {
                id: lambdaSegment
                source: "segment_asym.svg"
                sourceSize.width: width
                sourceSize.height: height
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                rotation: index * (360 / wheelContainer.segmentCount)

		property bool isSelected: index == wheelContainer.currentIndex
		opacity: isSelected ? 1.0 : 0.4
		scale: isSelected ? 1.15 : 1.0

		Behavior on opacity {
		    NumberAnimation { 
			duration: 100
		    }
		}
		Behavior on scale {
		    NumberAnimation {
			duration: 200;
			easing.type: Easing.OutQuad
		    }
		}

            }
        }
    }
}
