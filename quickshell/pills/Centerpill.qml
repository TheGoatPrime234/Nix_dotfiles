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
    
    function getAppIcon(name) {
        var n = name.toLowerCase();
        if (n.includes("spotify")) return "";
        if (n.includes("discord") || n.includes("vesktop")) return ""; 
        if (n.includes("firefox") || n.includes("browser")) return "";
        if (n.includes("rebuild") || n.includes("nix")) return "󱄅";
        return "";
    }

    implicitHeight: Theme.h2
    radius: Theme.rad
    border {
        width: 1
        color: Theme.bg2
    }
    color: Theme.bg0

    // ==========================================
    // DIE STATE-MACHINE (Verhindert JEDES Überlappen!)
    // ==========================================
    states: [
        State {
            name: "normal"
            when: !centerPillRoot.islandActive
            // Uhren sind an, Text ist aus
            PropertyChanges { target: cpill; opacity: 1.0; visible: true }
            PropertyChanges { target: islandContent; opacity: 0.0; visible: false }
            PropertyChanges { target: centerPillRoot; implicitWidth: cpill.implicitWidth + Theme.impW }
        },
        State {
            name: "island"
            when: centerPillRoot.islandActive
            // Text ist an, Uhren sind KOMPLETT abgeschaltet (kein Überlappen möglich)
            PropertyChanges { target: cpill; opacity: 0.0; visible: false }
            PropertyChanges { target: islandContent; opacity: 1.0; visible: true }
            PropertyChanges { target: centerPillRoot; implicitWidth: Math.max(300, islandTextItem.implicitWidth + 80) }
        }
    ]

    transitions: [
        // Choreografie beim Öffnen der Benachrichtigung
        Transition {
            from: "normal"
            to: "island"
            SequentialAnimation {
                // 1. Uhren sanft ausblenden und danach SOFORT abschalten
                NumberAnimation { target: cpill; property: "opacity"; duration: 150 }
                PropertyAction { target: cpill; property: "visible"; value: false }

                // 2. Deine gewünschten 0,3 Sekunden (300ms) warten!
                PauseAnimation { duration: 300 }

                // 3. Pille zieht sich in die Breite
                NumberAnimation { target: centerPillRoot; property: "implicitWidth"; duration: 500; easing.type: Easing.OutExpo }

                // 4. Text einschalten und einblenden
                PropertyAction { target: islandContent; property: "visible"; value: true }
                NumberAnimation { target: islandContent; property: "opacity"; duration: 150 }
            }
        },
        // Choreografie beim Schließen der Benachrichtigung
        Transition {
            from: "island"
            to: "normal"
            SequentialAnimation {
                // 1. Text ausblenden und abschalten
                NumberAnimation { target: islandContent; property: "opacity"; duration: 150 }
                PropertyAction { target: islandContent; property: "visible"; value: false }

                // 2. Pille schrumpft wieder
                NumberAnimation { target: centerPillRoot; property: "implicitWidth"; duration: 500; easing.type: Easing.OutExpo }

                // 3. Uhren einschalten und wieder einblenden
                PropertyAction { target: cpill; property: "visible"; value: true }
                NumberAnimation { target: cpill; property: "opacity"; duration: 150 }
            }
        }
    ]

    // ==========================================
    // LAYER 1: Uhren
    // ==========================================
    Row {
        id: cpill
        anchors {
            centerIn: parent
            margins: Theme.outmrg
            verticalCenter: parent.verticalCenter
        }
        spacing: Theme.spc2
        
        Uhr1 {}
        Iusenixosbtw {}
        Uhr2 {}
    }

    // ==========================================
    // LAYER 2: Benachrichtigung
    // ==========================================
    Item {
        id: islandContent
        anchors.fill: parent
        anchors.centerIn: parent
        clip: true
        
        RowLayout {
            anchors.fill: parent
            spacing: Theme.spc2
            Text {
                text: centerPillRoot.getAppIcon(centerPillRoot.islandAppName)
                font.family: Theme.fnt
                font.pixelSize: Theme.t1 + 4
                color: Theme.ac1
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: (Theme.rad / 2)
            }
            Text {
                id: islandTextItem
                text: centerPillRoot.islandText
                font.family: Theme.fnt
                font.pixelSize: Theme.t1
                font.bold: true
                color: "#ffffff"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                Layout.rightMargin: (Theme.rad / 2) // Bonus: Symmetrischer Abstand nach rechts
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        enabled: centerPillRoot.islandActive
        onClicked: {
            IslandState.close();
        }
    }
}
