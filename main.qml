import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Qt.MapItemType 1.0
import QtQuick.Layouts 1.1

Window {
    visible: true
    minimumHeight: 600;
    minimumWidth: 800;
    width: 800;
    height: 640;
    id: rootItem;
    color: "#EEEEEE";
    title: qsTr("MapEditor")

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
    MapItem {
        id: mapItem;
        width: 100;
        height: 100;
        anchors.left: parent.left;
        anchors.bottom: parent.bottom;
        anchors.margins: 4;
        type: MapItemType.MapItemXLine;
        color: "white";
        isCard: false;
        text: "248";
        cardPos: [length * 0.3, length * 0.5];
        Component.onCompleted: {
        }
        onClicked: {
            contentMenu.popup();
        }
    }
    Row {
        id: row;
        anchors.fill: parent;
        anchors.margins: 8;
        spacing: 4;
        property int mapWidth: {
            var w = row.width - mapItemSettingsGroup.width - row.spacing;
            var h = row.height;
            return (w < h) ? w : h;
        }
        MapGrid {
            id: mapGrid;
            width: row.mapWidth;
            height: row.mapWidth;
            rows: 20;
            columns: 20;
            scaleGrid: 1.5;
            onScaleGridChanged: {
                scaleSlide.slideValue = scaleGrid;
                console.log("set scale slide value.")
            }

            function setItemType(type) {
                mapGrid.mapGrid.currentItem.type = type;
            }
            function setItemIsCard(isCard) {
                mapGrid.mapGrid.currentItem.cardPos[0] = Number(cardIDPosX.text);
                mapGrid.mapGrid.currentItem.cardPos[1] = Number(cardIDPosY.text);
                mapGrid.mapGrid.currentItem.isCard = isCard;
            }
            function setItemCardID(id) {
                mapGrid.mapGrid.currentItem.cardID = Number(id);
            }
            function setItemCardPosX(x) {
                var pos = mapGrid.mapGrid.currentItem.cardPos;
                pos[0] = x;
                mapGrid.mapGrid.currentItem.cardPos = pos;
            }
            function setItemCardPosY(x) {
                var pos = mapGrid.mapGrid.currentItem.cardPos;
                pos[1] = x;
                mapGrid.mapGrid.currentItem.cardPos = pos;
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

            function setItemArc() {
                var index = arcCombo.index;
                var item = mapGrid.mapGrid.currentItem;
                if (item == null) {
                    return;
                }
                if (item.isArc == index) {
                    return;
                }
                var pos = [0, 0, 0, 0];
                var startAngle = 0.0;
                var endAngle = 0.0;
                posAdd(pos, 25, 25);
                switch (index) {
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
                switch (index) {
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
                console.log(pos[0] + " " + pos[1] + " " + pos[2] + " " + pos[3] + " "  + index);
                item.arcParam = pos;
                item.isArc = index;
                arcNeighbour(index, pos, mapGrid.mapGrid.currentIndex);
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
            }
            onCurrentIndexChanged: {
//                console.log("mapGrid index changed. " + mapGrid.mapGrid.currentIndex);
                showItemSettings();
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
                        console.log("set mapGrid scaleGrid.")
                    }
                }
            }

            GroupBox {
                id: mapItemSettingsGroup;
                title: "Item Settings";
    //            anchors.right: parent.right;
    //            anchors.top: parent.top;
    //            anchors.topMargin: 8;
    //            anchors.rightMargin: 8;
                width: 280;
                height: 200;
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
                    focus: true;
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

//                CheckBox {
//                    id: arcCheck;
//                    anchors.top: cardCheck.bottom;
//                    anchors.topMargin: 8;
//                    text: "Arc Exsit?";
//                    onClicked: {
//                        console.log("is Arc clicked. ", checked);
//                    }
//                }

//                TextField {
//                    id: arcRadiusText;
//                    anchors.left: cardIDText.left;
//                    anchors.leftMargin: 0;
//                    anchors.top: arcCheck.top;
//                    anchors.topMargin: -2;
//                    width: 60;
//                    height: 20;
//                    placeholderText: qsTr("Radius");
//                    selectByMouse: true;
//                    textColor: "blue";
//                    focus: true;
//                    validator: DoubleValidator {}
//                    onFocusChanged: {
//                        if (focus) {
//                            selectAll();
//                        }
//                    }
//                }
//                TextField {
//                    id: arcPosX;
//                    anchors.left: cardIDPosX.left;
//                    anchors.leftMargin: 0;
//                    anchors.top: arcRadiusText.top;
//                    width: 34;
//                    height: 20;
//                    selectByMouse: true;
//                    textColor: "green";
//                    text: "0.0";
//                    validator: DoubleValidator {
//                    }
//                    onFocusChanged: {
//                        if (focus) {
//                            selectAll();
//                        }
//                    }
//                }
//                TextField {
//                    id: arcPosY;
//                    anchors.left: arcPosX.right;
//                    anchors.leftMargin: 4;
//                    anchors.top: arcPosX.top;
//                    width: 34;
//                    height: 20;
//                    selectByMouse: true;
//                    textColor: "green";
//                    text: "0.0";
//                    validator: DoubleValidator {
//                    }
//                    onFocusChanged: {
                //                        if (focus) {
                //                            selectAll();
                //                        }
                //                    }
                //                }
            }
        }
    }

    Menu {
        id: contentMenu;
        MenuItem {
            text: "NULL";
            onTriggered: {
                mapItem.type = MapItemType.MapItemNULL;
            }
        }

        MenuItem {
            text: "XLine";
            onTriggered: {
                mapItem.type = MapItemType.MapItemXLine;
            }
        }

        MenuItem {
            text: "YLine";
            onTriggered: {
                mapItem.type = MapItemType.MapItemYLine;
            }
        }

        MenuItem {
            text: "Cross";
            onTriggered: {
                mapItem.type = MapItemType.MapItemCross;
            }
        }

        Menu {
            title: "del";
            MenuItem {
                text: "del2";

            }
                MenuItem {
                    text: "delabc";
                    onTriggered: {

                    }
                }
         }

    }
}
