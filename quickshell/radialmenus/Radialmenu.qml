import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "./../color"

// ─────────────────────────────────────────────────────────────────────────────
//  HOW TO ADD A NEW MENU ENTRY
//  ───────────────────────────
//  1. Append an object to `menuEntries` below.
//  2. Every entry needs:
//       label   – text shown on the gear segment
//       mode    – unique string key for this entry's sub-menu state
//       load    – JS function called once when the entry is opened;
//                 must populate `dynamicItems` with an array of objects
//                 { label, preview, action } where
//                     label    – text shown in the sub-menu
//                     preview  – optional image path (or "" for none)
//                     action   – JS function called when the item is confirmed
//
//  Example (brightness slider stub):
//
//    { label: "Brightness",
//      mode:  "brightness",
//      load:  function() {
//                 gearwheel.dynamicItems = [50, 60, 70, 80, 90, 100].map(v => ({
//                     label:   v + "%",
//                     preview: "",
//                     action:  function() {
//                         nixSwitcherProcess.command = ["bash","-c","brightnessctl s "+v+"%"];
//                         nixSwitcherProcess.running = true;
//                     }
//                 }));
//             }
//    }
// ─────────────────────────────────────────────────────────────────────────────

PanelWindow {
    id: gearwheel
    visible: false
    implicitWidth:  700
    implicitHeight: 600
    WlrLayershell.layer: WlrLayer.Overlay
    aboveWindows: true
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    // ── shared runtime state ──────────────────────────────────────────────────
    property int    currentIndex: 0
    property string currentMode:  "main"      // "main" | any entry.mode value
    property int    displayCount: 6

    // Items shown in the current sub-menu (filled by the active entry's load())
    property var dynamicItems: []

    // Resolved list that the repeater works against
    property var activeList: {
        if (currentMode === "main") return menuEntries.map(e => ({ label: e.label, preview: "", action: null }));
        return dynamicItems;
    }
    property int totalItems: activeList.length

    // ── menu entry definitions (THE only place you need to touch) ─────────────
    property var menuEntries: [
        {
            label: "Themes",
            mode:  "theme",
            load:  function() {
                var req = new XMLHttpRequest();
                req.open("GET", "file:///home/cato/.config/rice/nix-switcher/links.json", false);
                req.send(null);
                if (req.status === 200 || req.status === 0) {
                    var json = JSON.parse(req.responseText);
                    gearwheel.fullJsonData = json;
                    gearwheel.dynamicItems = Object.keys(json.theme).map(name => ({
                        label:   name,
                        preview: "",
                        action:  function() {
                            var cmd = "nix-switcher settheme " + name + " && nix-switcher apply && echo done";
                            nixSwitcherProcess.command = ["bash", "-c", cmd];
                            nixSwitcherProcess.running = true;
                        }
                    }));
                }
            }
        },
        {
            label: "Wallpaper",
            mode:  "wallpaper",
            load:  function() {
                // Reuse already-loaded JSON; fall back to disk if needed
                var json = gearwheel.fullJsonData;
                if (!json) {
                    var req = new XMLHttpRequest();
                    req.open("GET", "file:///home/cato/.config/rice/nix-switcher/links.json", false);
                    req.send(null);
                    if (req.status === 200 || req.status === 0) json = JSON.parse(req.responseText);
                    gearwheel.fullJsonData = json;
                }
                var cfgReq = new XMLHttpRequest();
                cfgReq.open("GET", "file:///home/cato/.config/rice/nix-switcher/config.json", false);
                cfgReq.send(null);
                var walls = [];
                if ((cfgReq.status === 200 || cfgReq.status === 0) && json) {
                    var active = JSON.parse(cfgReq.responseText).theme;
                    walls = json.theme[active] ? json.theme[active].wallpapers : [];
                }
                gearwheel.dynamicItems = walls.map((path, idx) => ({
                    label:   "",
                    preview: "file://" + path,
                    action:  (function(i) { return function() {
                        var cmd = "nix-switcher setwall " + i + " && nix-switcher apply && echo done";
                        nixSwitcherProcess.command = ["bash", "-c", cmd];
                        nixSwitcherProcess.running = true;
                    }; })(idx)
                }));
            }
        },
	{
	    label: "Link",
	    mode:  "link-wall",
	    load:  function() {
		gearwheel.pendingLinkWallIndex = -1;
		var req = new XMLHttpRequest();
		req.open("GET", "file:///home/cato/.config/rice/nix-switcher/wallpaper.json", false);
		req.send(null);
		var walls = [];
		if (req.status === 200 || req.status === 0)
		    walls = JSON.parse(req.responseText);
		gearwheel.dynamicItems = walls.map((path, idx) => ({
		    label:   "",
		    preview: "file://" + path,
		    action:  (function(i) { return function() {
			gearwheel.pendingLinkWallIndex = i;
			gearwheel.currentMode  = "link-theme";
			gearwheel.currentIndex = 0;
			gearwheel.loadLinkThemes();
		    }; })(idx)
		}));
	    }
	}
        // ── Add more entries here ──────────────────────────────────────────────
    ]

    // Keep fullJsonData cached between loads
    property var fullJsonData: null
    property int pendingLinkWallIndex: -1

    // ── IPC ───────────────────────────────────────────────────────────────────
    IpcHandler {
        target: "gearwheel"
        function toggle() {
            if (gearwheel.visible) {
                gearwheel.visible = false;
            } else {
                gearwheel.currentMode  = "main";
                gearwheel.currentIndex = 0;
                gearwheel.dynamicItems = [];
                gearwheel.visible      = true;
            }
        }
    }

    // ── Process runner ────────────────────────────────────────────────────────
    Process {
        id: nixSwitcherProcess
        stdout: SplitParser {
            onRead: data => {
                console.log("nix-switcher:", data);
                if (data.trim() === "done") {
                    gearwheel.visible = false;
                    // Reload cache so next open is fresh
                    gearwheel.fullJsonData = null;
                }
            }
        }
    }

    // ── Confirm / navigate ────────────────────────────────────────────────────
    function confirmSelection() {
        if (currentMode === "main") {
            // Open the selected entry's sub-menu
            var entry = menuEntries[currentIndex];
            if (!entry) return;
            currentMode  = entry.mode;
            currentIndex = 0;
            dynamicItems = [];
            entry.load();
        } else if (currentMode === "link-wall") {
            // Action setzt currentMode selbst auf "link-theme" – nicht überschreiben
            var item = activeList[currentIndex];
            if (item && item.action) item.action();
        } else {
            // Execute the item's action
            var item = activeList[currentIndex];
            if (item && item.action) item.action();
            currentMode  = "main";
            currentIndex = 0;
        }
    }

    function loadLinkThemes() {
	var req = new XMLHttpRequest();
	req.open("GET", "file:///home/cato/.config/rice/nix-switcher/links.json", false);
	req.send(null);
	var themes = [];
	if (req.status === 200 || req.status === 0)
	    themes = Object.keys(JSON.parse(req.responseText).theme);
	gearwheel.dynamicItems = themes.map(name => ({
	    label:   name,
	    preview: "",
	    action:  function() {
		var cmd = "nix-switcher link " + gearwheel.pendingLinkWallIndex + " " + name + " && echo done";
		nixSwitcherProcess.command = ["bash", "-c", cmd];
		nixSwitcherProcess.running = true;
	    }
	}));
    }

    // ── Visual ────────────────────────────────────────────────────────────────
    color: Theme.trans

    Item {
        id: wheelContainer
        width:  gearwheel.implicitWidth
        height: gearwheel.implicitHeight
        anchors.centerIn: parent
        focus: true

        Keys.onPressed: event => {
            if (gearwheel.totalItems > 0) {
                if (event.key === Qt.Key_K || event.key === Qt.Key_Tab || event.key === Qt.Key_Down) {
                    gearwheel.currentIndex = (gearwheel.currentIndex + 1) % gearwheel.totalItems;
                    event.accepted = true;
                } else if (event.key === Qt.Key_J || event.key === Qt.Key_Up) {
                    gearwheel.currentIndex = (gearwheel.currentIndex - 1 + gearwheel.totalItems) % gearwheel.totalItems;
                    event.accepted = true;
                } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Space || event.key === Qt.Key_Return) {
                    confirmSelection();
                    event.accepted = true;
                }
            }
            if (event.key === Qt.Key_Q || event.key === Qt.Key_Backspace || event.key === Qt.Key_Escape) {
                if (gearwheel.currentMode !== "main") {
                    gearwheel.currentMode  = "main";
                    gearwheel.currentIndex = 0;
                } else {
                    gearwheel.visible = false;
                }
                event.accepted = true;
            }
        }

        MouseArea {
            anchors.centerIn: parent
            width:  gearwheel.width
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
			sourceSize.width:  width
			sourceSize.height: height
			anchors.fill: parent
			fillMode: Image.PreserveAspectFit
			rotation: index * (360 / gearwheel.displayCount)

			property int  currentPage: Math.floor(gearwheel.currentIndex / gearwheel.displayCount)
			property int  realIndex:   (currentPage * gearwheel.displayCount) + index
			property bool isValid:     realIndex < gearwheel.totalItems
			property bool isSelected:  isValid && (realIndex === gearwheel.currentIndex)
			
			property var  activeItem:  isValid ? gearwheel.activeList[realIndex] : null

			opacity: isSelected ? 1.0 : (isValid ? 0.4 : 0.05)
			scale:   isSelected ? 1.15 : 1.0
			Behavior on opacity { NumberAnimation { duration: 100 } }
			Behavior on scale   { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }

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
			    width:  (height * 16) / 9
			    anchors.centerIn: parent
			    rotation: -(index * (360 / gearwheel.displayCount))

			    // Preview image (wallpapers / anything with a preview path)
			    Rectangle {
				anchors.fill: parent
				radius: Theme.rad
				clip:   true
				color:  Theme.trans
				visible: isValid && activeItem && activeItem.preview !== ""

				Image {
				    anchors.fill: parent
				    opacity:      isSelected ? 1.0 : 0.0
				    fillMode:     Image.PreserveAspectCrop
				    asynchronous: true
				    
				    // --- VRAM & Performance Fix ---
				    // Skaliert die 4K/8K Wallhaven Bilder sofort beim Laden herunter
				    sourceSize.width: 150
				    sourceSize.height: 150
				    
				    // --- Sonderzeichen Fix ---
				    // encodeURI fixt Leerzeichen und Klammern in den Dateinamen
				    source:       (activeItem && activeItem.preview) ? encodeURI(activeItem.preview) : ""
				}
			    }

			    // Label text (main menu + any sub-menu entry that has a label)
			    Text {
				font {
				    pixelSize: Theme.t1 * (gearwheel.currentMode === "main" ? 1.5 : 1.2)
				    bold:      true
				    family:    Theme.fnt
				}
				anchors.centerIn: parent
				color:   isSelected ? Theme.ac1 : Theme.trans
				visible: isValid && activeItem && activeItem.label !== ""
				text:    (activeItem && activeItem.label) ? activeItem.label : ""
			    }
			}
		    }
		}
	    } // Ende von: Item { id: wheelContainer }
}
