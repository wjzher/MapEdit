import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Qt.MapItemType 1.0
import QtQuick.Layouts 1.1
import Qt.MapData 1.0
import QtQuick.Dialogs 1.2
import Qt.UdpServer 1.0

Window {
    visible: true;
    minimumHeight: 600;
    minimumWidth: 800;
    width: 900;
    height: 640;
    id: rootItem;
    color: "#EEEEEE";
    title: qsTr("华创求实--AGV地图运行仿真系统");
    property alias pathList: pathList;
    property alias mapGrid: mapGrid;

    UpdateCardIdDialog {
        id: updateCardIdDialog;
        visible: false;
    }

    FileDialog {
        id: fileDialog;
        title: "Please choose a file";
        nameFilters: ["Image Files (*.map)"];
        property int opt: 0;    // 0 new, 1 open, 2 save
        function saveMap() {
            console.log("map file save. " + mapFilePath.text);
            var i;
            var n = mapGrid.rows * mapGrid.columns;
            for (i = 0; i < n; i++) {
                var item = mapGrid.itemAt(i);
                mapData.setItemType(i, item.type);
                mapData.setItemCardId(i, item.isCard, item.cardID);
                mapData.setItemCardPos(i, item.cardPos);
                mapData.setItemArc(i, item.isArc, item.neighbourPos);
                mapData.setItemIsNeighbour(i, item.isNeighbour);
                mapData.setItemCutLeftUp(i, item.cutLeftUp);
                mapData.setItemCutRightDown(i, item.cutRightDown);
            }
            console.log("save Map Data.");
            mapData.saveMapData(mapFilePath.text);
        }
        function mapDataToMapGrid() {
            var i;
            var n = mapGrid.rows * mapGrid.columns;
            for (i = 0; i < n; i++) {
                var item = mapGrid.itemAt(i);
                item.type = mapData.getItemType(i);
                item.isCard = mapData.getItemIsCard(i);
                item.cardPos = mapData.getItemCardPos(i);
                item.cardID = mapData.getItemCardId(i);
                item.isArc = mapData.getItemIsArc(i);
                item.isNeighbour = mapData.getItemIsNeighbour(i);
                item.cutLeftUp = mapData.getItemCutLeftUp(i);
                item.cutRightDown = mapData.getItemCutRightDown(i)
                if (item.isArc != MapItemType.ArcNULL && item.isNeighbour == false) {
                    mapGrid.updateItemArc(i, item, item.isArc);
                }
                item.agvIpText = "";
                if (item.isCard == true) {
                    var ip = udpServer.getAgvIpByCardId(item.cardID);
                    mapGrid.updateAgvCardId(ip, -1, item.cardID);
                }
            }
        }

        function clearMap() {
            console.log("clear Map.");
            mapData.initItems();
            mapDataToMapGrid();
            mapGrid.showItemSettings();
        }

        onAccepted: {
            var file = new String(fileDialog.fileUrl);
            //remove file:///
            if (Qt.platform.os == "windows"){
                file = file.slice(8);
            } else {
                file = file.slice(7);
            }
            mapFilePath.text = file;
            if (opt == 1) {
                console.log("map file open. " + file);
                mapData.loadMapData(file);
                mapDataToMapGrid();
                mapGrid.showItemSettings();
            } else if (opt == 2) {
                saveMap();
            }/* else if (opt == 0) {
                clearMap();
            }*/
        }
    }
    MapData {
        id: mapData;
        onRowsChanged: {
            console.log("rows change " + rows);
            mapGrid.rows = rows;
        }
        onColsChanged: {
            console.log("cols change " + cols);
            mapGrid.columns = cols;
        }
    }

    Component {
        id: radioStyle;
        RadioButtonStyle {
            indicator: Rectangle {
                implicitWidth: 16;
                implicitHeight: 16;
                radius: 8;
                border.color: control.hovered ? "darkblue" : "gray";
                border.width: 1;
                Rectangle {
                    anchors.fill: parent;
                    visible: control.checked;
                    color: "#0000A0";
                    radius: 5;
                    anchors.margins: 3;
                }
            }
            label: Text {
                color: control.activeFocus ? "blue" : "black";
                text: control.text;
            }
        }
    }

    Row {
        id: row;
        anchors.fill: parent;
        anchors.margins: 8;
        spacing: 4;
        MapGrid {
            id: mapGrid;
            width: row.width - mapItemSettingsGroup.width - row.spacing;
            height: row.height - 12;
            rows: 15;
            columns: 20;
            scaleGrid: 1.0;
            onScaleGridChanged: {
                scaleSlide.slideValue = scaleGrid;
            }
            Component.onCompleted: {
                mapData.setCols(columns);
                mapData.setRows(rows);
            }

            function searchNextItem(index) {
                var nextItem;
                switch (updateCardIdDialog.direction) {
                case 0:
                    nextItem = updateCardIdDialog.agvModel.itemUp(index, mapGrid);
                    break;
                case 1:
                    nextItem = updateCardIdDialog.agvModel.itemDown(index, mapGrid);
                    break;
                case 2:
                    nextItem = updateCardIdDialog.agvModel.itemLeft(index, mapGrid);
                    break;
                case 3:
                    nextItem = updateCardIdDialog.agvModel.itemRight(index, mapGrid);
                    break;
                default:
                    return null;
                }
                return nextItem;
            }
            function updateMapItemMoveToNext(idx) {
                var nextItem;
                while (true) {
                    nextItem = searchNextItem(idx);
                    if (nextItem == null) {
                        break;
                    }
                    updateCardIdDialog.currentItem = nextItem;
                    idx = updateCardIdDialog.currentIndex = mapGrid.mapGrid.indexAt(nextItem.x, nextItem.y);
                    if (nextItem.isCard == false) {
                        continue;
                    }
                    break;
                }
                if (nextItem == null) {
                    console.log("search next item null. stop!");
                    updateCardIdDialog.run = false;
                } else {
                    console.log("search next item: " + updateCardIdDialog.currentIndex);
                }
            }

            function updateMapItemCardId(id) {
                if (updateCardIdDialog.run == false) {
                    return;
                }
                // set updateCardIdDialog currentIndex card id
                var idx = updateCardIdDialog.currentIndex;
                var item = updateCardIdDialog.currentItem;
                if (item == null) {
                    return;
                }
                console.log("update item " + idx + " id " + id);
                mapGrid.setItemCardID2(idx, id);
                // get next updateCardIdDialog currentIndex
                updateMapItemMoveToNext(idx);
            }

            function updateAgvCardId(ip, lastId, currentId) {
                var i, item;
                console.log("updateAgvCardId " + ip + " " + lastId + " " + currentId);
                //cardIDText.text = currentId;    // for auto update Item cardID, only test
                updateMapItemCardId(currentId);
                if (lastId > 0) {
                    i = mapData.getItemIndexByCardId(lastId);
                    if (i < 0) {
                        return;
                    }
                    item = itemAt(i);
                    item.agvIpText = "";
                }

                if (currentId > 0) {
                    i = mapData.getItemIndexByCardId(currentId);
                    console.log("updateAgvCardId currentId " + i + " " + ip.substr(ip.lastIndexOf(".") + 1, ip.length - 1));
                    if (i < 0) {
                        return;
                    }
                    item = itemAt(i);
                    item.agvIpText = ip.substr(ip.lastIndexOf(".") + 1, ip.length - 1);
                }
            }

            function setGridFocus() {
                mapGrid.mapGrid.focus = true;
            }
            function setItemCutLeftUp(v) {
                mapGrid.mapGrid.currentItem.cutLeftUp = v;
                mapData.setItemCutLeftUp(mapGrid.mapGrid.currentIndex, v);
                setGridFocus();
            }
            function setItemCutRightDown(v) {
                mapGrid.mapGrid.currentItem.cutRightDown = v;
                mapData.setItemCutRightDown(mapGrid.mapGrid.currentIndex, v);
                setGridFocus();
            }
            function setItemType(type) {
                mapGrid.mapGrid.currentItem.type = type;
                mapData.setItemType(mapGrid.mapGrid.currentIndex, type);
                setGridFocus();
            }
            function setItemType2(index, type) {
                var item = mapGrid.itemAt(index);
                item.type = type;
                mapData.setItemType(index, type);
                setGridFocus();
            }
            function setItemIsCard(isCard) {
                mapGrid.mapGrid.currentItem.cardPos[0] = Number(cardIDPosX.text);
                mapGrid.mapGrid.currentItem.cardPos[1] = Number(cardIDPosY.text);
                mapGrid.mapGrid.currentItem.isCard = isCard;
                mapData.setItemCardId(mapGrid.mapGrid.currentIndex,
                                      mapGrid.mapGrid.currentItem.isCard,
                                      mapGrid.mapGrid.currentItem.cardID);
                mapData.setItemCardPos(mapGrid.mapGrid.currentIndex,
                                       mapGrid.mapGrid.currentItem.cardPos);
                setGridFocus();
            }
            function setItemIsCard2(index, isCard) {
                var item = mapGrid.itemAt(index);
                item.cardPos[0] = Number(cardIDPosX.text);
                item.cardPos[1] = Number(cardIDPosY.text);
                item.isCard = isCard;
                mapData.setItemCardId(index, item.isCard, item.cardID);
                mapData.setItemCardPos(index, item.cardPos);
                setGridFocus();
            }
            function setItemCardID(id) {
                mapGrid.mapGrid.currentItem.cardID = Number(id);
                mapData.setItemCardId(mapGrid.mapGrid.currentIndex,
                                      mapGrid.mapGrid.currentItem.isCard,
                                      mapGrid.mapGrid.currentItem.cardID);
            }
            function setItemCardID2(index, id) {
                var item = mapGrid.itemAt(index);
                item.cardID = Number(id);
                mapData.setItemCardId(index, item.isCard, item.cardID);
            }
            function setItemCardPosX(x) {
                var pos = mapGrid.mapGrid.currentItem.cardPos;
                pos[0] = x;
                mapGrid.mapGrid.currentItem.cardPos = pos;
                mapData.setItemCardPos(mapGrid.mapGrid.currentIndex,
                                       mapGrid.mapGrid.currentItem.cardPos);
                setGridFocus();
            }
            function setItemCardPosX2(index, x) {
                var item = mapGrid.itemAt(index);
                var pos = item.cardPos;
                pos[0] = x;
                item.cardPos = pos;
                mapData.setItemCardPos(index,item.cardPos);
                setGridFocus();
            }
            function setItemCardPosY(x) {
                var pos = mapGrid.mapGrid.currentItem.cardPos;
                pos[1] = x;
                mapGrid.mapGrid.currentItem.cardPos = pos;
                mapData.setItemCardPos(mapGrid.mapGrid.currentIndex,
                                       mapGrid.mapGrid.currentItem.cardPos);
                setGridFocus();
            }
            function setItemCardPosY2(index, x) {
                var item = mapGrid.itemAt(index);
                var pos = item.cardPos;
                pos[1] = x;
                item.cardPos = pos;
                mapData.setItemCardPos(index, item.cardPos);
                setGridFocus();
            }
            function posAdd(pos, x, y) {
                pos[0] += x;
                pos[1] += y;
            }
            function checkItemOut(rows, cols) {
                if (rows > mapGrid.mapGrid.rows || rows < 0) {
                    return false;
                }
                if (cols > mapGrid.mapGrid.columns || cols < 0) {
                    return false;
                }
                return true;
            }
            function calIndex(rows, cols) {
                return rows * mapGrid.columns + cols;
            }
            function calNeighbour(rows, cols, x, y) {
                rows += y;
                cols += x;
                if (checkItemOut(rows, cols)) {
                    return calIndex(rows, cols);
                }
                return -1;
            }
            function itemAt(index) {
//                if (index != 0) {
//                    index++;
//                }
                var item = mapGrid.mapGrid.contentItem.children[index]; // BUG??
                if (item == null) {
                    console.log("itemAt " + index + " Error.")
                }

                return item;
            }
            function arrayDeepCopy(dst, src) {
                for (var i = 0; i < src.length; i++) {
                    dst[i] = src[i];
                }
            }
            function addNeighbour(rows, cols, dx, dy) {
                var item = itemAt(calIndex(rows, cols));
                item.neighbourPos.push([dx, dy]);
            }

            function updateNeighbour(rows, cols, dx, dy, t, pos) {
                var neighbour = calNeighbour(rows, cols, dx, dy);
                console.log("neighbour " + rows + " " + cols + " " + neighbour);
                var p = [];
                arrayDeepCopy(p, pos);
                if (neighbour != -1) {
                    posAdd(p, -50 * dx, -50 * dy);
                    var item = itemAt(neighbour);
                    item.arcParam = p;
                    item.isArc = t;
                    item.isNeighbour = true;
                    addNeighbour(rows, cols, dx, dy);
                    mapData.setItemArc(neighbour,
                                       item.isArc, item.neighbourPos);
                    mapData.setItemIsNeighbour(neighbour,
                                               item.isNeighbour);
                }
            }
            function clearNeighbour(rows, cols) {
                console.log("clear " + rows + " " + cols);
                var item = itemAt(calIndex(rows, cols));
                console.log("clear " + rows + " " + cols + " " + typeof(item.neighbourPos) + " " + item.neighbourPos);
                while (item.neighbourPos.length > 0) {
                    var p = item.neighbourPos.pop();
                    console.log("clear " + calIndex(rows, cols) + ": " + p[0] + " " + p[1]);
                    var i = calNeighbour(rows, cols, p[0], p[1]);
                    var nitem = itemAt(i);
                    nitem.isArc = MapItemType.ArcNULL;
                    mapData.setItemArc(i,
                                       nitem.isArc, nitem.neighbourPos);
                }
            }

            function arcNeighbour(t, pos, index) {
                var rows = parseInt(index / mapGrid.columns);
                var cols = index % mapGrid.columns;
                var p = [];
                arrayDeepCopy(p, pos);
                // clear
                clearNeighbour(rows, cols);
                switch (t) {
                case MapItemType.ArcXRD:
                    updateNeighbour(rows, cols, 1, 0, t, p);
                    updateNeighbour(rows, cols, 1, 1, t, p);
                    updateNeighbour(rows, cols, 2, 1, t, p);
                    updateNeighbour(rows, cols, 2, 2, t, p);
                    break;
                case MapItemType.ArcXLD:
                    updateNeighbour(rows, cols, -1, 0, t, p);
                    updateNeighbour(rows, cols, -1, 1, t, p);
                    updateNeighbour(rows, cols, -2, 1, t, p);
                    updateNeighbour(rows, cols, -2, 2, t, p);
                    break;
                case MapItemType.ArcXLU:
                    updateNeighbour(rows, cols, -1, 0, t, p);
                    updateNeighbour(rows, cols, -1, -1, t, p);
                    updateNeighbour(rows, cols, -2, -1, t, p);
                    updateNeighbour(rows, cols, -2, -2, t, p);
                    break;
                case MapItemType.ArcXRU:
                    updateNeighbour(rows, cols, 1, 0, t, p);
                    updateNeighbour(rows, cols, 1, -1, t, p);
                    updateNeighbour(rows, cols, 2, -1, t, p);
                    updateNeighbour(rows, cols, 2, -2, t, p);
                    break;
                case MapItemType.ArcYRD:
                    updateNeighbour(rows, cols, 0, 1, t, p);
                    updateNeighbour(rows, cols, 1, 1, t, p);
                    updateNeighbour(rows, cols, 1, 2, t, p);
                    updateNeighbour(rows, cols, 2, 2, t, p);
                    break;
                case MapItemType.ArcYLD:
                    updateNeighbour(rows, cols, 0, 1, t, p);
                    updateNeighbour(rows, cols, -1, 1, t, p);
                    updateNeighbour(rows, cols, -1, 2, t, p);
                    updateNeighbour(rows, cols, -2, 2, t, p);
                    break;
                case MapItemType.ArcYLU:
                    updateNeighbour(rows, cols, 0, -1, t, p);
                    updateNeighbour(rows, cols, -1, -1, t, p);
                    updateNeighbour(rows, cols, -1, -2, t, p);
                    updateNeighbour(rows, cols, -2, -2, t, p);
                    break;
                case MapItemType.ArcYRU:
                    updateNeighbour(rows, cols, 0, -1, t, p);
                    updateNeighbour(rows, cols, 1, -1, t, p);
                    updateNeighbour(rows, cols, 1, -2, t, p);
                    updateNeighbour(rows, cols, 2, -2, t, p);
                    break;
                case MapItemType.ArcNULL:
                    break;
                }
            }
            function updateItemArc(index, item, arcType) {
                var pos = [0, 0, 0, 0];
                var startAngle = 0.0;
                var endAngle = 0.0;
                posAdd(pos, 25, 25);
                switch (arcType) {
                case MapItemType.ArcXLD:
                case MapItemType.ArcXRD:
                    posAdd(pos, 0, 100);
                    break;
                case MapItemType.ArcXLU:
                case MapItemType.ArcXRU:
                    posAdd(pos, 0, -100);
                    break;
                case MapItemType.ArcYLD:
                case MapItemType.ArcYLU:
                    posAdd(pos, -100, 0);
                    break;
                case MapItemType.ArcYRD:
                case MapItemType.ArcYRU:
                    posAdd(pos, 100, 0);
                    break;
                }
                switch (arcType) {
                case MapItemType.ArcXLU:
                case MapItemType.ArcYRD:
                    startAngle = Math.PI / 2;
                    endAngle = Math.PI;
                    break;
                case MapItemType.ArcXLD:
                case MapItemType.ArcYRU:
                    startAngle = Math.PI;
                    endAngle = Math.PI * 1.5;
                    break;
                case MapItemType.ArcXRU:
                case MapItemType.ArcYLD:
                    startAngle = 0;
                    endAngle = Math.PI / 2;
                    break;
                case MapItemType.ArcXRD:
                case MapItemType.ArcYLU:
                    startAngle = Math.PI * 1.5;
                    endAngle = Math.PI * 2;
                    break;
                }
                pos[2] = startAngle;
                pos[3] = endAngle;
                console.log(pos[0] + " " + pos[1] + " " + pos[2] + " " + pos[3] + " "  + arcType);
                item.arcParam = pos;
                item.isArc = arcType;
                item.isNeighbour = false;
                arcNeighbour(arcType, pos, index);
            }

            function setItemArc() {
                var arcType = arcCombo.index;
                var item = mapGrid.mapGrid.currentItem;
                if (item == null) {
                    return;
                }
                if (item.isArc == arcType) {
                    return;
                }
                updateItemArc(mapGrid.mapGrid.currentIndex, item, arcType);
                mapData.setItemArc(mapGrid.mapGrid.currentIndex,
                                   item.isArc, item.neighbourPos);
                setGridFocus();
            }

            function showItemSettings() {
                var item = mapGrid.mapGrid.currentItem;
                switch (item.type) {
                case MapItemType.MapItemNULL:
                    radioTypeNULL.checked = true;
                    radioTypeNULL.forceActiveFocus();
                    break;
                case MapItemType.MapItemXLine:
                    radioTypeXLine.checked = true;
                    radioTypeXLine.forceActiveFocus();
                    break;
                case MapItemType.MapItemYLine:
                    radioTypeYLine.checked = true;
                    radioTypeYLine.forceActiveFocus();
                    break;
                case MapItemType.MapItemCross:
                    radioTypeCross.checked = true;
                    radioTypeCross.forceActiveFocus();
                    break;
                case MapItemType.MapItemXLStop:
                    radioTypeXLStop.checked = true;
                    radioTypeXLStop.forceActiveFocus();
                    break;
                case MapItemType.MapItemXRStop:
                    radioTypeXRStop.checked = true;
                    radioTypeXRStop.forceActiveFocus();
                    break;
                case MapItemType.MapItemYUStop:
                    radioTypeYUStop.checked = true;
                    radioTypeYUStop.forceActiveFocus();
                    break;
                case MapItemType.MapItemYDStop:
                    radioTypeYDStop.checked = true;
                    radioTypeYDStop.forceActiveFocus();
                    break;
                case MapItemType.MapItemXLMStop:
                    radioTypeXLMStop.checked = true;
                    radioTypeXLMStop.forceActiveFocus();
                    break;
                case MapItemType.MapItemXRMStop:
                    radioTypeXRMStop.checked = true;
                    radioTypeXRMStop.forceActiveFocus();
                    break;
                case MapItemType.MapItemYUMStop:
                    radioTypeYUMStop.checked = true;
                    radioTypeYUMStop.forceActiveFocus();
                    break;
                case MapItemType.MapItemYDMStop:
                    radioTypeYDMStop.checked = true;
                    radioTypeYDMStop.forceActiveFocus();
                    break;
                }
                if (item.isCard) {
                    cardCheck.checked = true;
                } else {
                    cardCheck.checked = false;
                }
//                console.log("show " + mapGrid.mapGrid.currentIndex + " : " + item.cardID);
                if (item.cardID != 0) {
                    cardIDText.text = item.cardID;
                } else {
                    cardIDText.text = "";
                }

                cardIDPosX.text = item.cardPos[0];
                cardIDPosY.text = item.cardPos[1];

                arcCombo.index = item.isArc;
                cutLeftUpCheck.checked = item.cutLeftUp;
                cutRightDownCheck.checked = item.cutRightDown;
                setGridFocus();
            }
            onCurrentIndexChanged: {
//                console.log("mapGrid index changed. " + mapGrid.mapGrid.currentIndex);
                showItemSettings();
                var item = mapGrid.mapGrid.currentItem;
                if (item.isCard == true) {
                    actCombo.index = 0;
                    pathSetId.text = item.cardID;
                }
            }
        }
        Column {
            id: column;
            spacing: 4;
            width: 280;
            height: parent.height;
            GroupBox {
                id: globalSettingsGroup;
                title: "Global Settings";
                width: 280;
                height: 150;

                ScaleSlide {
                    id: scaleSlide;
                    slideValue: mapGrid.scaleGrid;
                    onSlideChanged: {
                        mapGrid.scaleGrid = slideValue.toFixed(1);
                    }
                }
                FileText {
                    id: mapFilePath;
                    anchors.left: parent.left;
                    anchors.leftMargin: 4;
                    anchors.top: scaleSlide.bottom;
                    anchors.topMargin: 4;
                    width: parent.width;
                }
                Button {
                    id: mapFileNew;
                    anchors.left: parent.left;
                    anchors.top: mapFilePath.bottom;
                    anchors.leftMargin: 2;
                    anchors.topMargin: 4;
                    text: "New";
                    onClicked: {
                        fileDialog.selectExisting = false;
                        fileDialog.opt = 0;     // new
                        mapFilePath.text = "";
                        fileDialog.clearMap();
                    }
                }
                Button {
                    id: mapFileOpen;
                    anchors.left: mapFileNew.right;
                    anchors.top: mapFilePath.bottom;
                    anchors.leftMargin: 2;
                    anchors.topMargin: 4;
                    text: "Open";
                    onClicked: {
                        fileDialog.selectExisting = true;
                        fileDialog.opt = 1;     // open
                        fileDialog.open();
                    }
                }

                Button {
                    id: mapFileSave;
                    anchors.left: mapFileOpen.right;
                    anchors.leftMargin: 2;
                    anchors.top: mapFilePath.bottom;
                    anchors.topMargin: 4;
                    text: "Save";
                    onClicked: {
                        if (mapFilePath.text == "") {
                            fileDialog.selectExisting = false;
                            fileDialog.opt = 2;     // save
                            fileDialog.open();
                        } else {
                            fileDialog.saveMap();
                        }
                    }
                }
                Button {
                    id: agvDialogButton;
                    anchors.left: mapFileSave.right;
                    anchors.leftMargin: 2;
                    anchors.top: mapFilePath.bottom;
                    anchors.topMargin: 4;
                    text: agvDialog.visible ? "Hide" : "Show";
                    onClicked: {
                        if (agvDialog.visible) {
                            agvDialog.hide();
                        } else {
                            agvDialog.show();
                        }
                    }
                }
                Row {
                    spacing: 2
                    y:70
                    Text{
                        y: 4;
                        text: "rows:"
                    }
                    TextField {
                        id: rowSpinText;
                        width: 50;
                        height: 20;
                        selectByMouse: true;
                        textColor: "blue";
                        validator: IntValidator {}
                        Component.onCompleted: {
                            text = mapGrid.rows;
                        }
                    }
                    Text{
                        y: 4;
                        text: "column:"
                    }
                    TextField {
                        id: columnsSpinText;
                        width: 50;
                        height: 20;
                        selectByMouse: true;
                        textColor: "blue";
                        validator: IntValidator {}
                        Component.onCompleted: {
                            text = mapGrid.columns;
                        }
                    }
                    Button {
                        id: changeSizeButton;
                        height: 20;
                        width: 60;
                        text: "Resize";
                        onClicked: {
                            var r = rowSpinText.text;
                            var c = columnsSpinText.text;
                            console.log("map Data resize " + r + " " + c);
                            mapData.resize(r, c);
                            mapGrid.rows = r;
                            mapGrid.columns = c;
                            fileDialog.mapDataToMapGrid();
                            mapGrid.showItemSettings();
                        }
                    }
                }
                Row {
                    spacing: 4;
                    y: 100
                    Button {
                        id: leftmove;
                        height: 20;
                        width: 40;
                        text: "←";
                        onClicked: {
                            mapData.leftmove();
                            fileDialog.mapDataToMapGrid();
                            mapGrid.showItemSettings();
                        }
                    }
                    Button {
                        id: rightmove;
                        height: 20;
                        width: 40;
                        text: "→";
                        onClicked: {
                            mapData.rightmove();
                            fileDialog.mapDataToMapGrid();
                            mapGrid.showItemSettings();
                        }
                    }
                    Button {
                        id: upmove;
                        height: 20;
                        width: 40;
                        text: "↑";
                        onClicked: {
                            mapData.upmove();
                            fileDialog.mapDataToMapGrid();
                            mapGrid.showItemSettings();
                        }
                    }
                    Button {
                        id: downmove;
                        height: 20;
                        width: 40;
                        text: "↓";
                        onClicked: {
                            mapData.downmove();
                            fileDialog.mapDataToMapGrid();
                            mapGrid.showItemSettings();
                        }
                    }
                }
            }

            GroupBox {
                id: mapItemSettingsGroup;
                title: "Item Settings";
                width: 280;
                height: 216;
                ExclusiveGroup {
                    id: itemTypeGroup;
                }

                GridLayout {
                    id: radioGridLayout;
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top;
                    anchors.topMargin: 4;
                    width: parent.width;
                    rows: 4;
                    columns: 3;
                    rowSpacing: 4;
                    columnSpacing: 4;
                    flow: GridLayout.TopToBottom;
                    property real widthGrid: ((width - 8) / columns);
                    Component.onCompleted: {
                        console.log("Layout ", width / columns, " ", width);
                    }
                    RadioButton {
                        id: radioTypeNULL;
                        text: "NULL";
                        exclusiveGroup: itemTypeGroup;
                        Layout.preferredWidth: parent.widthGrid;
                        activeFocusOnPress: true;
                        style: radioStyle;
                        onClicked: mapGrid.setItemType(MapItemType.MapItemNULL);
                    }
                    RadioButton {
                        id: radioTypeXLine;
                        text: "XLine";
                        exclusiveGroup: itemTypeGroup;
                        Layout.preferredWidth: parent.widthGrid;
                        activeFocusOnPress: true;
                        style: radioStyle;
                        onClicked: mapGrid.setItemType(MapItemType.MapItemXLine);
                    }
                    RadioButton {
                        id: radioTypeYLine;
                        text: "YLine";
                        exclusiveGroup: itemTypeGroup;
                        Layout.preferredWidth: parent.widthGrid;
                        activeFocusOnPress: true;
                        style: radioStyle;
                        onClicked: mapGrid.setItemType(MapItemType.MapItemYLine);
                    }
                    RadioButton {
                        id: radioTypeCross;
                        text: "Cross";
                        exclusiveGroup: itemTypeGroup;
                        Layout.preferredWidth: parent.widthGrid;
                        activeFocusOnPress: true;
                        style: radioStyle;
                        onClicked: mapGrid.setItemType(MapItemType.MapItemCross);
                    }
                    RadioButton {
                        id: radioTypeXLStop;
                        text: "XLStop";
                        exclusiveGroup: itemTypeGroup;
                        Layout.preferredWidth: parent.widthGrid;
                        activeFocusOnPress: true;
                        style: radioStyle;
                        onClicked: mapGrid.setItemType(MapItemType.MapItemXLStop);
                    }
                    RadioButton {
                        id: radioTypeXRStop;
                        text: "XRStop";
                        exclusiveGroup: itemTypeGroup;
                        Layout.preferredWidth: parent.widthGrid;
                        activeFocusOnPress: true;
                        style: radioStyle;
                        onClicked: mapGrid.setItemType(MapItemType.MapItemXRStop);
                    }
                    RadioButton {
                        id: radioTypeYUStop;
                        text: "YUStop";
                        exclusiveGroup: itemTypeGroup;
                        Layout.preferredWidth: parent.widthGrid;
                        activeFocusOnPress: true;
                        style: radioStyle;
                        onClicked: mapGrid.setItemType(MapItemType.MapItemYUStop);
                    }
                    RadioButton {
                        id: radioTypeYDStop;
                        text: "YDStop";
                        exclusiveGroup: itemTypeGroup;
                        Layout.preferredWidth: parent.widthGrid;
                        activeFocusOnPress: true;
                        style: radioStyle;
                        onClicked: mapGrid.setItemType(MapItemType.MapItemYDStop);
                    }
                    RadioButton {
                        id: radioTypeXLMStop;
                        text: "XLMStop";
                        exclusiveGroup: itemTypeGroup;
                        Layout.preferredWidth: parent.widthGrid;
                        activeFocusOnPress: true;
                        style: radioStyle;
                        onClicked: mapGrid.setItemType(MapItemType.MapItemXLMStop);
                    }
                    RadioButton {
                        id: radioTypeXRMStop;
                        text: "XRMStop";
                        exclusiveGroup: itemTypeGroup;
                        Layout.preferredWidth: parent.widthGrid;
                        activeFocusOnPress: true;
                        style: radioStyle;
                        onClicked: mapGrid.setItemType(MapItemType.MapItemXRMStop);
                    }
                    RadioButton {
                        id: radioTypeYUMStop;
                        text: "YUMStop";
                        exclusiveGroup: itemTypeGroup;
                        Layout.preferredWidth: parent.widthGrid;
                        activeFocusOnPress: true;
                        style: radioStyle;
                        onClicked: mapGrid.setItemType(MapItemType.MapItemYUMStop);
                    }
                    RadioButton {
                        id: radioTypeYDMStop;
                        text: "YDMStop";
                        exclusiveGroup: itemTypeGroup;
                        Layout.preferredWidth: parent.widthGrid;
                        activeFocusOnPress: true;
                        style: radioStyle;
                        onClicked: mapGrid.setItemType(MapItemType.MapItemYDMStop);
                    }
                }

                CheckBox {
                    id: cardCheck;
                    anchors.top: radioGridLayout.bottom;
                    anchors.topMargin: 8;
                    text: "Is Card";
                    onClicked: {
                        mapGrid.setItemIsCard(checked);
                    }
                }

                TextField {
                    id: cardIDText;
                    anchors.left: cardCheck.right;
                    anchors.leftMargin: 4;
                    anchors.top: cardCheck.top;
                    anchors.topMargin: -2;
                    width: 70
                    height: 20;
                    placeholderText: qsTr("Card ID");
                    selectByMouse: true;
                    textColor: "blue";
                    validator: IntValidator {}
                    onFocusChanged: {
                        if (focus) {
                            selectAll();
                        }
                    }
//                    onEditingFinished: {
//                        console.log("Card ID onEditingFinished. ", cardIDText.text);
//                        mapGrid.setItemCardID(cardIDText.text);
//                    }
//                    onTextChanged: {
//                        mapGrid.setItemCardID(cardIDText.text);
//                    }
                }

                TextField {
                    id: cardIDPosX;
                    anchors.left: cardIDText.right;
                    anchors.leftMargin: 4;
                    anchors.top: cardIDText.top;
                    width: 34;
                    height: 20;
                    selectByMouse: true;
                    textColor: "green";
                    text: "0.0";
                    validator: DoubleValidator {
                    }
                    onFocusChanged: {
                        if (focus) {
                            selectAll();
                        }
                    }
//                    onEditingFinished: {
//                        mapGrid.setItemCardPosX(Number(cardIDPosX.text));
//                    }
                }
                TextField {
                    id: cardIDPosY;
                    anchors.left: cardIDPosX.right;
                    anchors.leftMargin: 4;
                    anchors.top: cardIDText.top;
                    width: 34;
                    height: 20;
                    selectByMouse: true;
                    textColor: "green";
                    text: "0.0";
                    validator: DoubleValidator {
                    }
                    onFocusChanged: {
                        if (focus) {
                            selectAll();
                        }
                    }
//                    onEditingFinished: {
//                        mapGrid.setItemCardPosY(Number(cardIDPosY.text));
//                    }
                }
                Button {
                    id: posEnter;
                    anchors.left: cardIDPosY.right;
                    anchors.leftMargin: 4;
                    anchors.top: cardIDText.top;
                    width: 34;
                    height: 20;
                    text: "Enter";
                    onClicked: {
                        mapGrid.setItemCardID(cardIDText.text);
                        mapGrid.setItemCardPosX(Number(cardIDPosX.text));
                        mapGrid.setItemCardPosY(Number(cardIDPosY.text));
                    }
                }
                ArcCombo {
                    id: arcCombo;
                    width: 150;
                    anchors.top: cardCheck.bottom;
                    anchors.topMargin: 8;
                    index: MapItemType.ArcNULL;
                    onIndexChanged: {
                        console.log("index changed. ", index);
                        mapGrid.setItemArc();
                    }
                }
                CheckBox {
                    id: cutLeftUpCheck;
                    anchors.top: arcCombo.top;
                    anchors.topMargin: 4;
                    anchors.left: arcCombo.right;
                    anchors.leftMargin: 8;
                    text: "CLU";
                    checked: false;
                    onCheckedChanged: mapGrid.setItemCutLeftUp(checked);
                }
                CheckBox {
                    id: cutRightDownCheck;
                    anchors.top: arcCombo.top;
                    anchors.topMargin: 4;
                    anchors.left: cutLeftUpCheck.right;
                    anchors.leftMargin: 8;
                    text: "CRD";
                    checked: false;
                    onCheckedChanged: mapGrid.setItemCutRightDown(checked);
                }
                // repeat settings
                ComboBox {
                    id: repeatSelectCombo;
                    width: 80;
                    anchors.top: arcCombo.bottom;
                    anchors.topMargin: 4;
                    model: [
                        "行方式",
                        "列方式",
                        "行列式"
                    ];
                }
                ComboBox {
                    id: repeatItemTypeCombo;
                    width: 80;
                    anchors.top: repeatSelectCombo.top;
                    anchors.left: repeatSelectCombo.right;
                    anchors.leftMargin: 4;
//                    anchors.topMargin: 4;
                    model: [
                        "NULL",
                        "XLine",
                        "YLine",
                        "Cross",
                        "XLStop",
                        "XRStop",
                        "YUStop",
                        "YDStop",
                        "XLMStop",
                        "XRMStop",
                        "YUMStop",
                        "YDMStop"
                    ];
                }
                Button {
                    id: updateDialogButton;
                    anchors.left: repeatItemTypeCombo.right;
                    anchors.leftMargin: 2;
                    anchors.top: repeatItemTypeCombo.top;
                    text: updateCardIdDialog.visible ? "Hide" : "Show";
                    onClicked: {
                        if (updateCardIdDialog.visible) {
                            updateCardIdDialog.hide();
                        } else {
                            updateCardIdDialog.show();
                        }
                    }
                }
                TextField {
                    id: repeatStartText;
//                    anchors.left: repeatItemTypeCombo.right;
//                    anchors.leftMargin: 4;
                    anchors.top: repeatSelectCombo.bottom;
                    anchors.topMargin: 4;
                    width: 40;
                    height: 20;
                    selectByMouse: true;
                    textColor: "green";
                    placeholderText: qsTr("起始");
//                    text: "0";
                    validator: IntValidator {
                    }
                    onFocusChanged: {
                        if (focus) {
                            selectAll();
                        }
                    }
                }
                TextField {
                    id: repeatEndText;
                    anchors.left: repeatStartText.right;
                    anchors.leftMargin: 4;
                    anchors.top: repeatStartText.top;
//                    anchors.topMargin: 2;
                    width: 40;
                    height: 20;
                    selectByMouse: true;
                    textColor: "green";
                    placeholderText: qsTr("结束");
//                    text: "0";
                    validator: IntValidator {
                    }
                    onFocusChanged: {
                        if (focus) {
                            selectAll();
                        }
                    }
                }
                TextField {
                    id: repeatRowsIntervalText;
                    anchors.left: repeatEndText.right;
                    anchors.leftMargin: 4;
                    anchors.top: repeatStartText.top;
//                    anchors.topMargin: 2;
                    width: 60;
                    height: 20;
                    selectByMouse: true;
                    textColor: "green";
                    placeholderText: qsTr("行间隔");
//                    text: "0";
                    validator: IntValidator {
                    }
                    onFocusChanged: {
                        if (focus) {
                            selectAll();
                        }
                    }
                }
                TextField {
                    id: repeatColumnsIntervalText;
                    anchors.left: repeatRowsIntervalText.right;
                    anchors.leftMargin: 4;
                    anchors.top: repeatStartText.top;
                    width: 60;
                    height: 20;
                    selectByMouse: true;
                    textColor: "green";
                    placeholderText: qsTr("列间隔");
//                    text: "0";
                    validator: IntValidator {
                    }
                    onFocusChanged: {
                        if (focus) {
                            selectAll();
                        }
                    }
                }
                Button {
                    id: insertRepeatItemButton;
                    text: "Insert";
                    anchors.left: repeatColumnsIntervalText.right;
                    anchors.leftMargin: 4;
                    anchors.top: repeatStartText.top;
                    width: 60;
                    height: repeatStartText.height;
                    onClicked: {
                        if (repeatSelectCombo.currentIndex == 0) {
                            insertRepeatRows(parseInt(repeatStartText.text), parseInt(repeatEndText.text),
                                             parseInt(repeatRowsIntervalText.text), parseInt(repeatColumnsIntervalText.text));
                        } else if (repeatSelectCombo.currentIndex == 1) {
                            insertRepeatColumns(parseInt(repeatStartText.text), parseInt(repeatEndText.text),
                                                parseInt(repeatRowsIntervalText.text), parseInt(repeatColumnsIntervalText.text));
                        } else {
                            insertRepeatRowColumns(parseInt(repeatStartText.text), parseInt(repeatEndText.text),
                                                   parseInt(repeatRowsIntervalText.text))
                        }

                    }
                    function isCardAction(index) {
                        mapGrid.setItemCardID2(index, cardIDText.text);
                        mapGrid.setItemCardPosX2(index, Number(cardIDPosX.text));
                        mapGrid.setItemCardPosY2(index, Number(cardIDPosY.text));
                        mapGrid.setItemIsCard2(index, cardCheck.checked);
                    }
                    function insertRepeatRows(startItem, endItem, rowsInterval, columnsInterval) {
                        var i;
                        var j;
                        var col = mapGrid.columns;
                        j = parseInt(startItem / col);    // 所在行
                        var s = startItem % col;            // 行开始位置
                        for (i = startItem; i <= endItem; i += rowsInterval) {
                            console.log("now i = " + i + " j = " + j + " " + col * (j + 1));
                            if (i >= col * (j + 1)) {
                                // 如果当前行已经满，则跳到下一行的开始位置
                                j = j + columnsInterval;
                                i = s + col * j;
                                if (i > endItem) {
                                    break;
                                }
                            }
                            mapGrid.setItemType2(parseInt(i), repeatItemTypeCombo.currentIndex);
                            isCardAction(parseInt(i));
                        }
                    }
                    function insertRepeatColumns(startItem, endItem, rowsInterval, columnsInterval) {
                        var i;
                        var j;
                        var col = mapGrid.columns;
                        var row = parseInt(endItem / col);
                        if (endItem % col) {
                            row += 1;
                        }
                        console.log("row = " + row + " " + (row) * col);
                        j = parseInt(startItem % col);  // 所在列
                        for(i = startItem; i < endItem; ) {
                            console.log("now i = " + i + " j = " + j + " " + (row) * col + j);
                            mapGrid.setItemType2(parseInt(i), repeatItemTypeCombo.currentIndex);
                            isCardAction(parseInt(i));
                            i = i + columnsInterval * col;
                            if (i >= (row) * col + j){
                                // 如果当前列已经满，则跳到下一列的开始位置
                                j = j + rowsInterval;
                                i = startItem - startItem % col + j;
                                if (i > endItem) {
                                    break;
                                }
                            }
                            console.log("i = " + i);
                            console.log("j = " + j);
                        }
                    }
                    function insertRepeatRowColumns(startItem, endItem, rowsInterval) {
                        var i;
                        var j;
                        for (i = startItem; i <= endItem; i += rowsInterval) {
                            mapGrid.setItemType2(parseInt(i), repeatItemTypeCombo.currentIndex);
                            isCardAction(parseInt(i));
                        }
                    }
                }
            }
//            GroupBox {
//                id: repeatSettingsGroup;
//                title: "Repeat Settings";
//                width: 280;
//                height: 90;

//            }

            GroupBox {
                id: pathSettingsGroup;
                title: "Path Settings";
                width: 280;
                height: 90;

                ActCombo {
                    id: actCombo;
                    anchors.top: parent.top;
                    anchors.topMargin: 4;
                    index: MapItemType.ActNULL;
                    onIndexChanged: {
                        if (actProperty != null) {
                            actProperty.type = index;
                        }
                    }
                }
                Text {
                    id: pathSetId;
                    anchors.left: actCombo.right;
                    anchors.leftMargin: 4;

                    text: "";
                    color: "blue";
                }

                ActProperty {
                    id: actProperty;
                    anchors.top: actCombo.bottom;
                    anchors.topMargin: 27;
                    type: 0;
                }
                function actJsonVal() {
                    var v;
                    var id = pathSetId.text.toString();
                    if (actCombo.index == 1) {
                        v =  "{";
                        v += "\"id\":\"" + id + "\",";
                        v += "\"act\":" + actCombo.actJsonVal[actCombo.index];
                        v += "}";
                    } if ((actCombo.index == 2) || (actCombo.index == 3)) {
                        if(actProperty.speedValue) {
                            if(actProperty.turnValue) {
                                v =  "{";
                                v += "\"id\":\"" + id + "\",";
                                v += "\"act\":" + actCombo.actJsonVal[actCombo.index] + ",";
                                v += "\"v\":" + actProperty.speedValue + ",";
                                v += "\"turn\":" + actProperty.turnValue;
                                v += "}";
                            } if (!actProperty.turnValue) {
                                v =  "{";
                                v += "\"id\":\"" + id + "\",";
                                v += "\"act\":" + actCombo.actJsonVal[actCombo.index] + ",";
                                v += "\"v\":" + actProperty.speedValue;
                                v += "}";
                            } return v;
                        }  else if (actProperty.turnValue) {
                            v =  "{";
                            v += "\"id\":\"" + id + "\",";
                            v += "\"act\":" + actCombo.actJsonVal[actCombo.index] + ",";
                            v += "\"turn\":" + actProperty.turnValue;
                            v += "}";
                        } else {
                            v =  "{";
                            v += "\"id\":\"" + id + "\",";
                            v += "\"act\":" + actCombo.actJsonVal[actCombo.index];
                            v += "}";
                        } return v;
                    } if ((actCombo.index == 4) || (actCombo.index == 5)) {
                        v =  "{";
                        v += "\"id\":\"" + id + "\",";
                        v += "\"act\":" + actCombo.actJsonVal[actCombo.index]  + ",";
                        v += "\"v\":" + actProperty.speedValue;
                        v += "}";
                    } if ((actCombo.index == 6) || (actCombo.index == 7)) {
                        v =  "{";
                        v += "\"id\":\"" + id + "\",";
                        v += "\"act\":" + actCombo.actJsonVal[actCombo.index]  + ",";
                        v += "\"rot\":" + actProperty.rotJsonVal[actProperty.rotValue];
                        v += "}";
                    } if (actCombo.index == 8) {
                        v =  "{";
                        v += "\"id\":\"" + id + "\",";
                        v += "\"act\":" + actCombo.actJsonVal[actCombo.index]  + ",";
                        v += "\"val\":" + actProperty.platJsonVal[actProperty.platValue];
                        v += "}";
                    } if (actCombo.index == 9) {
                        v =  "{";
                        v += "\"id\":\"" + id + "\",";
                        v += "\"act\":" + actCombo.actJsonVal[actCombo.index]  + ",";
                        v += "\"bz\":" + actProperty.oaJsonVal[actProperty.oaValue];
                        v += "}";
                    } if (actCombo.index == 10) {
                        v =  "{";
                        v += "\"id\":\"" + id + "\",";
                        v += "\"act\":" + actCombo.actJsonVal[actCombo.index]  + ",";
                        v += "\"val\":" + actProperty.relayJsonVal[actProperty.relayValue];
                        v += "}";
                    } return v;
                }
                Button {
                    id: addButton;
                    width: 40;
                    height: 20;
                    anchors.right: parent.right;
                    anchors.rightMargin: 2;
                    text: "增加";
                    onClicked: {
                        if (pathSetId.text == "") {
                            return;
                        }
                        pathList.listView.add(pathSettingsGroup.actJsonVal());
                        console.log(pathSettingsGroup.actJsonVal());
                    }
                }
                function model(){
                    var p;
                    if (actCombo.index == 0 || actCombo.index == 1) {
                        p = ""
                        return p;
                    }
                    if (actCombo.index == 2 || actCombo.index == 3) {
                        p = "v:"+actProperty.modelV[actProperty.speedValue] + ",T:" +actProperty.modelT[actProperty.turnValue];
                        return p;
                    }
                    if (actCombo.index == 4 || actCombo.index == 5) {
                        p = "v:"+actProperty.modelV[actProperty.speedValue];
                        return p;
                    }
                    if (actCombo.index == 6 || actCombo.index == 7) {
                        p = "rot:"+actProperty.modelR[actProperty.rotValue];
                        return p;
                    }
                    if (actCombo.index == 8) {
                        p = "lf:"+actProperty.modelP[actProperty.platValue];
                        return p;
                    }
                    if (actCombo.index == 9) {
                        p = "oa:"+actProperty.modelB[actProperty.oaValue];
                        return p;
                    }
                    if (actCombo.index == 10) {
                        p = "charge:"+actProperty.modelC[actProperty.chargeValue] + ",relay:" + actProperty.modelRL[actProperty.relayValue];
                        return p;
                    } else {
                        return 0;
                    }
                }
                Button {
                    id: reviseButton;
                    width: 40;
                    height: 20;
                    anchors.right: addButton.right;
                    anchors.top: addButton.bottom;
                    anchors.topMargin: 2;
                    text: "修改";
                    onClicked: {
                        console.log("revise " + pathList.listView.count + " " + pathList.listView.currentIndex);
                        if (pathList.listView.count == 0) {
                            return;
                        }
                        if (pathSetId.text == "") {
                            return;
                        }
                        pathList.listView.revise(pathSettingsGroup.actJsonVal());
                    }
                }
                Button {
                    id: deleteButton;
                    width: 40;
                    height: 20;
                    anchors.right: reviseButton.right;
                    anchors.top: reviseButton.bottom;
                    anchors.topMargin: 2;
                    text: "删除";
                    onClicked: {
                        if (pathList.listView.count == 0) {
                            return;
                        }
                        var i = pathList.listView.currentIndex;
                        pathList.listView.del(i);
                    }
                }
            }
            PathInfo{
                id: pathList;
                width: 280;
                height: mapGrid.height - globalSettingsGroup.height
                        - mapItemSettingsGroup.height/* - repeatSettingsGroup.height*/
                        - pathSettingsGroup.height - 12;
            }

        }
    }
}
