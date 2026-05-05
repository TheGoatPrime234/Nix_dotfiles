pragma Singleton
import QtQuick

Item {
    property bool active: false
    property string text: ""
    property string appName: "" 
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
    Timer {
        id: islandTimer
        interval: 3000
        onTriggered: {
            active = false; 
        }
    }
}
