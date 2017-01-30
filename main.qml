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
    PathGrid {
        anchors.centerIn: parent;
        width: 600;
        height: 600;
        rows: 20;
        columns: 20;
        scaleGrid: 1.5;
    }
}
