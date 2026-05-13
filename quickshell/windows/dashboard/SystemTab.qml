import QtQuick
import QtQuick.Layouts
import Quickshell.Io 
import Quickshell.Services.UPower 
import "./../../color"
import "./../../elements"

Item {
    id: systemTab
    
    // === VIM FOCUS LAYER ===
    property bool isFocused: false
    property int selectedIndex: 0

    function handleKey(event) {
        if (event.key === Qt.Key_L || event.key === Qt.Key_Right) {
            selectedIndex = (selectedIndex + 1) % 5; 
            event.accepted = true;
        } else if (event.key === Qt.Key_H || event.key === Qt.Key_Left) {
            selectedIndex = (selectedIndex - 1 + 5) % 5;
            event.accepted = true;
        }
    }

    // === DATEN ===
    property int cpuPct: 0
    property int ramPct: 0
    property string ramText: "Lade..."
    property int diskPct: 0
    property string diskText: "Lade..."
    property int gpuPct: 0      
    property string gpuText: "Lade GPU..."
    
    property int battPct: UPower.displayDevice.ready ? Math.round(UPower.displayDevice.percentage * 100) : 0
    property string battText: UPower.displayDevice.ready 
        ? (UPower.displayDevice.state === 1 ? "Lädt..." : "Entlädt") 
        : "N/A"

    Process {
        id: sysDataProcess
        command: ["bash", "-c", "
            read -r cpu u n s i w x y z extra < /proc/stat
            prev_idle=$i
            prev_total=$((u+n+s+i+w+x+y+z))
            
            sleep 0.5
            
            read -r cpu u n s i w x y z extra < /proc/stat
            total=$((u+n+s+i+w+x+y+z))
            diff_idle=$((i - prev_idle))
            diff_total=$((total - prev_total))
            
            if [ $diff_total -eq 0 ]; then
                cpu_usage=0
            else
                cpu_usage=$((100 * (diff_total - diff_idle) / diff_total))
            fi

            ram=$(free -m | awk '/^Mem:/ {printf \"%.0f\", $3/$2*100}')
            ram_text=$(free -h | awk '/^Mem:/ {printf \"%s\", $3}')
            disk=$(df / | awk 'NR==2 {gsub(/%/, \"\", $5); printf \"%s\", $5}')
            disk_text=$(df -h / | awk 'NR==2 {printf \"%s\", $3}')
            
            gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | awk '{print $1}')
            gpu_text=$(nvidia-smi --query-gpu=name --format=csv,noheader | sed 's/NVIDIA GeForce //g' | sed 's/NVIDIA //g')

            echo \"$cpu_usage|$ram|$ram_text|$disk|$disk_text|$gpu|$gpu_text\"
        "]
        running: dashWindow.visible 
        onExited: sysTimer.start()
        stdout: SplitParser {
            onRead: data => {
                let parts = data.split("|");
                if (parts.length >= 7) {
                    systemTab.cpuPct = parseInt(parts[0]) || 0;
                    systemTab.ramPct = parseInt(parts[1]) || 0;
                    systemTab.ramText = parts[2].trim();
                    systemTab.diskPct = parseInt(parts[3]) || 0;
                    systemTab.diskText = parts[4].trim();
                    systemTab.gpuPct = parseInt(parts[5]) || 0;
                    systemTab.gpuText = parts[6].trim();
                }
            }
        }
    }
    
    Timer { 
        id: sysTimer
        interval: 2000 
        onTriggered: sysDataProcess.running = true 
    }

    // === UI LAYOUT ===
    GridLayout {
        anchors.fill: parent
        columns: 2 
        columnSpacing: Theme.spc2
        rowSpacing: Theme.spc2
        
        // 0: CPU Tacho
        Tacho {
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon: ""
            name: "CPU"
            accentColor: Theme.ac1
            pct: systemTab.cpuPct
            subText: "Auslastung"
            isFocused: systemTab.isFocused && systemTab.selectedIndex === 0
        }

        // 1: GPU Tacho
        Tacho {
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon: "󰢮"
            name: "GPU"
            accentColor: Theme.ac2
            pct: systemTab.gpuPct
            subText: systemTab.gpuText
            isFocused: systemTab.isFocused && systemTab.selectedIndex === 1
        }

        // 2: Batterie (Spannt sich über 2 Spalten als Trenner)
        FillingBar {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.columnSpan: 2 
            icon: "󰁹"
            name: "BATT"
            accentColor: Theme.ac1
            pct: systemTab.battPct
            subText: systemTab.battText
            isFocused: systemTab.isFocused && systemTab.selectedIndex === 2
        }

        // 3: RAM Leiste
        FillingBar {
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon: ""
            name: "RAM"
            accentColor: Theme.ac1
            pct: systemTab.ramPct
            subText: systemTab.ramText
            isFocused: systemTab.isFocused && systemTab.selectedIndex === 3
        }

        // 4: DISK Leiste
        FillingBar {
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon: "󰋊"
            name: "DISK"
            accentColor: Theme.ac2
            pct: systemTab.diskPct
            subText: systemTab.diskText
            isFocused: systemTab.isFocused && systemTab.selectedIndex === 4
        }
    }
}
