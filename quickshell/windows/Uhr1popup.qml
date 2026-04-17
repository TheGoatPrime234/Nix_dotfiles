import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes 
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "./../color"

PopupWindow {
    id: clockPopup
    property var itemanchor
    visible: false
    
    anchor {
        item: itemanchor
        edges: Edges.Top | Edges.Left 
        margins.top: Theme.h1
    }
    
    // 1. ANPASSUNG: Gesamtbreite erhöht, damit beide Spalten Platz haben
    implicitWidth: 440 
    implicitHeight: 220 
    color: Theme.trans

    property string activeTab: "Timer"
    
    property int timerDuration: 15 * 60 + 30 
    property int timerLeft: timerDuration
    property bool timerRunning: false
    
    property int stopwatchElapsed: 0
    property bool stopwatchRunning: false

    function formatTimerText(secs) {
        var h = Math.floor(secs / 3600)
        var m = Math.floor((secs % 3600) / 60)
        var s = Math.floor(secs % 60)
        if (h > 0) return h + "h " + m + "m " + s + "s"
        if (m > 0) return m + "m " + s + "s"
        return s + "s"
    }

    function formatStopwatchText(secs) {
        var m = Math.floor(secs / 60)
        var s = Math.floor(secs % 60)
        return m + ":" + (s < 10 ? "0" + s : s)
    }

    Rectangle {
        id: popupBg
        anchors.fill: parent
        border {
            width: 1
            color: Theme.ac1
        }
        radius: Theme.rad
        color: Theme.bg0

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.spc1
            spacing: Theme.spc1

            // ==========================================
            // LINKE SEITE: TAB-NAVIGATION
            // ==========================================
            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                // 2. ANPASSUNG: Feste Mindestbreite, damit "Bildschirmzeit" sauber reinpasst
                Layout.preferredWidth: 150 
                Layout.minimumWidth: 150
                spacing: Theme.spc2

                Repeater {
                    model: [
                        { name: "Timer", active: true },
                        { name: "Stoppuhr", active: true },
                        { name: "Bildschirmzeit", active: false },
                        { name: "Zeit", active: false }
                    ]
                    
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 32
                        radius: Theme.rad
                        
                        color: clockPopup.activeTab === modelData.name 
                               ? Theme.ac1 
                               : (modelData.active ? Theme.bg1 : Theme.bg0)
                               
                        border {
                            width: 1
                            color: clockPopup.activeTab === modelData.name ? Theme.ac1 : Theme.bg2
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.name
                            font {
                                pixelSize: Theme.t2
                                family: Theme.fnt
                                bold: clockPopup.activeTab === modelData.name
                            }
                            color: clockPopup.activeTab === modelData.name 
                                   ? Theme.bg0 
                                   : (modelData.active ? Theme.ac1 : Theme.bg2)
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: modelData.active
                            cursorShape: modelData.active ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: {
                                clockPopup.activeTab = modelData.name
                            }
                        }
                    }
                }
                
                Item { Layout.fillHeight: true }
            }

            // ==========================================
            // RECHTE SEITE: HAUPTINHALT
            // ==========================================
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 160 
                radius: Theme.rad
                color: Theme.bg1
                border { width: 1; color: Theme.bg2 }

                // Hilfsfunktion zum Parsen der Eingabe (MM:SS oder Sekunden)
                function setTimerFromInput(input) {
                    var parts = input.split(':');
                    var totalSeconds = 0;
                    if (parts.length === 2) {
                        totalSeconds = parseInt(parts[0]) * 60 + parseInt(parts[1]);
                    } else {
                        totalSeconds = parseInt(parts[0]);
                    }
                    
                    if (!isNaN(totalSeconds) && totalSeconds > 0) {
                        clockPopup.timerDuration = totalSeconds;
                        clockPopup.timerLeft = totalSeconds;
                        clockPopup.timerRunning = false;
                    }
                }

                // --- TIMER ANSICHT ---
                Item {
                    anchors.fill: parent
                    visible: clockPopup.activeTab === "Timer"

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Theme.spc2

                        // Der Kreis-Bereich
                        Item {
                            Layout.preferredWidth: 140
                            Layout.preferredHeight: 140

                            Shape {
                                id: timerShape
                                anchors.fill: parent
                                
                                ShapePath {
                                    fillColor: "transparent"
                                    strokeColor: Theme.bg2
                                    strokeWidth: 8
                                    capStyle: ShapePath.RoundCap
                                    PathAngleArc {
                                        centerX: 70; centerY: 70
                                        radiusX: 66; radiusY: 66
                                        startAngle: 0
                                        sweepAngle: 360
                                    }
                                }
                                
                                ShapePath {
                                    fillColor: "transparent"
                                    strokeColor: Theme.ac1
                                    strokeWidth: 8
                                    capStyle: ShapePath.RoundCap
                                    PathAngleArc {
                                        centerX: 70; centerY: 70
                                        radiusX: 66; radiusY: 66
                                        startAngle: -90
                                        sweepAngle: (clockPopup.timerLeft / clockPopup.timerDuration) * 360
                                    }
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: clockPopup.formatTimerText(clockPopup.timerLeft)
                                color: Theme.ac1
                                font {
                                    pixelSize: Theme.t1 + 2
                                    family: Theme.fnt
                                    bold: true
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                cursorShape: Qt.PointingHandCursor
                                onClicked: (mouse) => {
                                    if (mouse.button === Qt.LeftButton) {
                                        clockPopup.timerRunning = !clockPopup.timerRunning
                                    } else if (mouse.button === Qt.RightButton) {
                                        clockPopup.timerRunning = false
                                        clockPopup.timerLeft = clockPopup.timerDuration
                                    }
                                }
                            }
                        }

                        // --- NEU: Eingabefeld für die Zeit ---
                        Rectangle {
                            Layout.alignment: Qt.AlignHCenter
                            implicitWidth: 100
                            implicitHeight: 28
                            color: Theme.bg0
                            radius: Theme.rad / 2
                            border { 
                                width: 1
                                color: timeInput.activeFocus ? Theme.ac1 : Theme.bg2 
                            }

                            TextInput {
                                id: timeInput
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                color: Theme.ac1
                                font { family: Theme.fnt; pixelSize: Theme.t2 }
                                text: "15:30" // Standardanzeige
                                selectByMouse: true
                                
                                // Bei Enter wird die Zeit gesetzt
                                onAccepted: {
                                    parent.parent.parent.setTimerFromInput(text);
                                    focus = false; // Fokus verlieren nach Eingabe
                                }
                            }
                        }
                        
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "Zeit setzen (Enter)"
                            color: Theme.bg3
                            font { family: Theme.fnt; pixelSize: Theme.t4 }
                        }
                    }
                }
                // --- STOPPUHR ANSICHT ---
                Item {
                    anchors.fill: parent
                    visible: clockPopup.activeTab === "Stoppuhr"

                    Shape {
                        width: 140; height: 140
                        anchors.centerIn: parent
                        
                        ShapePath {
                            fillColor: "transparent"
                            strokeColor: clockPopup.stopwatchRunning ? Theme.ac1 : Theme.bg2
                            strokeWidth: 4
                            dashPattern: [10, 10] 
                            PathAngleArc {
                                centerX: 70; centerY: 70
                                radiusX: 66; radiusY: 66
                                startAngle: 0
                                sweepAngle: 360
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: clockPopup.formatStopwatchText(clockPopup.stopwatchElapsed)
                        color: clockPopup.stopwatchRunning ? Theme.ac1 : Theme.bg3
                        font {
                            pixelSize: Theme.t1 + 6
                            family: Theme.fnt
                            bold: true
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        cursorShape: Qt.PointingHandCursor
                        onClicked: (mouse) => {
                            if (mouse.button === Qt.LeftButton) {
                                clockPopup.stopwatchRunning = !clockPopup.stopwatchRunning
                            } else if (mouse.button === Qt.RightButton) {
                                clockPopup.stopwatchRunning = false
                                clockPopup.stopwatchElapsed = 0
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000 
        running: true 
        repeat: true
        onTriggered: {
            if (clockPopup.timerRunning) {
                if (clockPopup.timerLeft > 0) {
                    clockPopup.timerLeft--
                } else {
                    clockPopup.timerRunning = false 
                }
            }

            if (clockPopup.stopwatchRunning) {
                clockPopup.stopwatchElapsed++
            }
        }
    }
}
