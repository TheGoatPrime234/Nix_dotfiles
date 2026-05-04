pragma Singleton
import QtQuick

Item {
    property bool active: false
    property string text: ""
    function trigger(newText) {
        text = newText;
        active = true;
        islandTimer.restart(); 
    }

    Timer {
        id: islandTimer
        interval: 5000
        onTriggered: {
            active = false; 
            console.log("DYNAMIC ISLAND SCHLIESST SICH");
        }
    }
}
