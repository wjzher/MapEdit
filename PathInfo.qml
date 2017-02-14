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
    FileDialog {
        id: pathListFileDialog;
        title: "Please choose a file";
        nameFilters: ["Json Files (*.json)"];
        property int opt: 0;    // 0 new, 1 open, 2 save
        onAccepted: {
            var file = new String(pathListFileDialog.fileUrl);
            //remove file:///
            if (Qt.platform.os == "windows"){
                file = file.slice(8);
            } else {
                file = file.slice(7);
            }
            if (opt == 1) {
                console.log("map file open. " + file);
                var v = pathJson.openJsonFile(file);
                console.log(v);
                listView.update(v);
            } else if (opt == 2) {
            }
        }
    }
    PathJson {
        id: pathJson;
        mode: 1;
    }
    ActProperty {
        id: actProperty;
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
                    var v, pv, pt, pr, pp, po, pc, prl;
                    //console.log("click: " + index)
                    wrapper.ListView.view.currentIndex = index;
                    v = listView.model.get(index).Act;
                    pv = listView.model.get(index).Remark.substring(2,4);
                    pt = listView.model.get(index).Remark.substring(7,10);
                    pr = listView.model.get(index).Remark.substring(4,8);
                    pp = listView.model.get(index).Remark.substring(3,6);
                    po = listView.model.get(index).Remark.substring(3,6);
                    pc = listView.model.get(index).Remark.substring(7,9);
                    prl = listView.model.get(index).Remark.substring(16,18);
                    //console.log (listView.model.get(index).Remark.substring(listView.model.get(index).Remark.indexOf(":", 2)));
                    console.log (listView.model.get(index).Remark.substring("v:", 4));
                    function speedIndex(s) {
                        if(s == "1档") {
                            actProperty.speedValue = 1;
                        } if(s == "2档") {
                            actProperty.speedValue = 2;
                        } if(s == "3档") {
                            actProperty.speedValue = 3;
                        } if(s == "4档") {
                            actProperty.speedValue = 4;
                        } if(s == "5档") {
                            actProperty.speedValue = 5;
                        } else {
                            actProperty.speedValue = 0;
                        }
                    }
                    function turnIndex(t) {
                        if (t == "左分支") {
                            actProperty.turnValue = 1;
                        } if (t == "右分支") {
                            actProperty.turnValue = 2;
                        } else {
                            actProperty.turnValue = 0;
                        }
                    }
                    function rotIndex(t) {
                        if (t == "90°") {
                            actProperty.rotValue = 0;
                        } if (t == "180°") {
                            actProperty.rotValue = 1;
                        }
                    }
                    function platIndex(t) {
                        if (t == "升平台") {
                            actProperty.platValue = 0;
                        } if (t == "降平台") {
                            actProperty.platValue = 1;
                        }
                    }
                    function oaIndex(t) {
                        if (t == "开避障") {
                            actProperty.oaValue = 0;
                        } if (t == "关避障") {
                            actProperty.oaValue = 1;
                        }
                    }
                    function chargeIndex(t) {
                        if (t == "充电") {
                            actProperty.chargeValue = 0;
                        } if (t == "断电") {
                            actProperty.chargeValue = 1;
                        }
                    }
                    function relayIndex(t) {
                        if (t == "闭合") {
                            actProperty.relayValue = 0;
                        } if (t == "断开") {
                            actProperty.relayValue = 1;
                        }
                    }
                    if(v == "前行") {
                        actCombo.index = 2;
                        speedIndex(pv);
                        turnIndex(pt);
                    } if(v == "后退") {
                        actCombo.index = 3;
                        speedIndex(pv);
                        turnIndex(pt);
                    } if(v == "顺时针旋转") {
                        actCombo.index = 4;
                        rotIndex(pr);
                    } if(v == "逆时针旋转") {
                        actCombo.index = 5;
                        rotIndex(pr);
                    } if(v == "平台动作") {
                        actCombo.index = 6;
                        platIndex(pp);
                    } if(v == "避障") {
                        actCombo.index = 7;
                        oaIndex(po);
                    } if(v == "充电") {
                        actCombo.index = 8;
                        chargeIndex(pc);
                        relayIndex(prl);
                    }
                }
                onDoubleClicked: {
                    console.log("double click: " + index);
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
            Button {
                id: savePathButton;
                anchors.right: downmoveButton.left;
                anchors.rightMargin: 8;
                text: "Save";
                onClicked: {
                    console.log(listView.model.get(0));
                    var v = listView.model.get(0);
                    console.log(v.Idx);
                    pathJson.saveJsonFile("", listView.model.get(0));

                }
            }
            Button {
                id: openPathButton;
                anchors.right: savePathButton.left;
                anchors.rightMargin: 8;
                text: "Open";
                onClicked: {
                    pathListFileDialog.opt = 1;
                    pathListFileDialog.open();
                }
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
                Remark: "V:2档,T:右分支";
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
        function add(v) {
            if (listView.count == 0
                || listView.currentIndex == (listView.count - 1)) {
                listView.model.append(v);
            } else {
                listView.model.insert(listView.currentIndex + 1, v);
            }
        }
        function revise(v) {
            listView.model.set(listView.currentIndex, v);
        }
        function act(m) {
            var p;
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
                return 0;
            }
        }
        function remark(m) {
            var p;
            if(m.act == 2) {
                return 0;
            } if ((m.act == 3) || (m.act == 4)) {
                if(m.v) {
                    if(m.turn) {
                        p = "v:"+actProperty.modelV[m.v] + ",T:"+actProperty.modelT[m.turn];
                    } if (!m.turn) {
                        p = "v:"+actProperty.modelV[m.v];
                    }
                } else if (m.turn) {
                    p = "T:"+actProperty.modelT[m.turn];
                } else {
                    return 0;
                }
                return p;
            } if (m.act == 7 || m.act == 8) {
                if (m.rot == 90) {
                    p =  "rot:"+actProperty.modelR[0];
                } if (m.rot == 180) {
                    p =  "rot:"+actProperty.modelR[1];
                }
                return p;
            } if (m.act == 17) {
                if (m.val == 2) {
                    p = "lf:"+actProperty.modelP[0];
                } if (m.val == 4) {
                    p = "lf:"+actProperty.modelP[1];
                } return p;
            } if (m.act == 20) {
                if ((m.bz[0] == 1) && (m.bz[0] == 2)) {
                    p = "oa:"+actProperty.modelB[0];
                } if ((m.bz[0] == 2) && (m.bz[0] == 2)) {
                    p = "oa:"+actProperty.modelB[1];
                } else {
                    return 0;
                } return p;
            } else {
                return 0;
            }
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
