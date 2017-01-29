import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    visible: true
    width: 800;
    height: 480;
    id: rootItem;
    color: "#EEEEEE";
    title: qsTr("Hello World")

    ListView {
        anchors.fill: parent
        anchors.margins: 20
        clip: true
        model: 10
        delegate: numberDelegate
        spacing: 1
        focus: true;
    }

    Component {
        id: numberDelegate
        Rectangle {
            id: wrapper;
            width: 40
            height: 40
            color: "lightGreen";
            border.color: "black";
            border.width: wrapper.ListView.isCurrentItem ? 1 : 0;
            Text {
                anchors.centerIn: parent
                font.pixelSize: 10
                text: index
            }
        }
    }
}
