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
    property real asymmetricOffset: (uhr2.implicitWidth - uhr1.implicitWidth) / 2
    function getAppIcon(name) {
        var n = name.toLowerCase();
        if (n.includes("spotify"))
            return "";
        if (n.includes("discord") || n.includes("vesktop"))
            return "";
        if (n.includes("firefox") || n.includes("browser"))
            return "";
        if (n.includes("rebuild") || n.includes("nix"))
            return "󱄅";
        return "";
    }
    implicitHeight: Theme.h2
    radius: Theme.rad
    border {
        width: 1
        color: Theme.bg2
    }
    color: Theme.bg0
    Text {
        id: textMeasurer
        text: centerPillRoot.islandText
        font.family: Theme.fnt
        font.pixelSize: Theme.t1
        font.bold: true
        visible: false
    }
    anchors.horizontalCenterOffset: islandActive ? 0 : asymmetricOffset
    Behavior on anchors.horizontalCenterOffset {
        NumberAnimation {
            duration: 500
            easing.type: Easing.OutExpo
        }
    }
    states: [
        State {
            name: "normal"
            when: !centerPillRoot.islandActive
            PropertyChanges {
                target: cpill
                opacity: 1.0
                visible: true
            }
            PropertyChanges {
                target: islandContent
                opacity: 0.0
                visible: false
            }
            PropertyChanges {
                target: centerPillRoot
                implicitWidth: cpill.implicitWidth + Theme.impW
            }
            PropertyChanges {
                target: floatingIcon
                anchors.horizontalCenterOffset: -centerPillRoot.asymmetricOffset
                rotation: 0
                anchors.leftMargin: 0
                iconColor: "#ffffff"
                iconText: "󱄅"
                iconSize: 35
            }
            AnchorChanges {
                target: floatingIcon
                anchors.horizontalCenter: centerPillRoot.horizontalCenter
                anchors.left: undefined
            }
        },
        State {
            name: "island"
            when: centerPillRoot.islandActive
            PropertyChanges {
                target: cpill
                opacity: 0.0
                visible: false
            }
            PropertyChanges {
                target: islandContent
                opacity: 1.0
                visible: true
            }
            PropertyChanges {
                target: centerPillRoot
                implicitWidth: Math.max(300, textMeasurer.contentWidth + 100)
            }
            PropertyChanges {
                target: floatingIcon
                anchors.horizontalCenterOffset: 0
                rotation: 360
                anchors.leftMargin: Theme.spc2
                iconColor: Theme.ac1
                iconText: centerPillRoot.getAppIcon(islandAppName)
                iconSize: Theme.t1 + 6
            }
            AnchorChanges {
                target: floatingIcon
                anchors.horizontalCenter: undefined
                anchors.left: centerPillRoot.left
            }
        }
    ]
    transitions: [
        Transition {
            from: "normal"
            to: "island"
            SequentialAnimation {
                NumberAnimation {
                    target: cpill
                    property: "opacity"
                    duration: 150
                }
                PropertyAction {
                    target: cpill
                    property: "visible"
                    value: false
                }
                PauseAnimation {
                    duration: 300
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: centerPillRoot
                        property: "implicitWidth"
                        duration: 500
                        easing.type: Easing.OutExpo
                    }
                    AnchorAnimation {
                        duration: 500
                        easing.type: Easing.OutExpo
                    }
                    NumberAnimation {
                        target: floatingIcon
                        properties: "rotation, iconSize, anchors.horizontalCenterOffset"
                        duration: 500
                        easing.type: Easing.OutExpo
                    }
                    ColorAnimation {
                        target: floatingIcon
                        property: "iconColor"
                        duration: 500
                    }
                }
                PropertyAction {
                    target: islandContent
                    property: "visible"
                    value: true
                }
                NumberAnimation {
                    target: islandContent
                    property: "opacity"
                    duration: 150
                }
            }
        },
        Transition {
            from: "island"
            to: "normal"
            SequentialAnimation {
                NumberAnimation {
                    target: islandContent
                    property: "opacity"
                    duration: 150
                }
                PropertyAction {
                    target: islandContent
                    property: "visible"
                    value: false
                }

                ParallelAnimation {
                    NumberAnimation {
                        target: centerPillRoot
                        property: "implicitWidth"
                        duration: 500
                        easing.type: Easing.OutExpo
                    }
                    AnchorAnimation {
                        duration: 500
                        easing.type: Easing.OutExpo
                    }
                    NumberAnimation {
                        target: floatingIcon
                        properties: "rotation, iconSize, anchors.horizontalCenterOffset"
                        duration: 500
                        easing.type: Easing.OutExpo
                    }
                    ColorAnimation {
                        target: floatingIcon
                        property: "iconColor"
                        duration: 500
                    }
                }
                PropertyAction {
                    target: cpill
                    property: "visible"
                    value: true
                }
                NumberAnimation {
                    target: cpill
                    property: "opacity"
                    duration: 150
                }
            }
        }
    ]
    Row {
        id: cpill
        anchors {
            centerIn: parent
            margins: Theme.outmrg
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.spc2
        Uhr1 {
            id: uhr1
        }
        Item {
            width: floatingIcon.width
            height: 1
        }
        Uhr2 {
            id: uhr2
        }
    }
    Item {
        id: islandContent
        anchors.fill: parent
        anchors.centerIn: parent
        clip: true
        RowLayout {
            anchors.fill: parent
            spacing: Theme.spc2
            Item {
                Layout.preferredWidth: floatingIcon.width + Theme.spc2
            }
            Text {
                id: islandTextItem
                text: centerPillRoot.islandText
                anchors.centerIn: parent
                font.family: Theme.fnt
                font.pixelSize: Theme.t1
                font.bold: true
                color: "#ffffff"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                Layout.rightMargin: (Theme.rad / 2)
            }
        }
    }
    Iusenixosbtw {
        id: floatingIcon
        transformOrigin: Item.Center
        z: 10
        anchors.verticalCenter: parent.verticalCenter
    }
    MouseArea {
        anchors.fill: parent
        enabled: centerPillRoot.islandActive
        onClicked: {
            IslandState.close();
        }
    }
}
