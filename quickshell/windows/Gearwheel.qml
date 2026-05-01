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
    property var mainList: ["Themes", "Wallpaper"] 
    property var themeList: []
    property var wallpaperList: []
    property var fullJsonData: null
    property int currentIndex: 0
    property string currentMode: "main" 
    property int segmentCount: {
        if (currentMode === "main") return mainList.length;
        if (currentMode === "theme") return themeList.length;
        return wallpaperList.length;
    }
    function loadConfig() {
        var reqLinks = new XMLHttpRequest();
        reqLinks.open("GET", "file:///home/cato/.config/rice/nix-switcher/links.json", false);
        reqLinks.send(null);
        if (reqLinks.status === 200 || reqLinks.status === 0) {
            fullJsonData = JSON.parse(reqLinks.responseText);
            themeList = Object.keys(fullJsonData.theme);
        }
        var reqConfig = new XMLHttpRequest();
        reqConfig.open("GET", "file:///home/cato/.config/rice/nix-switcher/config.json", false);
        reqConfig.send(null);
        if (reqConfig.status === 200 || reqConfig.status === 0) {
            var activeConfig = JSON.parse(reqConfig.responseText);
            var activeTheme = activeConfig.theme;
            if (fullJsonData && fullJsonData.theme[activeTheme]) {
                wallpaperList = fullJsonData.theme[activeTheme].wallpapers;
            }
        }
    }
    Component.onCompleted: loadConfig()
    color: Theme.trans
    Process {
        id: nixSwitcherProcess
    }
    Process {
        id: applyProcess
        command: ["nix-switcher", "apply"]
    }
    function confirmSelection() {
        if (currentMode === "main") {
            if (currentIndex === 0) {
                currentMode = "theme";
            } else {
                currentMode = "wallpaper";
            }
            currentIndex = 0;
        } else if (currentMode === "theme") {
            // Theme anwenden
            let selectedTheme = themeList[currentIndex];
            console.log("Führe aus: nix-switcher settheme " + selectedTheme);
            nixSwitcherProcess.command = ["nix-switcher", "settheme", selectedTheme];
            nixSwitcherProcess.running = true;
            gearwheel.visible = false;
            currentMode = "main"; 
        } else if (currentMode === "wallpaper") {
            console.log("Führe aus: nix-switcher setwall " + currentIndex);
            nixSwitcherProcess.command = ["nix-switcher", "setwall", currentIndex.toString()];
            nixSwitcherProcess.running = true;
            gearwheel.visible = false;
            currentMode = "main";
        }
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
                confirmSelection();
                event.accepted = true;
            } else if (event.key === Qt.Key_Q || event.key === Qt.Key_Escape) {
                if (gearwheel.currentMode !== "main") {
                    gearwheel.currentMode = "main";
                    gearwheel.currentIndex = 0;
                } else {
                    gearwheel.visible = false;
                }
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
                
                Behavior on opacity { NumberAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        gearwheel.currentIndex = index;
                        confirmSelection();
                    }
                }
                Text {
                    font {
                        pixelSize: Theme.t1 * 1.5
                        bold: true
                        family: Theme.fnt
                    }
                    anchors.centerIn: parent
                    color: parent.isSelected ? "black" : Theme.trans
                    text: {
                        if (gearwheel.currentMode === "main") return gearwheel.mainList[index];
                        if (gearwheel.currentMode === "theme") return gearwheel.themeList[index];
                        return "Wall " + (index + 1);
                    }
                    rotation: -(index * (360 / gearwheel.segmentCount))
                }
            }
        }
    }
    onVisibleChanged: {
	if (!visible) {
	    console.log("Rad geschlossen - führe nix-switcher apply aus...");
	    applyProcess.running = true;
	    loadConfig(); 
	}
    }
}
