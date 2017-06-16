import QtQuick 2.5
import Qt.MapItemType 1.0

Rectangle {
    id: root;
    property int rows: 5;
    property int columns: 5;
    property int numberMargins: 0;
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
    onColumnsChanged: {
        agvUpdateAll();
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
//        onCellWidthChanged: {
//            console.log("cell width changed");
//            agvUpdateAll();
//        }
        onCellHeightChanged: agvUpdateAll();
//        onXChanged: agvUpdateAll();
//        onYChanged: agvUpdateAll();
//        onWidthChanged: agvUpdateAll();
//        onHeightChanged: agvUpdateAll();
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
            border.color: wrapper.GridView.isCurrentItem ? "royalblue" : "white";
            border.width: wrapper.GridView.isCurrentItem ? 2 : 1;
            text: index;
            onClicked: {
                console.log("wrapper " + index + " clicked.");
                wrapper.GridView.view.currentIndex = index;
                wrapper.GridView.view.focus = index;
            }
        }
    }
    Component.onCompleted: {
        if (agvComponent == null) {
            agvComponent = Qt.createComponent("AgvModel.qml");
            if (agvComponent.status != Component.Ready) {
                console.log("Warning: agv Componet not ready");
            }
        }
    }

    function addAgvModel(addr) {
        var agv;
        if (agvComponent.status == Component.Ready) {
            // createObject时赋值x: mapGrid.x + ((gridIndex % columns) * mapGrid.cellWidth) - width / 2 + gridX
            // 报错gridIndex找不到，采用简单赋值可以
            agv = agvComponent.createObject(mapGrid, {
                "x": 0,
                "y": 0,
                "visible": false,
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
    function showAgvModel(addr) {
        var i = searchAgvModel(addr);
        if (i == -1) {
            return;
        }
        agvModels[i].text = addr;
        agvModels[i].visible = true;
    }
    function hideAgvModel(addr) {
        var i = searchAgvModel(addr);
        if (i == -1) {
            return;
        }
        agvModels[i].visible = false;
    }
    function agvModelIsShow(addr) {
        var i = searchAgvModel(addr);
        if (i == -1) {
            return false;
        }
        return agvModels[i].visible;
    }
    function agvModel(addr) {
        var i = searchAgvModel(addr);
        if (i == -1) {
            return false;
        }
        console.log("agvModel test...")
        return agvModels[i].getMapItemType();
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
            console.log("searchAgvModel: can not find " + addr);
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
    function agvUpdate(i) {
        var agv = agvModels[i];
        var ix = agv.gridIndex % columns;
        var iy = parseInt(agv.gridIndex / columns);
        // agv model 存在scale时的计算方法
        // 在scale = 1情况下计算agv中心点的坐标
        // 将agv的中心点进行scale缩放
        // 由agv的中心点找到左上角的点，此时要用rect.width进行偏移
        // 原因是agv的缩放是由系统完成，而非程序计算得到
        console.log("agvUpdate (" + agv.gridIndex + "): ix = " + ix + ", iy = " + iy);
        agv.x = ix * root.gridLength + agv.gridX;
        agv.x *= agv.scale;
        agv.x -= agv.width / 2;
        agv.y = iy * root.gridLength + agv.gridY;
        agv.y *= agv.scale;
        agv.y -= agv.height / 2;
        console.log("agv update: col " + columns + " w " + mapGrid.cellWidth + " gridx " + agv.gridX + " agv.x " + agv.x);
        console.log("idx " + agv.gridIndex + " agv.y " + agv.y + " agv.width " + agv.width + " agv.height " + agv.height);
        console.log("agv scale: " + agv.scale);
    }
    function agvUpdateAll() {
        var i;
        for (i = 0; i < agvModels.length; i++) {
            agvModels[i].scale = scaleGrid;
            agvUpdate(i);
        }
    }
    function agvUpdateStatus(addr, s) {
        var i = searchAgvModel(addr);
        if (i == -1) {
            return;
        }
        agvModels[i].agvStatus = s;
        //console.log("agvUpdateStatus: " + addr + ", " + s);
    }

    function setAgvModel(addr, index, x, y, r) {
        var i = searchAgvModel(addr);
        if (i == -1) {
            return;
        }
        var agv = agvModels[i];
        agv.agvSetPosition(index, x, y, r);
        agvUpdate(i);
    }

    function agvTestGetMagCurve(addr, act, turn) {
        var i = searchAgvModel(addr);
        if (i == -1) {
            return;
        }
        var agv = agvModels[i];
        agv.getMagCurve(act, turn);
    }
    function agvTestGetCross(addr, act, turn) {
        var i = searchAgvModel(addr);
        if (i == -1) {
            return;
        }
        var agv = agvModels[i];
        agv.crossTestLine(act, turn);
    }
}
