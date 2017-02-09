import QtQuick 2.5
import Qt.MapItemType 1.0

Rectangle {
    id: root;
    property int rows: 5;
    property int columns: 5;
    property int numberMargins: 1;
    property int gridWidth: (width > height) ? width : height;
    property int cellW: ((gridWidth) / columns);
    property int cellH: ((gridWidth) / rows);
    property real scaleGrid: 1.0;
    property alias mapGrid: mapGrid;
    signal currentIndexChanged;
    clip: true;
    MouseArea {
        anchors.fill: parent;
        onWheel: {
//            console.log("Wheel " + wheel.angleDelta.y + " " + wheel.angleDelta.x);
            if (wheel.angleDelta.y > 0) {
                root.scaleGrid += 0.2;
                if (root.scaleGrid >= 4) {
                    root.scaleGrid = 4;
                }
            } else if (wheel.angleDelta.y < 0) {
                root.scaleGrid -= 0.2;
                if (root.scaleGrid <= 0) {
                    root.scaleGrid = 0.2;
                }
            }
        }
    }
    GridView {
        id: mapGrid;
        width: root.gridWidth * root.scaleGrid;
        height: root.gridWidth * root.scaleGrid;
        anchors.margins: 0;
        //        anchors.centerIn: parent;

        clip: true
        model: (rows * columns);
        delegate: numberDelegate
        cellHeight: root.cellW * root.scaleGrid;
        cellWidth: root.cellH * root.scaleGrid;
        focus: true;
        Component.onCompleted: {
//            console.log("w = ", root.width, " h = ", root.height);
//            console.log("cw = " + root.cellW, " ch = ", root.cellH);
        }
        MouseArea {
            id: gridMa;
            anchors.fill: parent;
            drag.target: mapGrid;      // drag mapGrid
            drag.axis: Drag.XAndYAxis;
            acceptedButtons: Qt.RightButton;    // right button is valid
            onPressed: {
                parent.focus = true;
            }
            onReleased: {
                var view = root;
//                console.log("realse ", parent.x + " " + parent.y);
//                console.log("parent ", parent.width + " " + parent.height);
//                console.log("view ", view.width + " " + view.height);
                var x = parent.x, y = parent.y;
                if (x > 2) {
                    parent.x = 2;
                }
                if (y > 2) {
                    parent.y = 2;
                }
                x += parent.width - view.width;
                if (x < -2) {
                    parent.x = view.width - parent.width - 2;
                }
                y += parent.height - view.height;
                if (y < -2) {
                    parent.y = view.height - parent.height - 2;
                }
            }
        }
        onCurrentIndexChanged: {
            root.currentIndexChanged();
        }
    }
    Component {
        id: numberDelegate;
        MapItem {
            id: wrapper;
            type: MapItemType.MapItemNULL;
            width: (root.cellW - numberMargins) * root.scaleGrid;
            height: (root.cellH - numberMargins) * root.scaleGrid;
            color: "aquamarine";
            border.color: "royalblue";
            border.width: wrapper.GridView.isCurrentItem ? 2 : 0;
            text: index;
            onClicked: {
                console.log("wrapper " + index + " clicked.");
                wrapper.GridView.view.currentIndex = index;
                wrapper.GridView.view.focus = index;
            }
        }
    }
}
