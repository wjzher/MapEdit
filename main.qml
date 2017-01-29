import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    visible: true
    width: 360;
    height: 240;
    id: rootItem;
    color: "#EEEEEE";
    title: qsTr("Hello World")

    Text {
        id: centerText;
        text: "QT Quick.";
        anchors.centerIn: parent;
        font.pixelSize: 24;
        font.bold: true;
    }

    function setTextColor(clr) {
        centerText.color = clr;
    }

    Grid {
        id: colorGrid;
        anchors.left: parent.left;
        anchors.leftMargin: 4;
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 4;
        rows: 3;
        columns: 3;
        rowSpacing: 4;
        columnSpacing: 4;

        ColorPicker {
            color: Qt.rgba(Math.random(), Math.random(),
                           Math.random(), 1.0);
            onColorPicked: setTextColor(clr);
        }
        ColorPicker {
            color: Qt.rgba(Math.random(), Math.random(),
                           Math.random(), 1.0);
            onColorPicked: setTextColor(clr);
        }
        ColorPicker {
            color: Qt.rgba(Math.random(), Math.random(),
                           Math.random(), 1.0);
            onColorPicked: setTextColor(clr);
        }
        ColorPicker {
            color: Qt.rgba(Math.random(), Math.random(),
                           Math.random(), 1.0);
            onColorPicked: setTextColor(clr);
        }
        ColorPicker {
            color: Qt.rgba(Math.random(), Math.random(),
                           Math.random(), 1.0);
            onColorPicked: setTextColor(clr);
        }
        ColorPicker {
            color: Qt.rgba(Math.random(), Math.random(),
                           Math.random(), 1.0);
            onColorPicked: setTextColor(clr);
        }
        ColorPicker {
            color: Qt.rgba(Math.random(), Math.random(),
                           Math.random(), 1.0);
            onColorPicked: setTextColor(clr);
        }
    }
    Button {
        anchors.left: parent.left;
        anchors.leftMargin: 4;
        anchors.top: parent.top;
        anchors.topMargin: 4;
        text: "Add";
        onClicked: {
            console.log("Button clicked.");

        }
    }
}
