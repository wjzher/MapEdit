import QtQuick 2.0

Rectangle {
    id: root;
    implicitHeight: 25;
    implicitWidth: 40;
    property alias text: rectangleText.text;
    property alias color: root.color;
    property alias font: rectangleText.font.pointSize;
    property alias colortext: rectangleText.color;
    color: "#EEEEEE";
    border.color: "lightsteelblue";
    radius: 4;
    Text {
        id: rectangleText
        color: "black";
        font.pointSize: 10;
        anchors.centerIn: parent;
    }
}
