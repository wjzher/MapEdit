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
    title: qsTr("MapEditor");

    AgvDialog {
        id: agvDialog;
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
                if (item.isArc != MapItemType.ArcNULL && item.isNeighbour == false) {
                    mapGrid.updateItemArc(i, item, item.isArc);
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
//        property int mapWidth: {
//            var w = row.width - mapItemSettingsGroup.width - row.spacing;
//            var h = row.height;
//            return (w < h) ? w : h;
//        }
        MapGrid {
            id: mapGrid;
            width: row.width - mapItemSettingsGroup.width - row.spacing;
            height: row.height - 12;
            rows: 20;
            columns: 20;
            scaleGrid: 1.6;
            onScaleGridChanged: {
                scaleSlide.slideValue = scaleGrid;
            }
            Component.onCompleted: {
                mapData.setCols(columns);
                mapData.setRows(rows);
            }

            function setGridFocus() {
                mapGrid.mapGrid.focus = true;
            }

            function setItemType(type) {
                mapGrid.mapGrid.currentItem.type = type;
                setGridFocus();
            }
            function setItemIsCard(isCard) {
                mapGrid.mapGrid.currentItem.cardPos[0] = Number(cardIDPosX.text);
                mapGrid.mapGrid.currentItem.cardPos[1] = Number(cardIDPosY.text);
                mapGrid.mapGrid.currentItem.isCard = isCard;
                setGridFocus();
            }
            function setItemCardID(id) {
                mapGrid.mapGrid.currentItem.cardID = Number(id);
            }
            function setItemCardPosX(x) {
                var pos = mapGrid.mapGrid.currentItem.cardPos;
                pos[0] = x;
                mapGrid.mapGrid.currentItem.cardPos = pos;
                setGridFocus();
            }
            function setItemCardPosY(x) {
                var pos = mapGrid.mapGrid.currentItem.cardPos;
                pos[1] = x;
                mapGrid.mapGrid.currentItem.cardPos = pos;
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
                return rows * mapGrid.rows + cols;
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
                if (index != 0) {
                    index++;
                }
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
                }
            }
            function clearNeighbour(rows, cols) {
                console.log("clear " + rows + " " + cols);
                var item = itemAt(calIndex(rows, cols));
                console.log("clear " + rows + " " + cols + " " + typeof(item.neighbourPos) + " " + item.neighbourPos);
                while (item.neighbourPos.length > 0) {
                    var p = item.neighbourPos.pop();
                    console.log("clear " + calIndex(rows, cols) + ": " + p[0] + " " + p[1]);
                    var nitem = itemAt(calNeighbour(rows, cols, p[0], p[1]));
                    nitem.isArc = MapItemType.ArcNULL;
                }
            }

            function arcNeighbour(t, pos, index) {
                var rows = parseInt(index / mapGrid.rows);
                var cols = index % mapGrid.rows;
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
                setGridFocus();
            }
            onCurrentIndexChanged: {
//                console.log("mapGrid index changed. " + mapGrid.mapGrid.currentIndex);
                showItemSettings();
                var item = mapGrid.mapGrid.currentItem;
                if (item.isCard == true) {
                    actCombo.index = 0;
                }
            }
        }
        Column {
            id: column;
            spacing: 4;
            width: 280;
            GroupBox {
                id: globalSettingsGroup;
                title: "Global Settings";
                width: 280;
                height: 100;

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
            }

            GroupBox {
                id: mapItemSettingsGroup;
                title: "Item Settings";
                width: 280;
                height: 162;
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
                    text: "Card Exsit?";
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
                    width: 75
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
                    onEditingFinished: {
                        console.log("Card ID onEditingFinished. ", cardIDText.text);
                        mapGrid.setItemCardID(cardIDText.text);
                    }
                    onTextChanged: {
                        mapGrid.setItemCardID(cardIDText.text);
                    }
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
                    onEditingFinished: {
                        mapGrid.setItemCardPosX(Number(cardIDPosX.text));
                    }
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
                    onEditingFinished: {
                        mapGrid.setItemCardPosY(Number(cardIDPosY.text));
                    }
                }
                ArcCombo {
                    id: arcCombo;
                    anchors.top: cardCheck.bottom;
                    anchors.topMargin: 8;
                    index: MapItemType.ArcNULL;
                    onIndexChanged: {
                        console.log("index changed. ", index);
                        mapGrid.setItemArc();
                    }
                }
            }
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
                ActProperty {
                    id: actProperty;
                    anchors.top: actCombo.bottom;
                    anchors.topMargin: 27;
                    type: 0;
                }
                function actJsonVal() {
                    var v;
                    if (actCombo.index == 1) {
                        v =  "{";
                        v += "\"id\":\"" + mapGrid.mapGrid.currentItem.cardID.toString() + "\",";
                        v += "\"act\":" + actCombo.actJsonVal[actCombo.index];
                        v += "}";
                    } if ((actCombo.index == 2) || (actCombo.index == 3)) {
                        if(actProperty.speedValue) {
                            if(actProperty.turnValue) {
                                v =  "{";
                                v += "\"id\":\"" + mapGrid.mapGrid.currentItem.cardID.toString() + "\",";
                                v += "\"act\":" + actCombo.actJsonVal[actCombo.index] + ",";
                                v += "\"v\":" + actProperty.speedValue + ",";
                                v += "\"turn\":" + actProperty.turnValue;
                                v += "}";
                            } if (!actProperty.turnValue) {
                                v =  "{";
                                v += "\"id\":\"" + mapGrid.mapGrid.currentItem.cardID.toString() + "\",";
                                v += "\"act\":" + actCombo.actJsonVal[actCombo.index] + ",";
                                v += "\"v\":" + actProperty.speedValue;
                                v += "}";
                            } return v;
                        }  else if (actProperty.turnValue) {
                            v =  "{";
                            v += "\"id\":\"" + mapGrid.mapGrid.currentItem.cardID.toString() + "\",";
                            v += "\"act\":" + actCombo.actJsonVal[actCombo.index] + ",";
                            v += "\"turn\":" + actProperty.turnValue;
                            v += "}";
                        } else {
                            v =  "{";
                            v += "\"id\":\"" + mapGrid.mapGrid.currentItem.cardID.toString() + "\",";
                            v += "\"act\":" + actCombo.actJsonVal[actCombo.index];
                            v += "}";
                        } return v;
                    } if ((actCombo.index == 4) || (actCombo.index == 5)) {
                        v =  "{";
                        v += "\"id\":\"" + mapGrid.mapGrid.currentItem.cardID.toString() + "\",";
                        v += "\"act\":" + actCombo.actJsonVal[actCombo.index]  + ",";
                        v += "\"rot\":" + actProperty.rotJsonVal[actProperty.rotValue];
                        v += "}";
                    } if (actCombo.index == 6) {
                        v =  "{";
                        v += "\"id\":\"" + mapGrid.mapGrid.currentItem.cardID.toString() + "\",";
                        v += "\"act\":" + actCombo.actJsonVal[actCombo.index]  + ",";
                        v += "\"val\":" + actProperty.platJsonVal[actProperty.platValue];
                        v += "}";
                    } if (actCombo.index == 7) {
                        v =  "{";
                        v += "\"id\":\"" + mapGrid.mapGrid.currentItem.cardID.toString() + "\",";
                        v += "\"act\":" + actCombo.actJsonVal[actCombo.index]  + ",";
                        v += "\"bz\":" + actProperty.oaJsonVal[actProperty.oaValue];
                        v += "}";
                    }return v;
                }
                Button {
                    id: addButton;
                    width: 40;
                    height: 20;
                    anchors.right: parent.right;
                    anchors.rightMargin: 2;
                    text: "增加";
                    onClicked: {
                        pathSettingsGroup.actJsonVal();
                        pathList.listView.add(mapGrid.mapGrid.currentIndex, pathSettingsGroup.actJsonVal());
                        console.log(pathSettingsGroup.actJsonVal());
                    }
                }
                function model(){
                    var p;
                    if (actCombo.index == 0 || actCombo.index == 1) {
                        return 0;
                    }
                    if (actCombo.index == 2 || actCombo.index == 3) {
                        p = "v:"+actProperty.modelV[actProperty.speedValue] + ",T:" +actProperty.modelT[actProperty.turnValue];
                        return p;
                    }
                    if (actCombo.index == 4 || actCombo.index == 5) {
                        p = "rot:"+actProperty.modelR[actProperty.rotValue];
                        return p;
                    } if (actCombo.index == 6) {
                        p = "lf:"+actProperty.modelP[actProperty.platValue];
                        return p;
                    } if (actCombo.index == 7) {
                        p = "oa:"+actProperty.modelB[actProperty.oaValue];
                        return p;
                    } if (actCombo.index == 8) {
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
                        var item = mapGrid.mapGrid.currentItem;
                        var v;
                        v = {
                            "Act":actCombo.model[actCombo.index],
                            "Remark":pathSettingsGroup.model()
                        };
                        pathList.listView.revise(v);
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
                        var item = mapGrid.mapGrid.currentItem;
                        pathList.listView.del(item);
                    }
                }
            }
            PathInfo{
                id: pathList;
                width: 280;
                height: rootItem.height - 352 - 32 - 8;
            }

        }
    }
}
