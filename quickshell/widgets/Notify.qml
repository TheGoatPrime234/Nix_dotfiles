import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.Notifications
import "./../color"

Rectangle { // Notify Widget Root
    id: notifyWidgetroot
    anchors.verticalCenter: parent.verticalCenter
    implicitHeight: Theme.h3
    implicitWidth: notifyWidgettext.implicitWidth + (Theme.impW * 2)
    border {
        width: 1
        color: Theme.bg2
    }
    radius: Theme.rad
    color: Theme.bg1
    //
    Text { //Notify Bell
        id: notifyWidgettext
        anchors.centerIn: parent
        font {
            pixelSize: Theme.t1
            bold: true
            family: Theme.fnt
        }
        color: Theme.ac1
        text: ""
    }
    //
    MouseArea { // NotifypopupButton
        id: notifyWidgetbutton
        anchors.fill: parent
        onClicked: notifyPopupwind.visible = !notifyPopupwind.visible
    }
    property bool bootFinished: false
    Timer {
        interval: 800
        running: true
        onTriggered: notifyWidgetroot.bootFinished = true
    }
}
