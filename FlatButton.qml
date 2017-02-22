import QtQuick 2.2
import QtQuick.Controls 2.0

Rectangle {
    id: bkgnd;
    implicitWidth: 35;
    implicitHeight: 30;
    color: "transparent";
    property alias iconSource: icon.source;
    property alias iconWidth: icon.width;
    property alias iconHeight: icon.height;
    property alias textColor: btnText.color;
    property alias font: btnText.font;
    property alias text: btnText.text;
    property alias toolTipText: toolTip.text;
    radius: 4;
    property bool hovered: false;
    border.color: "lightsteelblue";
    border.width: hovered ? 2 : 1;
    signal clicked;

    ToolTip {
        id: toolTip;
        visible: hovered;
        delay: 500;
        timeout: 2500;
    }
    Image {
        id: icon;
        anchors.left: parent.left;
        anchors.verticalCenter: parent.verticalCenter;
    }
    Text {
        id: btnText;
        anchors.left: icon.right;
        anchors.centerIn: parent;
        anchors.verticalCenter: icon.verticalCenter;
        anchors.margins: 4;
        font.pointSize: 18;
        color: ma.pressed ? "blue" : (parent.hovered ? "#0000a0" : "deeppink");
    }
    MouseArea {
        id: ma;
        anchors.fill: parent;
        hoverEnabled: true;
        onEntered: {
            bkgnd.hovered = true;
        }
        onExited: {
            bkgnd.hovered = false;
        }
        onClicked: {
            bkgnd.hovered = false;
            bkgnd.clicked();
        }
    }
}

