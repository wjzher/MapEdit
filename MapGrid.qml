import QtQuick 2.5
import Qt.MapItemType 1.0

Rectangle {
    id: root;
    property int rows: 5;
    property int columns: 5;
    property int numberMargins: 1;
    property int gridLength: 50;
    property real scaleGrid: 1.0;
    property alias mapGrid: mapGrid;
    signal currentIndexChanged;
    property Component agvComponent: null;
    property var agvModels: [];
    property var agvAddrs: [];
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
        width: columns * cellWidth;
        height: rows * cellHeight;
        anchors.margins: 0;

        clip: true;
        model: (rows * columns);
        delegate: numberDelegate
        cellHeight: (gridLength + numberMargins) * root.scaleGrid;
        cellWidth: (gridLength + numberMargins) * root.scaleGrid;
        focus: true;
        Component.onCompleted: {
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
                return;
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
            width: gridLength * root.scaleGrid;
            height: gridLength * root.scaleGrid;
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
    function addAgvModel(addr) {
        if (agvComponent == null) {
            agvComponent = Qt.createComponent("AgvModel.qml");
        }
        var agv;
        if (agvComponent.status == Component.Ready) {
            // createObject时赋值x: mapGrid.x + ((gridIndex % columns) * mapGrid.cellWidth) - width / 2 + gridX
            // 报错gridIndex找不到，采用简单赋值可以
            agv = agvComponent.createObject(mapGrid, {
                "x": mapGrid.x,
                "y": mapGrid.y,
                "scale": root.scaleGrid
                });
            if (agv == null) {
                // Error
                console.log("create agv object error");
                return;
            }
            agvModels.push(agv);
            agvAddrs.push(addr);
            console.log("add agv model: " + agvModels);
            console.log("add agv model: " + agvAddrs);
        }
    }
    function delListItem(list, i) {
        var newList = [];
        var j;
        for (j = 0; j < list.length; j++) {
            if (j == i) {
                continue;
            }
            newList.push(list[j]);
        }
        return newList;
    }
    function searchAgvModel(addr) {
        var i;
        for (i = 0; i < agvAddrs.length; i++) {
            if (agvAddrs[i] == addr) {
                break;
            }
        }
        if (i == agvAddrs.length) {
            console.log("del Agv Model: can not find " + addr);
            return -1;
        }
        return i;
    }
    function delAgvModel(addr) {
        var i = searchAgvModel(addr);
        if (i == -1) {
            return;
        }
        agvModels[i].destroy();
        agvAddrs = delListItem(agvAddrs, i);
        agvModels = delListItem(agvModels, i);
        console.log("del agv model: " + agvModels);
        console.log("del agv model: " + agvAddrs);
    }
    function setAgvModel(addr, index, x, y, r) {
        var i = searchAgvModel(addr);
        if (i == -1) {
            return;
        }
        var agv = agvModels[i];
        agv.agvSetPosition(index, x, y, r);
    }
}
