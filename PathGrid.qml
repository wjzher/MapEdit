import QtQuick 2.7
import QtQuick.Controls 2.0

Rectangle {
    id: root;
    property int rows: 5;
    property int columns: 5;
    property int numberMargins: 2;
    property int cellW: ((width + numberMargins) / columns);
    property int cellH: ((height + numberMargins) / rows);
    property real scaleGrid: 1.0;
    clip: true;
    MouseArea {
        anchors.fill: parent;
        onWheel: {
            console.log("Wheel " + wheel.angleDelta.y + " " + wheel.angleDelta.x);
            if (wheel.angleDelta.y > 0) {
                root.scaleGrid += 0.1;
            } else if (wheel.angleDelta.y < 0) {
                root.scaleGrid -= 0.1;
            }
        }
    }
    GridView {
        id: pathGrid;
        width: root.width * root.scaleGrid;
        height: root.height * root.scaleGrid;
        anchors.margins: 0;
        //        anchors.centerIn: parent;

        clip: true
        model: (rows * columns);
        delegate: numberDelegate
        cellHeight: root.cellW * root.scaleGrid;
        cellWidth: root.cellH * root.scaleGrid;
        focus: true;
        Component.onCompleted: {
            console.log("w = ", root.width, " h = ", root.height);
            console.log("cw = " + root.cellW, " ch = ", root.cellH);
        }
        MouseArea {
            id: gridMa;
            anchors.fill: parent;
            drag.target: pathGrid;      // drag path Grid
            drag.axis: Drag.XAndYAxis;
            acceptedButtons: Qt.RightButton;    // right button is valid
        }
    }
    Component {
        id: numberDelegate;
        Rectangle {
            id: wrapper;
            width: (root.cellW - numberMargins) * root.scaleGrid;
            height: (root.cellH - numberMargins) * root.scaleGrid;
            color: "lightGreen";
            border.color: "black";
            border.width: wrapper.GridView.isCurrentItem ? 2 : 0;
            Text {
                anchors.centerIn: parent;
                font.pixelSize: 10;
                text: index;
            }
            MouseArea {
                id: wrapperMa;
                anchors.fill: parent;
                onClicked: {
                    console.log("wrapperMa " + index + " clicked.");
                }
            }
        }
    }
}
