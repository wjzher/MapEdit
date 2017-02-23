import QtQuick 2.7
import QtQuick.Window 2.2

QtObject {
    property real defaultSpacing: 10
    property SystemPalette palette: SystemPalette { }
    property alias pathList: mapWindow.pathList;
    property alias mapGrid: mapWindow.mapGrid;
    property alias udpServer: agvDialog.udpServer;

    property var mapWindow: MapEditWindow {
        id: mapWindow;
        visible: true;
        onClosing: {
            agvDialog.close();
        }
    }

    property var agvControlWindow: AgvDialog {
        id: agvDialog;
    }
}
