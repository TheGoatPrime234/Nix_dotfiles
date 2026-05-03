import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "./../color"

// ─────────────────────────────────────────────────────────────────────────────
//  HOW TO ADD A NEW MENU ENTRY
//  ───────────────────────────
//  Append an object to `menuEntries`. Jeder Eintrag hat:
//
//    label    – Text auf dem Segment
//    load     – Funktion die `dynamicItems` befüllt. Jedes Item hat:
//                 label    – Text im Untermenü (oder "" bei reinen Bildern)
//                 preview  – Bildpfad (oder "")
//                 action   – Funktion die beim Bestätigen ausgeführt wird ODER
//                 children – Array von weiteren Items (erzeugt eine Stufe tiefer)
//
//  ESC / Backspace geht immer genau EINE Stufe zurück.
//  Beliebige Tiefe möglich – einfach `children` ineinander verschachteln.
//
//  Beispiel – 3-stufig:
//
//    { label: "Quick Set",
//      load: function() {
//        gearwheel.pushLevel("Quick Set", [
//          { label: "RAM-Modes",
//            children: [
//              { label: "Normal",      preview: "", action: function() { ... } },
//              { label: "Performance", preview: "", action: function() { ... } },
//            ]
//          },
//          { label: "GPU-Modes",
//            children: [ ... ]
//          }
//        ]);
//      }
//    }
//
//  Beispiel – 2-stufig (flache Liste, kein children):
//
//    { label: "Themes",
//      load: function() {
//        gearwheel.pushLevel("Themes", myItems);
//      }
//    }
// ─────────────────────────────────────────────────────────────────────────────

