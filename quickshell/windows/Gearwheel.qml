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
        onExited: {
            console.log("Speichern erfolgreich - führe jetzt apply aus...");
            applyProcess.running = true;
            loadConfig(); 
        }
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
            // WICHTIG: Wenn die Liste leer ist, crasht Modulo-Mathe. Daher die > 0 Prüfung.
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
            // Das Model ist jetzt fest auf 6 verankert!
            model: gearwheel.displayCount
            
            Image {
                id: lambdaSegment
                source: "segment_asym.svg"
                sourceSize.width: width
                sourceSize.height: height
                anchors.fill: parent
                fillMode: Image.PreserveAspectFit
                
                // Rotiert immer in perfekten 60° Schritten, egal wie viele Items es gibt
                rotation: index * (360 / gearwheel.displayCount)
                
                // --- NEUE SEITEN-LOGIK ---
                // Berechnet, auf welcher "Seite" (0, 1, 2...) wir uns befinden
                property int currentPage: Math.floor(gearwheel.currentIndex / gearwheel.displayCount)
                
                // Welcher echte Index aus der JSON gehört zu diesem speziellen Segment?
                property int realIndex: (currentPage * gearwheel.displayCount) + index
                
                // Existiert dieser Index in unseren Daten, oder ist das Lambda gerade "leer"?
                property bool isValid: realIndex < gearwheel.totalItems
                
                // Ist dieses Lambda gerade angewählt?
                property bool isSelected: isValid && (realIndex === gearwheel.currentIndex)
 
                // Wenn es keine Daten hat (isValid = false), machen wir es fast unsichtbar (0.05),
                // so bleibt die Sechseck-Silhouette wie ein Wasserzeichen im Hintergrund erhalten!
                opacity: isSelected ? 1.0 : (isValid ? 0.4 : 0.05)
                scale: isSelected ? 1.15 : 1.0
                
                Behavior on opacity { NumberAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
                
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        // Man kann nur auf Lambdas klicken, die auch gültige Daten haben
                        if (isValid) {
                            gearwheel.currentIndex = realIndex;
                            confirmSelection();
                        }
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
                    
                    // Text wird nur angezeigt, wenn das Segment auch gültig ist
                    text: {
                        if (!isValid) return "";
                        if (gearwheel.currentMode === "main") return gearwheel.mainList[realIndex];
                        if (gearwheel.currentMode === "theme") return gearwheel.themeList[realIndex];
                        return "Wall " + (realIndex + 1);
                    }
                    
                    rotation: -(index * (360 / gearwheel.displayCount))
                }
            }
        }
    }
}
