import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import Qt.PathJson 1.0
import QtQuick.Dialogs 1.2

Rectangle {
    id: root;
    clip: true;
    property alias listView: listView;
    property alias pathJson: pathJson;
    FileDialog {
        id: pathListFileDialog;
        property var fileName: "";
        title: "Please choose a file";
        nameFilters: ["Json Files (*.json)"];
        property int opt: 0;    // 0 new, 1 open, 2 save
        //selectExisting: opt == 2 ? false : true;
        onAccepted: {
            var file = new String(pathListFileDialog.fileUrl);
            //remove file:///
            if (Qt.platform.os == "windows"){
                file = file.slice(8);
            } else {
                file = file.slice(7);
            }
            if (opt == 1) {
                fileName = file;
                console.log("map file open. " + file);
                var v = pathJson.openJsonFile(file);
                console.log(v);
                listView.update(v);
            } else if (opt == 2) {
                fileName = file;
                pathJson.saveJsonFile(fileName);
            }
        }
    }
    PathJson {
        id: pathJson;
        mode: 1;
    }

    Component {
        id:pathDelegate
        Item {
            id:wrapper
            width: parent.width;
            height: 20;
            MouseArea {
                anchors.fill: parent;
                onClicked: {
                    wrapper.ListView.view.currentIndex = index;
                }
                onDoubleClicked: {
                    var json = JSON.parse(pathJson.exportList());
                    if (index >= json.length) {
                        return;
                    }
                    var m = json[index];
                    console.log("click: " + index);
                    actCombo.index = listView.jsonact(m);
                    if ((m.act == 3) || (m.act == 4)) {
                        actProperty.speedValue = listView.jsonspeed(m);
                        actProperty.turnValue = listView.jsonturn(m);
                    } if ((m.act == 7) || (m.act == 8)) {
                        actProperty.rotValue = listView.jsonrot(m);
                    } if (m.act == 17) {
                        actProperty.platValue = listView.jsonplat(m);
                    } if (m.act == 20) {
                        actProperty.oaValue = listView.jsonoa(m);
                    }
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
                onClicked: {
                    var item = listView.currentIndex;
                    listView.model.move(item, item - 1, 1);
                    pathJson.moveItem(item,item - 1);
                }
            }
            Button {
                id: downmoveButton;
                anchors.right: upmoveButton.left;
                anchors.verticalCenter: parent.verticalCenter;
                width: 20
                height: 20
                text: "↓";
                onClicked: {
                    var item = listView.currentIndex;
                    listView.model.move(item, item + 1, 1);
                    pathJson.moveItem(item,item + 1);
                }
            }
            Button {
                id: savePathButton;
                anchors.right: downmoveButton.left;
                anchors.rightMargin: 8;
                text: "Save";
                onClicked: {
                    if (pathListFileDialog.fileName == "") {
                        pathListFileDialog.selectExisting = false;
                        pathListFileDialog.opt = 2;
                        pathListFileDialog.open();
                    } else {
                        pathJson.saveJsonFile(pathListFileDialog.fileName);
                    }
                }
            }
            Button {
                id: openPathButton;
                anchors.right: savePathButton.left;
                anchors.rightMargin: 8;
                text: "Open";
                onClicked: {
                    pathListFileDialog.opt = 1;
                    pathListFileDialog.selectExisting = true;
                    pathListFileDialog.open();
                }
            }
        }
    }
    Component {
        id: pathModel;
        ListModel {
//            ListElement {
//                Idx: "128";
//                ID: "123456";
//                Act: "前行";
//                Remark: "V:2档,T:右分支";
//            }
//            ListElement {
//                Idx: "100";
//                ID: "987456";
//                Act: "顺时针旋转";
//                Remark: "180";
//            }
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

        function add(idx, v) {
            console.log("count " + listView.count + " " + listView.currentIndex);
            if (listView.count == 0) {
                pathJson.insertItem(0, v);
            } else {
                pathJson.insertItem(listView.currentIndex + 1, v);
            }
            var json = JSON.parse(v);
            var listElement;
            listElement = {
                    "Idx":idx.toString(),
                    "ID":json.id.toString(),
                    "Act":act(json.act),//actCombo.model[actCombo.index],
                    "Remark":remark(json)//pathSettingsGroup.model.toString()
                };
            if (listView.count == 0
                || listView.currentIndex == (listView.count - 1)) {
                listView.model.append(listElement);
            } else {
                listView.model.insert(listView.currentIndex + 1, listElement);
            }
            listView.currentIndex++;
        }
        function revise(v) {
            var json = JSON.parse(v);
            var listElement;
            listElement = {
//                    "Idx":idx.toString(),
//                    "ID":json.id.toString(),
                    "Act":act(json.act),
                    "Remark":remark(json)
                };
            listView.model.set(listView.currentIndex, listElement);
            pathJson.modifyItem(listView.currentIndex,v);
        }
//        function revise(v) {
//            listView.model.set(listView.currentIndex, v);
//            pathJson.modifyItem(v);
//        }
        function  del(v) {
            listView.model.remove(v);
            pathJson.deleteItem(v);
        }
        function act(m) {
            var p = "";
            if (m == 2) {
                p = actCombo.model[1];
                return p;
            } if (m == 3) {
                p = actCombo.model[2];
                return p;
            } if (m == 4) {
                p = actCombo.model[3];
                return p;
            } if (m == 7) {
                p = actCombo.model[4];
                return p;
            } if (m == 8) {
                p = actCombo.model[5];
                return p;
            } if (m == 17) {
                p = actCombo.model[6];
                return p;
            } if (m == 20) {
                p = actCombo.model[7];
                return p;
            } else {
                return "";
            }
        }
        function remark(m) {
            var p = "";
            if(m.act == 2) {
                return "";
            } if ((m.act == 3) || (m.act == 4)) {
                if(m.v) {
                    if(m.turn) {
                        p = "v:"+actProperty.modelV[m.v] + ",T:"+actProperty.modelT[m.turn];
                    } if (!m.turn) {
                        p = "v:"+actProperty.modelV[m.v];
                    }
                    return p;
                } else if (m.turn) {
                    p = "T:"+actProperty.modelT[m.turn];
                } else {
                    return "";
                }
                return p;
            } if ((m.act == 7) || (m.act == 8)) {
                if (m.rot == 90) {
                    p =  "rot:"+actProperty.modelR[0];
                    return p;
                } if (m.rot == 180) {
                    p =  "rot:"+actProperty.modelR[1];
                    return p;
                } else {
                    return "";
                }
            } if (m.act == 17) {
                if (m.val == 2) {
                    p = "lf:"+actProperty.modelP[0];
                } if (m.val == 4) {
                    p = "lf:"+actProperty.modelP[1];
                } return p;
            } if (m.act == 20) {
                if ((m.bz[0] == 1) && (m.bz[1] == 2)) {
                    p = "oa:"+actProperty.modelB[0];
                    return p;
                } if ((m.bz[0] == 2) && (m.bz[1] == 2)) {
                    p = "oa:"+actProperty.modelB[1];
                } else {
                    return "";
                } return p;
            } else {
                return "";
            }
        }
        function jsonact(m) {
            var p = 0;
            if (m.act == 2) {
                p = 1;
            } if ((m.act == 3) || (m.act == 4)) {
                p = m.act - 1;
            } if ((m.act == 7) || (m.act == 8)) {
                p = m.act - 3;
            } if (m.act == 17) {
                p = 6;
            } if (m.act == 20) {
                p = 7;
            } return p;
        }
        function jsonspeed(m) {
            var p = 0;
            if (m.v) {
                p = m.v;
            } else {
                p = 0;
            } return p;
        }
        function jsonturn(m) {
            var p = 0;
            if (m.turn) {
                p = m.turn;
            } else {
                p = 0;
            } return p;
        }
        function jsonrot(m) {
            var p = 0;
            if (m.rot == 90) {
                p = 0;
            } if (m.rot == 180) {
                p = 1;
            } return p;
        }
        function jsonplat(m) {
            var p = 0;
            if (m.val == 2) {
                p = 0;
            } if (m.val == 4) {
                p = 1;
            } return p;
        }
        function jsonoa(m) {
            var p = 0;
            if ((m.bz[0] == 1) && (m.bz[0] == 2)) {
                p = 0;
            } if ((m.bz[0] == 2) && (m.bz[0] == 2)) {
                p = 1;
            } return p;
        }

        function update(v) {
            var json = JSON.parse(v);
            var i;
            listView.model.clear();
            for (i = 0; i < json.length; i++) {
                console.log("id:" + json[i].id);
                var listElement;
                listElement = {
                        "Idx":mapData.getItemIndexByCardId(json[i].id).toString(),
                        "ID":json[i].id.toString(),
                        //"Act":json[i].act.toString(),
                        "Act":act(json[i].act),
                        "Remark":remark(json[i])
                    };
                listView.model.append(listElement);
            }
        }

        Component.onCompleted: {
        }
    }
}
