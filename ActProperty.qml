import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import Qt.MapItemType 1.0

Rectangle{
    id: root;
    property int type: 0;
    property alias speedValue: speedCombobox.currentIndex;
    property alias turnValue: turnCombobox.currentIndex;
    property alias rotValue: rotCombobox.currentIndex;
    property alias platValue: platformCombobox.currentIndex;
    property alias oaValue: bzCombobox.currentIndex;
    property alias relayValue: relayCombobox.currentIndex;
    property alias modelV: speedCombobox.model;
    property alias modelT: turnCombobox.model;
    property alias modelR: rotCombobox.model;
    property alias modelP: platformCombobox.model;
    property alias modelB: bzCombobox.model;
    property alias modelRL: relayCombobox.model;
    property var oaJsonVal: ["[1,2]", "[2,2]"];
    property var rotJsonVal:[90,180];
    property var platJsonVal:[2,4];
    property var relayJsonVal:[2,4];
    Row {
        Rectangle {
            id: speedRect;
            width: 80;
            visible: (type == 2 || type == 3 || type == 4 || type == 5 ? true : false);
            Row {
                spacing: 8;
                Text {
                    y: 4;
                    text: qsTr("v:");
                }
                ComboBox {
                    width: 50;
                    id: speedCombobox;
                    model: [
                        "",
                        "1档",
                        "2档",
                        "3档",
                        "4档",
                        "5档"
                    ];
                }
            }
        }
        Rectangle {
            id: turnRect;
            anchors.left: speedRect.right;
            anchors.leftMargin: 2;
            width: 180;
            visible: (type == 2 || type == 3 ? true : false);
            Row {
                spacing: 8;
                Text {
                    y: 4;
                    text: qsTr("Turn:");
                }
                ComboBox {
                    width: 75;
                    id: turnCombobox;
                    model: [
                        "",
                        "左分支",
                        "右分支"
                    ];
                }
            }
        }
    }
    Rectangle {
        id: rotRect;
        width: 180;
        visible: (type == 6 || type == 7 ? true : false);
        Row {
            spacing: 8;
            Text {
                y: 4;
                text: qsTr("Rot: ");
            }
            ComboBox {
                width: 120;
                id: rotCombobox;
                model: [
                    "90°",
                    "180°"
                ];
            }
        }

    }
    Rectangle {
        id: platformRect;
        width: 180;
        visible: (type == 8 ? true : false);
        Row {
            spacing: 8;
            Text {
                y: 4;
                text: qsTr("Lf: ");
            }
            ComboBox {
                width: 120;
                id: platformCombobox;
                model: [
                    "升平台",
                    "降平台"
                ];
            }
        }
    }
    Rectangle {
        id: bzRect;
        width: 180;
        visible: (type == 9 ? true : false);
        Row {
            spacing: 8;
            Text {
                y: 4;
                text: qsTr("Bz: ");
            }
            ComboBox {
                width: 120;
                id: bzCombobox;
                model: [
                    "开避障",
                    "关避障"
                ];
            }
        }
    }
        Rectangle {
            id: relayRect;
            width: 100;
            anchors.left: parent.left
            anchors.leftMargin: 2
            visible: (type == 10 ? true : false);
            Row {
                spacing: 5;
                Text {
                    y: 4;
                    text: qsTr("Relay:");
                }
                ComboBox {
                    width: 70;
                    id: relayCombobox;
                    model: [
                        "闭合",
                        "断开"
                    ];
                }
            }


    }

}



