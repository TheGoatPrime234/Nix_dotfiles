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
    property int displayCount: 6
    property int totalItems: {
        if (currentMode === "main") return mainList.length;
        if (currentMode === "theme") return themeList.length;
        return wallpaperList.length;
    }
    IpcHandler {
        target: "gearwheel" 
        function toggle() {
            if (gearwheel.visible) {
                gearwheel.visible = false;
            } else {
                loadConfig();
                gearwheel.currentMode = "main";
                gearwheel.currentIndex = 0;
                gearwheel.visible = true;
            }
        }
    }
    Process {
	id: nixSwitcherProcess
	stdout: SplitParser {
	    onRead: data => {
		console.log("Output:", data);
		if (data.trim() === "done") {
		    gearwheel.visible = false;
		    loadConfig();
		}
	    }
	}
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
    function confirmSelection() {
	let bashCommand = "";
	if (currentMode === "main") {
	    if (currentIndex === 0) {
		currentMode = "theme";
	    } else {
		currentMode = "wallpaper";
	    }
	    currentIndex = 0;
	    return;
	} else if (currentMode === "theme") {
	    let selectedTheme = themeList[currentIndex];
	    bashCommand = "nix-switcher settheme " + selectedTheme + " && nix-switcher apply && echo done";
	} else if (currentMode === "wallpaper") {
	    bashCommand = "nix-switcher setwall " + currentIndex.toString() + " && nix-switcher apply && echo done";
	}
	nixSwitcherProcess.command = ["bash", "-c", bashCommand];
	nixSwitcherProcess.running = true;
	currentMode = "main";
    }
    Item {
        id: wheelContainer
        width: gearwheel.implicitWidth
        height: gearwheel.implicitHeight
        anchors.centerIn: parent
        focus: true
        Keys.onPressed: event => {
            if (gearwheel.totalItems > 0) {
                if (event.key === Qt.Key_K || event.key === Qt.Key_Down) {
                    gearwheel.currentIndex = (gearwheel.currentIndex + 1) % gearwheel.totalItems;
                    event.accepted = true;
                } else if (event.key === Qt.Key_J || event.key === Qt.Key_Up) {
                    gearwheel.currentIndex = (gearwheel.currentIndex - 1 + gearwheel.totalItems) % gearwheel.totalItems;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Return) {
                    confirmSelection();
                    event.accepted = true;
                }
            }
            if (event.key === Qt.Key_Q || event.key === Qt.Key_Escape) {
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
                if (gearwheel.totalItems > 0) {
                    if (wheel.angleDelta.y > 0) {
                        gearwheel.currentIndex = (gearwheel.currentIndex - 1 + gearwheel.totalItems) % gearwheel.totalItems;
                    } else if (wheel.angleDelta.y < 0) {
                        gearwheel.currentIndex = (gearwheel.currentIndex + 1) % gearwheel.totalItems;
                    }
                }
            }
        }
        Repeater {
            model: gearwheel.displayCount
            Image {
                id: lambdaSegment
                source: "segment_asym.svg"
                sourceSize.width: width
                sourceSize.height: height
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                rotation: index * (360 / gearwheel.displayCount)
                property int currentPage: Math.floor(gearwheel.currentIndex / gearwheel.displayCount)
                property int realIndex: (currentPage * gearwheel.displayCount) + index
                property bool isValid: realIndex < gearwheel.totalItems
                property bool isSelected: isValid && (realIndex === gearwheel.currentIndex)
                opacity: isSelected ? 1.0 : (isValid ? 0.4 : 0.05)
                scale: isSelected ? 1.15 : 1.0
                Behavior on opacity { NumberAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (isValid) {
                            gearwheel.currentIndex = realIndex;
                            confirmSelection();
                        }
                    }
                }
                Item {
                    height: 80
                    width: (height * 16) / 9
                    anchors.centerIn: parent
                    rotation: -(index * (360 / gearwheel.displayCount))
                    Rectangle {
                        anchors.fill: parent
                        radius: Theme.rad
                        clip: true      
                        color: Theme.trans
                        visible: isValid && gearwheel.currentMode !== "main"
                        Image {
                            anchors.fill: parent
			    opacity: isSelected ? 100 : 0
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true 
                            source: {
                                if (!isValid) return "";
                                if (gearwheel.currentMode === "wallpaper") {
                                    return "file://" + gearwheel.wallpaperList[realIndex];
                                } 
                                else if (gearwheel.currentMode === "theme") {
                                    let themeName = gearwheel.themeList[realIndex];
                                    let themeWalls = gearwheel.fullJsonData.theme[themeName].wallpapers;
                                    if (themeWalls && themeWalls.length > 0) {
                                        return "";
                                    }
                                }
                                return "";
                            }
                        }
                        Rectangle {
                            anchors.fill: parent
                            color: Theme.trans
                            opacity: gearwheel.currentMode === "theme" ? 0.5 : 0.0 
                        }
                    }
                    Text {
                        font {
                            pixelSize: Theme.t1 * (gearwheel.currentMode === "main" ? 1.5 : 1.2)
                            bold: true
                            family: Theme.fnt
                        }
                        anchors.centerIn: parent
                        color: isSelected ? Theme.ac1 : Theme.trans
                        visible: gearwheel.currentMode !== "wallpaper"
                        text: {
                            if (!isValid) return "";
                            if (gearwheel.currentMode === "main") return gearwheel.mainList[realIndex];
                            if (gearwheel.currentMode === "theme") return gearwheel.themeList[realIndex];
                            return "";
                        }
                    }
                }
            }
        }
    }
}
