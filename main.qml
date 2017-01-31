import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    visible: true
    width: 800;
    height: 800;
    id: rootItem;
    color: "#EEEEEE";
    title: qsTr("Hello World")

    onWidthChanged: {
    }
    LineItem {
        width: 40;
        height: 24;
        anchors.left: parent.left;
        anchors.top: parent.top;
        anchors.margins: 4;
    }
    MapGrid {
        width: 600;
        height: 600;
        anchors.centerIn: parent;
        rows: 20;
        columns: 20;
        scaleGrid: 1.5;
    }

}