PanelWindow {
    id: gearwheel
    visible: false
    implicitWidth: 960
    implicitHeight: 600
    WlrLayershell.layer: WlrLayer.Overlay
    aboveWindows: true
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property int displayCount: 6

    // ── Navigations-Stack ─────────────────────────────────────────────────────
    // Jede Ebene: { title: string, items: [...], selectedIndex: int }
    property var navStack: []

    // Eigener Index für das Hauptmenü
    property int mainIndex: 0

    // Aktuelle Ebene
    property var currentLevel: navStack.length > 0 ? navStack[navStack.length - 1] : null
    property var activeList:   currentLevel ? currentLevel.items : menuEntries.map(e => ({ label: e.label, preview: "", children: null, action: null }))
    property int currentIndex: currentLevel ? currentLevel.selectedIndex : mainIndex
    property int totalItems:   activeList.length
    property bool onMain:      navStack.length === 0

    // Index-Setter: Hauptmenü → mainIndex, Untermenü → Stack
    function setIndex(i) {
        if (navStack.length === 0) {
            mainIndex = i;
        } else {
            var stack = navStack.slice();
            stack[stack.length - 1].selectedIndex = i;
            navStack = stack;
        }
    }

    // Eine Ebene tiefer gehen
    function pushLevel(title, items) {
        var stack = navStack.slice();
        stack.push({ title: title, items: items, selectedIndex: 0 });
        navStack = stack;
    }

    // Eine Ebene zurück (ESC)
    function popLevel() {
        if (navStack.length === 0) {
            gearwheel.visible = false;
            return;
        }
        var stack = navStack.slice();
        stack.pop();
        navStack = stack;
    }

    // Bestätigen
    function confirmSelection() {
        var item = activeList[currentIndex];
        if (!item) return;

        if (onMain) {
            // Hauptmenü → entry.load() aufrufen
            var entry = menuEntries[currentIndex];
            if (entry && entry.load) entry.load();
        } else if (item.children) {
            // Untermenü mit weiteren Kindern → eine Stufe tiefer
            pushLevel(item.label, item.children);
        } else if (item.action) {
            // Blatt-Aktion ausführen
            item.action();
        }
    }

    // ── Cached data ───────────────────────────────────────────────────────────
    property var fullJsonData: null

    // ── Menu entry definitions ────────────────────────────────────────────────
    property var menuEntries: [
        // ── Quick Set (3-stufig) ──────────────────────────────────────────────
        {
            label: "Quick Set",
            load: function() {
                gearwheel.pushLevel("Quick Set", [
                    {
                        label: "RAM-Modes",
                        preview: "",
                        children: [
                            {
                                label: "Normal",
                                preview: "",
                                action: function() {
                                    nixSwitcherProcess.command = ["bash", "-c", "notify-send normal"];
                                    nixSwitcherProcess.running = true;
                                }
                            }
                            // Weitere RAM-Modi hier einfügen
                        ]
                    }
                    // Weitere Kategorien hier einfügen
                ]);
            }
        },

        // ── Themes ───────────────────────────────────────────────────────────
        {
            label: "Themes",
            load: function() {
                var req = new XMLHttpRequest();
                req.open("GET", "file:///home/cato/.config/rice/nix-switcher/links.json", false);
                req.send(null);
                if (req.status === 200 || req.status === 0) {
                    var json = JSON.parse(req.responseText);
                    gearwheel.fullJsonData = json;
                    var items = Object.keys(json.theme).map(name => ({
                        label:   name,
                        preview: "",
                        action:  function() {
                            var cmd = "nix-switcher settheme " + name + " && nix-switcher apply && echo done";
                            nixSwitcherProcess.command = ["bash", "-c", cmd];
                            nixSwitcherProcess.running = true;
                        }
                    }));
                    gearwheel.pushLevel("Themes", items);
                }
            }
        },

        // ── Wallpaper ─────────────────────────────────────────────────────────
        {
            label: "Wallpaper",
            load: function() {
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
                var items = walls.map((path, idx) => ({
                    label:   "",
                    preview: "file://" + path,
                    action:  (function(i) { return function() {
                        var cmd = "nix-switcher setwall " + i + " && nix-switcher apply && echo done";
                        nixSwitcherProcess.command = ["bash", "-c", cmd];
                        nixSwitcherProcess.running = true;
                    }; })(idx)
                }));
                gearwheel.pushLevel("Wallpaper", items);
            }
        },

        // ── Link (Wallpaper → Theme, 2 Stufen über Stack) ────────────────────
        {
            label: "Link",
            load: function() {
                var req = new XMLHttpRequest();
                req.open("GET", "file:///home/cato/.config/rice/nix-switcher/wallpaper.json", false);
                req.send(null);
                var walls = [];
                if (req.status === 200 || req.status === 0)
                    walls = JSON.parse(req.responseText);

                var items = walls.map((path, idx) => ({
                    label:   path.split("/").pop(),
                    preview: "file://" + path,
                    // children werden dynamisch beim Öffnen erzeugt
                    children: (function(wallIdx) {
                        var themeReq = new XMLHttpRequest();
                        themeReq.open("GET", "file:///home/cato/.config/rice/nix-switcher/links.json", false);
                        themeReq.send(null);
                        var themes = [];
                        if (themeReq.status === 200 || themeReq.status === 0)
                            themes = Object.keys(JSON.parse(themeReq.responseText).theme);
                        return themes.map(name => ({
                            label:   name,
                            preview: "",
                            action:  function() {
                                var cmd = "nix-switcher link " + wallIdx + " " + name + " && echo done";
                                nixSwitcherProcess.command = ["bash", "-c", cmd];
                                nixSwitcherProcess.running = true;
                            }
                        }));
                    })(idx)
                }));
                gearwheel.pushLevel("Link › Wallpaper", items);
            }
        },

        // ── Rebuild ───────────────────────────────────────────────────────────
        {
            label: "Rebuild",
            load: function() {
                var cmd = "kitty --class kitty-floating bash -c 'restituo; echo \"\"; read -n 1 -s -r -p \"Rebuild beendet! Drücke eine beliebige Taste...\"'";
                nixSwitcherProcess.command = ["bash", "-c", cmd];
                gearwheel.visible = false;
                nixSwitcherProcess.running = true;
            }
        },

        // ── Shutdown / Session ────────────────────────────────────────────────
        {
            label: "Shutdown",
            load: function() {
                gearwheel.pushLevel("Shutdown", [
                    { label: "Suspend",   preview: "", action: function() { nixSwitcherProcess.command = ["bash","-c","systemctl suspend"];       nixSwitcherProcess.running = true; } },
                    { label: "Hibernate", preview: "", action: function() { nixSwitcherProcess.command = ["bash","-c","systemctl hibernate"];      nixSwitcherProcess.running = true; } },
                    { label: "Shutdown",  preview: "", action: function() { nixSwitcherProcess.command = ["bash","-c","systemctl poweroff"];       nixSwitcherProcess.running = true; } },
                    { label: "Reboot",    preview: "", action: function() { nixSwitcherProcess.command = ["bash","-c","systemctl reboot"];         nixSwitcherProcess.running = true; } },
                    { label: "Lock",      preview: "", action: function() { nixSwitcherProcess.command = ["bash","-c","hyprlock"];                 nixSwitcherProcess.running = true; } },
                    { label: "Logout",    preview: "", action: function() { nixSwitcherProcess.command = ["bash","-c","hyprctl dispatch exit"];    nixSwitcherProcess.running = true; } }
                ]);
            }
        }

        // ── Weitere Einträge hier einfügen ────────────────────────────────────
    ]

    // ── IPC ───────────────────────────────────────────────────────────────────
    IpcHandler {
        target: "gearwheel"
        function toggle() {
            if (gearwheel.visible) {
                gearwheel.visible = false;
            } else {
                gearwheel.navStack     = [];
                gearwheel.mainIndex    = 0;
                gearwheel.fullJsonData = null;
                gearwheel.visible     = true;
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
                    gearwheel.visible      = false;
                    gearwheel.fullJsonData = null;
                }
            }
        }
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
                    gearwheel.setIndex((gearwheel.currentIndex + 1) % gearwheel.totalItems);
                    event.accepted = true;
                } else if (event.key === Qt.Key_J || event.key === Qt.Key_Up) {
                    gearwheel.setIndex((gearwheel.currentIndex - 1 + gearwheel.totalItems) % gearwheel.totalItems);
                    event.accepted = true;
                } else if (event.key === Qt.Key_Enter || event.key === Qt.Key_Space || event.key === Qt.Key_Return) {
                    confirmSelection();
                    event.accepted = true;
                }
            }
            if (event.key === Qt.Key_Q || event.key === Qt.Key_Backspace || event.key === Qt.Key_Escape) {
                gearwheel.popLevel();   // immer nur eine Stufe zurück
                event.accepted = true;
            }
        }

        MouseArea {
            anchors.centerIn: parent
            width:  gearwheel.width
            height: gearwheel.height
            onWheel: {
                if (gearwheel.totalItems > 0) {
                    if (wheel.angleDelta.y > 0)
                        gearwheel.setIndex((gearwheel.currentIndex - 1 + gearwheel.totalItems) % gearwheel.totalItems);
                    else if (wheel.angleDelta.y < 0)
                        gearwheel.setIndex((gearwheel.currentIndex + 1) % gearwheel.totalItems);
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
                            gearwheel.setIndex(realIndex);
                            confirmSelection();
                        }
                    }
                }

                Item {
                    height: 80
                    width:  (height * 16) / 9
                    anchors.centerIn: parent
                    rotation: -(index * (360 / gearwheel.displayCount))

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
                            sourceSize.width:  150
                            sourceSize.height: 150
                            source: (activeItem && activeItem.preview) ? encodeURI(activeItem.preview) : ""
                        }
                    }

                    Text {
                        font {
                            pixelSize: Theme.t1 * (gearwheel.onMain ? 1.5 : 1.2)
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

        // ── Breadcrumb ────────────────────────────────────────────────────────
        Text {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 16
            }
            font { pixelSize: Theme.t1; family: Theme.fnt }
            color:   Theme.fg
            opacity: 0.5
            text: {
                if (gearwheel.navStack.length === 0) return "";
                return gearwheel.navStack.map(l => l.title).join(" › ");
            }
        }

    } // Ende von: Item { id: wheelContainer }
}
