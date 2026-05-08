import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import "./../color"
import "MenuOptions.js" as MenuLogic

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
    property var navStack: []
    property int mainIndex: 0
    property var currentLevel: navStack.length > 0 ? navStack[navStack.length - 1] : null
    property var cachedMainMenu: menuEntries.map(e => ({ label: e.label, preview: "", children: null, action: null }))
    property var activeList: currentLevel ? currentLevel.items : cachedMainMenu
    property int currentIndex: currentLevel ? currentLevel.selectedIndex : mainIndex
    property int totalItems:   activeList.length
    property bool onMain:      navStack.length === 0
    property int startupVisibleSegments: 0 
    Timer {
        id: startupTimer
        interval: 40 
        repeat: true
        onTriggered: {
            if (gearwheel.startupVisibleSegments < gearwheel.displayCount) {
                gearwheel.startupVisibleSegments += 1;
            } else {
                stop(); 
            }
        }
    }
    onVisibleChanged: {
        if (visible) {
            startupTimer.start();
        } else {
            startupTimer.stop();
            startupVisibleSegments = 0;
        }
    }
    function setIndex(i) {
        if (navStack.length === 0) {
            mainIndex = i;
        } else {
            var last = navStack[navStack.length - 1];
            var newLevel = { title: last.title, items: last.items, selectedIndex: i };
            navStack = [...navStack.slice(0, -1), newLevel];
        }
    }
    function pushLevel(title, items) {
        navStack = [...navStack, { title: title, items: items, selectedIndex: 0 }];
    }
    function popLevel() {
        if (navStack.length === 0) {
            gearwheel.visible = false;
            return;
        }
        navStack = navStack.slice(0, -1);
    }
    function confirmSelection() {
        var item = activeList[currentIndex];
        if (!item) return;
        if (onMain) {
            var entry = menuEntries[currentIndex];
            if (entry && entry.load) entry.load();
        } else if (item.children) {
            var childItems = typeof item.children === "function" ?
                item.children() : item.children;
            pushLevel(item.label, childItems);
        } else if (item.load) {
            item.load();
        } else if (item.action) {
            item.action();
            gearwheel.visible = false;
        }
    }
    property var fullJsonData: null
    property var menuEntries: MenuLogic.buildMenu(gearwheel, GlobalNotifs, GlobalDashboard, nixSwitcherProcess)
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
    Process {
        id: nixSwitcherProcess
        stdout: SplitParser {
            onRead: data => {
                console.log("nix-switcher:", data);
                if (data.trim() === "done") {
                    gearwheel.fullJsonData = null;
                }
            }
        }
    }
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
                gearwheel.popLevel();   
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
                opacity: (index < gearwheel.startupVisibleSegments) ? (isSelected ? 1.0 : (isValid ? 0.4 : 0.05)) : 0.0
                scale:   (index < gearwheel.startupVisibleSegments) ? (isSelected ? 1.15 : 1.0) : 0.8
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
			color:   isSelected ? (index % 2 === 0 ? Theme.ac1 : Theme.ac2) : Theme.trans
                        visible: isValid && activeItem && activeItem.label !== ""
                        text:    (activeItem && activeItem.label) ? activeItem.label : ""
                    }
                }
            }
        }
        Text {
            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
                bottomMargin: 16
            }
            font { pixelSize: Theme.t1; family: Theme.fnt }
            color: Theme.ac2
            opacity: 0.5
            text: {
                if (gearwheel.navStack.length === 0) return "";
                return gearwheel.navStack.map(l => l.title).join(" › ");
            }
        }

    } 
}
