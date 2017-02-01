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
        length: 100;
        anchors.left: parent.left;
        anchors.top: parent.top;
        anchors.margins: 4;
        type: MapItemType.MapItemCross;
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
            text: "Add";
            onTriggered: {
                console.log("Trig Add.");
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
