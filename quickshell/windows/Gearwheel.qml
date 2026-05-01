import Quickshell
import QtQuick
import QtQuick.Layouts
import "./../color"

FloatingWindow {
    id: themeswitcher
    visible: false
    implicitWidth: 400
    implicitHeight: 400
    color: Theme.bg1
    Item {
        id: wheelContainer
        width: 400
        height: 400
        anchors.centerIn: parent
        property int segmentCount: 6

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
            }
        }
    }
}
