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
    height: 600;
    id: rootItem;
    color: "#EEEEEE";
    title: qsTr("Hello World")

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
//    MapItem {
//        id: mapItem;
//        length: 100;
//        anchors.left: parent.left;
//        anchors.top: parent.top;
//        anchors.margins: 4;
//        type: MapItemType.MapItemYUMStop;
//        color: "red";
//        isCard: true;
//        text: "248";
//        cardPos: [length * 0.3, length * 0.5];
//        Component.onCompleted: {
//        }
//        onClicked: {
//            contentMenu.popup();
//        }
//    }
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
            function setItemType(type) {
                mapGrid.mapGrid.currentItem.type = type;
            }
            function setItemIsCard(isCard) {
                mapGrid.mapGrid.currentItem.isCard = isCard;
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
                    radioTypeYline.checked = true;
                    radioTypeYline.forceActiveFocus();
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
                cardIDPosX.text = item.cardPos[0];
                cardIDPosY.text = item.cardPos[1];
            }
            onCurrentIndexChanged: {
                console.log("mapGrid index changed. " + mapGrid.mapGrid.currentIndex);
                showItemSettings();
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
                    console.log("is Card clicked. ", checked);
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
                    console.log("carID editing finished.");
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
            }

            CheckBox {
                id: arcCheck;
                anchors.top: cardCheck.bottom;
                anchors.topMargin: 8;
                text: "Arc Exsit?";
                onClicked: {
                    console.log("is Arc clicked. ", checked);
                }
            }

            TextField {
                id: arcRadiusText;
                anchors.left: cardIDText.left;
                anchors.leftMargin: 0;
                anchors.top: arcCheck.top;
                anchors.topMargin: -2;
                width: 60;
                height: 20;
                placeholderText: qsTr("Radius");
                selectByMouse: true;
                textColor: "blue";
                focus: true;
                validator: DoubleValidator {}
                onFocusChanged: {
                    if (focus) {
                        selectAll();
                    }
                }
            }
            TextField {
                id: arcPosX;
                anchors.left: cardIDPosX.left;
                anchors.leftMargin: 0;
                anchors.top: arcRadiusText.top;
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
            }
            TextField {
                id: arcPosY;
                anchors.left: arcPosX.right;
                anchors.leftMargin: 4;
                anchors.top: arcPosX.top;
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
