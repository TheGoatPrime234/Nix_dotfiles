import Quickshell
import Quickshell.Wayland
import Quickshell.Io
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
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    property int currentIndex: 0
    property var themeList: []
    property var wallpaperList: []
    property var fullJsonData: null
    property string currentMode: "theme"
    property int segmentCount: currentMode === "theme" ? themeList.length : wallpaperList.length
    function loadConfig() {
        var request = new XMLHttpRequest();
        request.open("GET", "file:///home/cato/.config/rice/nix-switcher/links.json", false);
        request.send(null);
        if (request.status === 200 || request.status === 0) {
            fullJsonData = JSON.parse(request.responseText);
            themeList = Object.keys(fullJsonData.theme);
        } else {
            console.error("Konnte links.json nicht laden!");
        }
    }
    Component.onCompleted: loadConfig()
    color: Theme.trans
    Process {
        id: nixSwitcherProcess
    }
    function applyTheme() {
        if (currentMode === "theme") {
            let selectedTheme = themeList[currentIndex];
            console.log("Führe aus: nix-switcher settheme " + selectedTheme);
            nixSwitcherProcess.command = ["nix-switcher", "settheme", selectedTheme];
            nixSwitcherProcess.running = true;
        } else if (currentMode === "wallpaper") {
            console.log("Führe aus: nix-switcher setwall " + currentIndex);
            nixSwitcherProcess.command = ["nix-switcher", "setwall", currentIndex.toString()];
            nixSwitcherProcess.running = true;
        }

        gearwheel.visible = false;
    }
    Item {
        id: wheelContainer
        width: gearwheel.implicitWidth
        height: gearwheel.implicitHeight
        anchors.centerIn: parent
        focus: true
        Keys.onPressed: event => {
            if (event.key === Qt.Key_K || event.key === Qt.Key_Down) {
                gearwheel.currentIndex = (gearwheel.currentIndex + 1) % gearwheel.segmentCount;
                event.accepted = true;
            } else if (event.key === Qt.Key_J || event.key === Qt.Key_Up) {
                gearwheel.currentIndex = (gearwheel.currentIndex - 1 + gearwheel.segmentCount) % gearwheel.segmentCount;
                event.accepted = true;
            } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                applyTheme();
                event.accepted = true;
            } else if (event.key === Qt.Key_Escape) {
                gearwheel.visible = false;
                event.accepted = true;
            }
        }
        MouseArea {
            anchors.centerIn: parent
            width: gearwheel.width
            height: gearwheel.height
            onWheel: {
                if (wheel.angleDelta.y > 0) {
                    gearwheel.currentIndex = (gearwheel.currentIndex - 1 + gearwheel.segmentCount) % gearwheel.segmentCount;
                } else if (wheel.angleDelta.y < 0) {
                    gearwheel.currentIndex = (gearwheel.currentIndex + 1) % gearwheel.segmentCount;
                }
            }
        }
        Repeater {
            model: gearwheel.segmentCount
            Image {
                id: lambdaSegment
                source: "segment_asym.svg"
                sourceSize.width: width
                sourceSize.height: height
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                rotation: index * (360 / gearwheel.segmentCount)
                property bool isSelected: index == gearwheel.currentIndex
                opacity: isSelected ? 1.0 : 0.4
                scale: isSelected ? 1.15 : 1.0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 100
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        gearwheel.currentIndex = index;
                        applyTheme();
                    }
                }
                Text {
                    anchors.centerIn: parent
                    color: "black"
                    text: gearwheel.currentMode === "theme" ? gearwheel.themeList[index] : "Wall" + index
                    rotation: -(index * (360 / gearwheel.segmentCount))
                }
            }
        }
    }
}
