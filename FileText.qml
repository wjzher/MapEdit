import QtQuick 2.0

Text {
    id: root;
    text: "";

    Rectangle {
        id: textRect;
        anchors.fill: parent;
        anchors.margins: -2;
        border.width: 1;
        border.color: "black";
        color: "transparent";
    }
}
