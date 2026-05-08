pragma Singleton
import QtQuick

Item {
    id: root
    property bool dashboardVisible: false
    property int currentMenuLevel: 0 

    function toggle() {
        if (dashboardVisible) {
            close();
        } else {
            dashboardVisible = true;
            currentMenuLevel = 0; 
        }
    }
    
    function close() {
        dashboardVisible = false;
        currentMenuLevel = 0;
    }
}
