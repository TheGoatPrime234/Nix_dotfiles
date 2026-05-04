import QtQuick
import QtQuick.Shapes 
import "./../color" 

Item {
    id: wingsRoot
    anchors.fill: parent 
    opacity: 0
    property real anilength: 500
    Behavior on opacity {
	NumberAnimation {
	    duration: anilength
	    easing.type: Easing.OutExpo
	}
    }
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: Theme.engelsflügel
        color: wingsRoot.parent.color 
    }
    Shape {
        anchors.right: parent.left 
        anchors.top: parent.top
        width: Theme.engelsflügel
        height: Theme.engelsflügel
        ShapePath {
            fillColor: wingsRoot.parent.color
            strokeColor: "transparent"
            PathSvg {
                path: "M " + Theme.engelsflügel + " 0 " + 
                      "L " + Theme.engelsflügel + " " + Theme.engelsflügel + " " + 
                      "A " + Theme.engelsflügel + " " + Theme.engelsflügel + " 0 0 0 0 0 Z"
            }
        }
    }
    Shape {
        anchors.left: parent.right
        anchors.top: parent.top
        width: Theme.engelsflügel
        height: Theme.engelsflügel
        ShapePath {
            fillColor: wingsRoot.parent.color
            strokeColor: "transparent"
            PathSvg {
                path: "M 0 0 " + 
                      "L 0 " + Theme.engelsflügel + " " + 
                      "A " + Theme.engelsflügel + " " + Theme.engelsflügel + " 0 0 1 " + Theme.engelsflügel + " 0 Z"
            }
        }
    }
}
