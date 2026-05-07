pragma Singleton
import QtQuick
import Quickshell.Services.Notifications

Item {
    id: globalNotifRoot
    property alias trackedNotifications: server.trackedNotifications
    property bool bootFinished: false
    
    // States für das Notification Center
    property bool centerVisible: false
    
    // States für die Dynamic Island
    property bool active: false
    property string text: ""
    property string appName: "" 

    // Zentrale Icon-Logik für alle Widgets
    function getAppIcon(name) {
        if (!name) return "";
        var n = name.toLowerCase();
        if (n.includes("spotify")) return "";
        if (n.includes("discord") || n.includes("vesktop")) return "";
        if (n.includes("firefox") || n.includes("browser")) return "";
        if (n.includes("rebuild") || n.includes("nix")) return "󱄅";
        return "";
    }

    function toggleCenter() {
        centerVisible = !centerVisible;
    }

    function trigger(newText, newAppName) {
        text = newText;
        appName = newAppName;
        active = true;
        islandTimer.restart(); 
    }

    function close() {
        active = false;
        islandTimer.stop(); 
    }

    Timer { id: islandTimer; interval: 3000; onTriggered: active = false }

    Timer {
        interval: 800
        running: true
        onTriggered: globalNotifRoot.bootFinished = true
    }

    NotificationServer {
        id: server
        onNotification: notification => {
            notification.tracked = true
            if (globalNotifRoot.bootFinished) {
                globalNotifRoot.trigger(notification.summary, notification.appName)
            }
        }
    }
}
