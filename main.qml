import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import Qt.MapItemType 1.0

Window {
    visible: true
    width: 800;
    height: 800;
    id: rootItem;
    color: "#EEEEEE";
    title: qsTr("Hello World")

    onWidthChanged: {
    }
    MapItem {
        id: mapItem;
        length: 100;
        anchors.left: parent.left;
        anchors.top: parent.top;
        anchors.margins: 4;
        type: MapItemType.MapItemYUMStop;
        color: "red";
        isCard: true;
        text: "248";
        cardPos: [length * 0.3, length * 0.5];
        Component.onCompleted: {
        }
        onClicked: {
            contentMenu.popup();
        }
    }
    MapGrid {
        width: 600;
        height: 600;
        anchors.centerIn: parent;
        rows: 20;
        columns: 20;
        scaleGrid: 1.5;
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
