import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
Rectangle {
    id: root;
    clip: true;
    Component {
        id:pathDelegate
        Item {
            id:wrapper
            width: parent.width;
            height: 20;
            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    console.log("click: " + index)
                    wrapper.ListView.view.currentIndex = index;
                }
            }
            RowLayout {
                anchors.left: parent.left;
                anchors.verticalCenter: parent.verticalCenter;
                spacing: 8;
                Text {
                    id: col1;
                    text: Idx;
                    color: wrapper.ListView.isCurrentItem ? "red" : "black";
                    font.pixelSize: wrapper.ListView.isCurrentItem ? 15 : 12;
                    Layout.preferredWidth: 30;
                }
                Text {
                    text: ID;
                    color: wrapper.ListView.isCurrentItem ? "red" : "black";
                    font.pixelSize: wrapper.ListView.isCurrentItem ? 15 : 12;
                    Layout.preferredWidth: 50;
                }
                Text {
                    text: Act;
                    color: wrapper.ListView.isCurrentItem ? "red" : "black";
                    font.pixelSize: wrapper.ListView.isCurrentItem ? 15 : 12;
                    Layout.fillWidth: true;
                    Layout.preferredWidth: 80;
                }
                Text {
                    text: Remark;
                    color: wrapper.ListView.isCurrentItem ? "red" : "black";
                    font.pixelSize: wrapper.ListView.isCurrentItem ? 15 : 12;
                    Layout.fillWidth: true;
                }
            }
        }
    }
    Component {
        id: headerView;
        Item {
            width: parent.width;
            height: 20;

            RowLayout {
                anchors.left: parent.left;
                anchors.verticalCenter: parent.verticalCenter;
                Text {
                    text: "Idx";
                    font.pixelSize: 12;
                    Layout.fillWidth: true;
                    Layout.preferredWidth: 30;
                }
                Text {
                    text: "ID";
                    font.pixelSize: 12;
                    Layout.fillWidth: true;
                    Layout.preferredWidth: 50;
                }
                Text {
                    text: "Act";
                    font.pixelSize: 12;
                    Layout.fillWidth: true;
                    Layout.preferredWidth: 80;
                }
                Text {
                    text: "Remark";
                    font.pixelSize: 12;
                    Layout.fillWidth: true;
                }
            }
        }
    }
    Component {
        id: footerView;
        Item {
            id: footerRootItem;
            width: parent.width;
            height: 24;
            Button {
                id: upmoveButton;
                anchors.right: parent.right;
                anchors.verticalCenter: parent.verticalCenter;
                width: 20
                height: 20
                text: "↑";
            }
            Button {
                id: downmoveButton;
                anchors.right: upmoveButton.left;
                anchors.verticalCenter: parent.verticalCenter;
                width: 20
                height: 20
                text: "↓";
            }
        }
    }
    Component {
        id: pathModel;
        ListModel {
            ListElement {
                Idx: "128";
                ID: "123456";
                Act: "前行";
                Remark: "V: 2, T: 右";
            }
            ListElement {
                Idx: "100";
                ID: "987456";
                Act: "顺时针旋转";
                Remark: "180";
            }
        }
    }
    ListView {
        id: listView;
        anchors.fill: parent;
        delegate: pathDelegate;
        header: headerView;
        footer: footerView;
        model: pathModel.createObject(listView);
        focus: true;
        highlight: Rectangle {
            color: "lightblue"
        }
        highlightFollowsCurrentItem: true;
        onCurrentIndexChanged: {
        }

        Component.onCompleted: {
        }
    }
}
