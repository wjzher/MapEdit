import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import Qt.UdpServer 1.0
import QtQuick.Controls 1.4

Window {
    id: root;
    width: 500;
    height: 360;
    title: "AGV Control";
    color: "#EEEEEE";
    modality: Qt.WindowNoState;
    property alias udpServer: udpServer;

    function getCurrentCardId() {
        return parseInt(agvPrepos.text);
    }
    Item {
        focus: true
        Keys.onPressed: {
            switch(event.key) {
            case Qt.Key_Up:
                mfButton.clickedCallBack();
                break;
            case Qt.Key_Down:
                mbButton.clickedCallBack();
                break;
            case Qt.Key_Left:
                leftMoveButton.clickedCallBack();
                break;
            case Qt.Key_Right:
                rightMoveButton.clickedCallBack();
                break;
            case Qt.Key_Equal:
                rotateview.clickedCallBack();
                break;
            case Qt.Key_Delete:
                delButton.clickedCallBack();
                break;
            case Qt.Key_Insert:
                loadButton.clickedCallBack();
                break;
            case Qt.Key_Home:
                startButton.clickedCallBack();
                break;
            case Qt.Key_End:
                esButton.clickedCallBack();
                break;
            case Qt.Key_Q:
                rcButton.clickedCallBack();
                break;
            case Qt.Key_W:
                rccButton.clickedCallBack();
                break;
            case Qt.Key_R:
                rightButton.clickedCallBack();
                break;
            case Qt.Key_L:
                leftButton.clickedCallBack();
                break;
            case Qt.Key_S:
                stopButton.clickedCallBack();
                break;
            case Qt.Key_A:
            case Qt.Key_Space:
                astopButton.clickedCallBack();
                break;
            case Qt.Key_U:
                lfupButton.clickedCallBack();
                break;
            case Qt.Key_M:
                lfmButton.clickedCallBack();
                break;
            case Qt.Key_D:
                lfdButton.clickedCallBack();
                break;
            case Qt.Key_F1:
                oaButton.clickedCallBack();
                break;
            case Qt.Key_F2:
                csButton.clickedCallBack();
                break;
            default:
                return;
            }
        }
    }

    UdpServer {
        id: udpServer;
        property int cmdInf: 20000;
        property int initFlag: 0;
        function paramJson(cmd) {
            var v = "{\"agvcmd\":\"";
            v += cmd;
            v += "\"}";
            return v;
        }
        function paramAgvId() {
            return "{\"agvid\":\"1\"}";
        }
        function cmdMf(speed) {
            var v = paramJson("mf " + speed);
            sendCommand(cmdInf, v);
        }
        function cmdMb(speed) {
            var v = paramJson("mb " + speed);
            sendCommand(cmdInf, v);
        }
        function cmdMl(speed) {
            var v = paramJson("ml " + speed);
            sendCommand(cmdInf, v);
        }
        function cmdMr(speed) {
            var v = paramJson("mr " + speed);
            sendCommand(cmdInf, v);
        }
        function cmdStop() {
            var v = paramJson("s");
            sendCommand(cmdInf, v);
        }
        function cmdAStop() {
            var v = paramJson("a");
            sendCommand(cmdInf, v);
        }
        function cmdTl() {
            var v = paramJson("tl");
            sendCommand(cmdInf, v);
        }
        function cmdTr() {
            var v = paramJson("tr");
            sendCommand(cmdInf, v);
        }
        function cmdRc() {
            var v = paramJson("rc");
            sendCommand(cmdInf, v);
        }
        function cmdRc2() {
            var v = paramJson("rc2");
            sendCommand(cmdInf, v);
        }
        function cmdRcc() {
            var v = paramJson("rcc");
            sendCommand(cmdInf, v);
        }
        function cmdRcc2() {
            var v = paramJson("rcc2");
            sendCommand(cmdInf, v);
        }
        function cmdOAOn() {
            var v = paramJson("oa 1");
            sendCommand(cmdInf, v);
        }
        function cmdOAOff() {
            var v = paramJson("oa 0");
            sendCommand(cmdInf, v);
        }
        function cmdLiftUp() {
            var v = paramJson("lf 1");
            sendCommand(cmdInf, v);
        }
        function cmdLiftMid() {
            var v = paramJson("lf 2");
            sendCommand(cmdInf, v);
        }
        function cmdLiftDown() {
            var v = paramJson("lf 0");
            sendCommand(cmdInf, v);
        }
        function cmdCSOn() {
            var v = paramJson("cs 1");
            sendCommand(cmdInf, v);
        }
        function cmdCSOff() {
            var v = paramJson("cs 0");
            sendCommand(cmdInf, v);
        }
        function cmdDEList() {
            var v = paramJson("dellist");
            sendCommand(cmdInf, v);
        }
        function cmdEStop() {
            var v = paramAgvId();
            sendCommand(1005, v);
        }
        function cmdStart() {
            var v = paramAgvId();
            sendCommand(1003, v);
        }
        function initActView() {
            stopButton.color = "transparent";
            mfButton.color = "transparent";
            mbButton.color = "transparent";
            leftMoveButton.color = "transparent";
            rightMoveButton.color = "transparent";
            rcButton.color = "transparent";
            rccButton.color = "transparent";
            astopButton.color = "transparent";
            astopButton.text = "T";
        }
        function agvShowStatus(status) {
            var json = JSON.parse(status);
            var m = json.infos;
            var n = json.alarm;
            console.log("agvShowStatus = " + m.sta);
            initActView();
            switch (m.sta) {
            case 0:
                stopButton.color = "aquamarine";
                break;
            case 1:
                mfButton.color = "aquamarine"
                break;
            case 2:
                mbButton.color = "aquamarine"
                break;
            case 3:
                leftMoveButton.color = "aquamarine"
                break;
            case 4:
                rightMoveButton.color = "aquamarine"
                break;
            case 5:
                rcButton.color = "aquamarine";
                break;
            case 6:
                rccButton.color = "aquamarine";
                break;
            case 7:
                agvActive.text = "⚠"
                break;
            case 8:
                astopButton.text = "T"
                astopButton.color = "aquamarine"
                break;
            case 9:
                astopButton.text = "t"
                astopButton.color = "aquamarine"
                break;
            default:
                break;
            }
            switch (m.turnto) {
            case 1:
                leftButton.color = "aquamarine"
                rightButton.color = "transparent"
                break;
            case 2:
                leftButton.color = "transparent"
                rightButton.color = "aquamarine"
                break;
            default:
                break;
            }
            if ((m.sta == 1) || (m.sta == 2) || (m.sta == 3)  || (m.sta == 4)) {
            switch (m.v) {
            case 0:
                speedview.text = "0";
                break;
            case 1:
                speedview.text = "1";
                break;
            case 2:
                speedview.text = "2";
                break;
            case 3:
                speedview.text = "3";
                break;
            case 4:
                speedview.text = "4";
                break;
            case 5:
                speedview.text = "5";
                break;
            default:
                break;
            }
            } else {
                speedview.text = "0";
            }
            switch (m.liftsta) {
            case 1:
                lfupButton.color = "aquamarine"
                lfdButton.color = "transparent"
                break
            case 2:
                lfdButton.color = "aquamarine"
                lfupButton.color = "transparent"
                break;
            default:
                break;
            }
            switch (m.bz[0]) {
            case 0:
                //oaview.color = "aquamarine";
                oaButton.color = "aquamarine";
                oaButton.oa = 0;
                if (initFlag == 0) {
                    oaButton.onOff = 1;
                }
                break
            case 1:
                //oaview.color = "#EEEEEE";
                oaButton.color = "transparent";
                oaButton.oa = 1;
                if (initFlag == 0) {
                    oaButton.onOff = 0;
                }
                break;
            default:
                break;
            }
            switch (m.charge) {
            case 0:
                //csview.color = "#EEEEEE";
                csButton.color = "transparent";
                csButton.cs = 0;
                if (initFlag == 0) {
                    csButton.onOff = 0;
                }
                break
            case 1:
                //csview.color = "aquamarine";
                csButton.color = "aquamarine"
                csButton.cs = 0;
                if (initFlag == 0) {
                    csButton.onOff = 1;
                }
                break;
            default:
                break;
            }
            agvVoltage.text = m.voltage + "v";
            agvPrepos.text = m.prepos;
            agvNextpose.text = m.nextpos;
            if (n.far) {
                farView.color = "aquamarine";
            } else {
                farView.color = "#EEEEEE";
            }
            if (n.near) {
                nearView.color = "aquamarine";
            } else {
                nearView.color = "#EEEEEE";
            }
            if (n.touch) {
                machView.color = "aquamarine";
            } else {
                machView.color = "#EEEEEE";
            }
            if (!n.dc) {
                dcNomal.color = "aquamarine";
                dcAlarm.color = "#EEEEEE";
            } else {
                dcAlarm.color = "red";
                dcNomal.color = "#EEEEEE";
            }
            if (!n.driver) {
                moterNomal.color = "aquamarine";
                moterAlarm.color = "#EEEEEE";
            } else {
                moterAlarm.color = "red";
                moterNomal.color = "#EEEEEE";
            }
            if (!n.elec) {
                elecNomal.color = "aquamarine";
                elecAlarm.color = "#EEEEEE";
            } else {
                elecAlarm.color = "red";
                elecNomal.color = "#EEEEEE";
            }
            if (!n.lift) {
                liftNomal.color = "aquamarine";
                liftAlarm.color = "#EEEEEE";
            } else {
                liftAlarm.color = "red";
                liftNomal.color = "#EEEEEE";
            }
            if (!n.chargecommu) {
                chargeNomal.color = "aquamarine";
                chargeAlarm.color = "#EEEEEE";
            } else {
                chargeAlarm.color = "red";
                chargeNomal.color = "#EEEEEE";
            }
            if (!n.rotate) {
                rotateNomal.color = "aquamarine";
                rotateAlarm.color = "#EEEEEE";
            } else {
                rotateAlarm.color = "red";
                rotateNomal.color = "#EEEEEE";
            }
            if (!n.lowpower) {
                lowPowerNomal.color = "aquamarine";
                lowPowerAlarm.color = "#EEEEEE";
            } else {
                lowPowerAlarm.color = "red";
                lowPowerNomal.color = "#EEEEEE";
            }
            if (!n.roller) {
                rollerNomal.color = "aquamarine";
                rollerAlarm.color = "#EEEEEE";
            } else {
                rollerAlarm.color = "red";
                rollerNomal.color = "#EEEEEE";
            }
            if (!n.inside) {
                masterCtrNomal.color = "aquamarine";
                masterCtrAlarm.color = "#EEEEEE";
            } else {
                masterCtrAlarm.color = "red";
                masterCtrNomal.color = "#EEEEEE";
            }
            if (!n.emergency) {
                estopNomal.color = "aquamarine";
                estopAlarm.color = "#EEEEEE";
            } else {
                estopAlarm.color = "red";
                estopNomal.color = "#EEEEEE";
            }
            if (!n.netbreak) {
                netInterruptNomal.color = "aquamarine";
                netInterruptAlarm.color = "#EEEEEE";
            } else {
                netInterruptAlarm.color = "red";
                netInterruptNomal.color = "#EEEEEE";
            }
        }
        function cmdLoadPath() {
            var v = pathList.pathJson.exportParamObject();
            console.log("LoadPath: " + v);
            sendCommand(1007, v);
        }
        onAgvCardIdChanged: {
            mapGrid.updateAgvCardId(ip, lastId, cardId);
        }

        onAgvStatusChanged: {
            console.log("status changed " + inf + " " + status);
            switch (parseInt(inf)) {
            case 20000:
                agvInfo.text = "AGV运动命令应答";
                break;
            case 1001:
                agvInfo.text = "AGV信息总召";
                break;
            case 1003:
                agvInfo.text = "AGV启动应答";
                break;
            case 1005:
                agvInfo.text = "AGV急停应答";
                break;
            case 1007:
                agvInfo.text = "AGV运动应答";
                break;
            case 5001:
                console.log("5001 ...");
                agvShowStatus(status);
                initFlag = 1;
                break;
            }
        }
        onAgvAddressChanged: {
            console.log("address changed " + ip);
            agvipCombobox.model.append({text: ip});
            initFlag = 0;
            mapGrid.addAgvModel(ip);
        }
        onAgvStatusChanged2: {
            //console.log("agv status changed " + ip);
            mapGrid.agvUpdateStatus(ip, status);
        }
    }

    Row{
        id: row;
        anchors.fill: parent;
        anchors.margins: 8;
        spacing: 4;
        GroupBox{
            id: agvConsole;
            title: "agv console";
            height: root.height - 12;
            width: 290;
            Column{
                spacing: 10
                Row {
                    spacing: 8;
                    Text {
                        y: 6;
                        text: qsTr("IP:");
                    }
                    ComboBox {
                        width: 140;
                        id: agvipCombobox;
                        onCountChanged: {
                            if (count == 1) {
                                console.log("agv ip count changed " + currentIndex + " " + model.get(currentIndex).text);
                                udpServer.currentIp = model.get(currentIndex).text;
                            }
                        }

                        model: ListModel {
                            id: model;
//                            ListElement {
//                                text: "192.168.2.xx";
//                            }
                        }
//                        Component.onCompleted: {
//                            mapGrid.addAgvModel("192.168.2.xx");
//                        }

                        onCurrentIndexChanged: {
                            if (model.get(currentIndex) == null) {
                                return;
                            }
                            console.log("agv ip changed " + currentIndex + " " + model.get(currentIndex).text);
                            udpServer.currentIp = model.get(currentIndex).text;
                        }
                    }
                }

                Row {
                    spacing: 4;
                    Column {
                        spacing: 4;
                        FlatButton {
                            id: speedview;
                            property int dir: 0;    // 0 front 1 back  2 left  3 right
                            text: "0";
                            font.pointSize: 12;
                            toolTipText: qsTr("下发速度");
                            textColor: "black";
                            function clear() {
                                dir = 0;
                                text = 0;
                            }
                            function move() {
                                if (text == 0) {
                                    udpServer.cmdStop();
                                } else {
                                    if (dir == 0) {
                                        udpServer.cmdMf(text);
                                        console.log("dir = " + dir);
                                    } else if (dir == 1) {
                                        udpServer.cmdMb(text);
                                        console.log("dir = " + dir);
                                    } else if (dir == 2) {
                                        udpServer.cmdMl(text);
                                        console.log("dir = " + dir);
                                    } else if (dir == 3) {
                                        udpServer.cmdMr(text);
                                        console.log("dir = " + dir);
                                    }
                                }
                            }

                            function up(){
                                if (dir == 0 || speedview.text == 0) {
                                    if (speedview.text < 5) {
                                        speedview.text++;
                                        dir = 0;
                                        move();
                                    }
                                } else if (dir == 2 || dir == 3) {
                                        return 0;
                                } else {
                                    if(speedview.text > 0) {
                                        speedview.text--;
                                        if (speedview.text == 0) {
                                            dir = 0;
                                        }
                                        move();
                                    }
                                }
                            }
                            function down(){
                                if (dir == 1 || speedview.text == 0) {
                                    if (speedview.text < 5) {
                                        speedview.text++;
                                        dir = 1;
                                        move();
                                    }
                                } else if (dir == 2 || dir == 3) {
                                    return 0;
                                }else {
                                    if (speedview.text > 0) {
                                        speedview.text--;
                                        if (speedview.text == 0) {
                                            dir = 1;
                                        }
                                        move();
                                    }
                                }
                            }
                            function left(){
                                if (dir == 2 || speedview.text == 0) {
                                    if (speedview.text < 5) {
                                        speedview.text++;
                                        dir = 2;
                                        move();
                                    }
                                } else if (dir == 0 || dir == 1) {
                                    return 0;
                                } else {
                                    if (speedview.text > 0) {
                                        speedview.text--;
                                        if (speedview.text == 0) {
                                            dir = 2;
                                        }
                                        move();
                                    }
                                }
                            }
                            function right(){
                                if (dir == 3 || speedview.text == 0) {
                                    if (speedview.text < 5) {
                                        speedview.text++;
                                        dir = 3;
                                        move();
                                    }
                                } else if (dir == 0 || dir == 1) {
                                    return 0;
                                } else {
                                    if (speedview.text > 0) {
                                        speedview.text--;
                                        if (speedview.text == 0) {
                                            dir = 3;
                                        }
                                        move();
                                    }
                                }
                            }
                        }
                        FlatButton {
                            id: mfButton;
                            text: "↑";
                            function clickedCallBack(){
                                speedview.up();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("前行 Key_Up");
                        }
                        FlatButton {
                            id: mbButton;
                            text: "↓";
                            function clickedCallBack() {
                                speedview.down();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("后退 Key_Down");
                        }
                    }
                    Column{
                        spacing: 4;
                        FlatButton {
                            id: stopButton;
                            text: "■";
                            function clickedCallBack() {
                                speedview.clear();
                                speedview.move();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("停止 Key_S");
                        }
                        FlatButton {
                            id: leftMoveButton;
                            text: "←";
                            width: lfdButton.width;
                            function clickedCallBack(){
                                speedview.left();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("左移 Key_left");
                        }
                        FlatButton {
                            id: rightMoveButton;
                            text: "→";
                            width: lfdButton.width;
                            function clickedCallBack(){
                                speedview.right();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("右移 Key_right");
                        }
                    }
                    Column{
                        spacing: 4;
                        FlatButton {
                            id: astopButton;
                            text: "T";
                            function clickedCallBack() {
                                speedview.clear();
                                udpServer.cmdAStop();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("精确停止 A/space");
                        }
                        FlatButton {
                            id: leftButton;
                            text: "↰";
                            width: lfdButton.width;
                            function clickedCallBack() {
                                udpServer.cmdTl();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("左分支 L");
                        }
                        FlatButton {
                            id: rightButton;
                            text: "↱";
                            width: lfdButton.width;
                            function clickedCallBack() {
                                udpServer.cmdTr();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("右分支 R");
                        }
                    }
                    Column{
                        spacing: 4;
                        FlatButton {
                            id: rotateview;
                            font.pointSize: 12;
                            textColor: "black";
                            text:"90";
                            property int rot: 0  //0: 90°  1: 180°
                            function clickedCallBack() {
                                if (rot == 0) {
                                    text = "180";
                                    rot = 1;
                                } else {
                                    text = "90";
                                    rot = 0;
                                }
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("旋转角度 Key_Equal");
                        }
                        FlatButton {
                            id: rcButton;
                            text: "↻";
                            function clickedCallBack() {
                                if (rotateview.text == 90) {
                                    udpServer.cmdRc();
                                } else {
                                    udpServer.cmdRc2();
                                }
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("顺时针旋转 Key_Q");
                        }
                        FlatButton {
                            id: rccButton;
                            text: "↺";
                            function clickedCallBack() {
                                if (rotateview.text == 90) {
                                    udpServer.cmdRcc();
                                } else {
                                    udpServer.cmdRcc2();
                                }
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("逆时针旋转 Key_W");
                        }
                    }

                    Column{
                        spacing: 4;
                        FlatButton {
                            id: lfupButton;
                            text: "U";
                            width: lfdButton.width;
                            function clickedCallBack() {
                                udpServer.cmdLiftUp();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("升平台 U");
                        }
                        FlatButton {
                            id: lfmButton;
                            text: "M";
                            width: mfButton.width;
                            function clickedCallBack() {
                                udpServer.cmdLiftMid();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("中间平台 M");
                        }
                        FlatButton {
                            id: lfdButton;
                            text: "D";
                            width: mfButton.width;
                            function clickedCallBack() {
                                udpServer.cmdLiftDown();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("降平台 D");
                        }
                    }
                    Column{
                        spacing: 4;
                        FlatButton {
                            id: oaButton;
                            text: "OA";
                            width: lfdButton.width;
                            property int oa;     //0 on, 1 off
                            property int onOff: 0;
                            function clickedCallBack(){
                                if (onOff == 0) {
                                    udpServer.cmdOAOn()
                                    onOff = 1;
                                } else {
                                    udpServer.cmdOAOff();
                                    onOff = 0;
                                }
                            }
                            onOaChanged: {
                                if (oa == 0) {
                                    color = "aquamarine";
                                } else {
                                    color = "transparent";
                                }
                            }
                            onOnOffChanged: {
                                if (onOff == 0) {
                                    font.underline = false;
                                } else {
                                    font.underline = true;
                                }
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("避障 F1");
                        }
                        FlatButton {
                            id: csButton;
                            text: "CS";
                            width: lfdButton.width;
                            property int cs;  //0:off  1:on
                            property int onOff: 0;
                            function clickedCallBack() {
                                if (onOff == 0) {
                                    udpServer.cmdCSOn();
                                    onOff = 1;
                                } else {
                                    udpServer.cmdCSOff();
                                    onOff = 0;
                                }
                            }
                            onCsChanged: {
                                if (cs == 0) {
                                    color = "transparent";
                                } else {
                                    color = "aquamarine";
                                }
                            }
                            onOnOffChanged: {
                                if (onOff == 0) {
                                    font.underline = false;
                                } else {
                                    font.underline = true;
                                }
                            }

                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("充电继电器 F2");
                        }
                    }
                    Column {
                        spacing: 4;
                        RectangleStatus {
                            id: farView;
                            width: mfButton.width;
                            height: mfButton.height;
                            text: qsTr("FAR")
                            colortext: "deeppink";
                        }
                        RectangleStatus {
                            id: nearView;
                            width: mfButton.width;
                            height: mfButton.height;
                            text: qsTr("NEAR")
                            colortext: "deeppink";
                        }
                        RectangleStatus {
                            id: machView;
                            width: mfButton.width;
                            height: mfButton.height;
                            text: qsTr("MACH")
                            colortext: "deeppink";
                        }
                    }
                }
                Row {
                    spacing: 4;
                    FlatButton {
                        id: loadButton;
                        //width: 58;
                        text: "L";
                        function clickedCallBack() {
                            udpServer.cmdLoadPath();
                        }
                        onClicked: {
                            clickedCallBack();
                        }
                        toolTipText: qsTr("加载路径 Insert");
                    }
                    FlatButton {
                        id: startButton;
                        text: "O";
                        width: loadButton.width;
                        function clickedCallBack() {
                            udpServer.cmdStart();
                        }
                        onClicked: {
                            clickedCallBack()
                        }
                        toolTipText: qsTr("解除急停 Home");
                    }
                    FlatButton {
                        id: esButton;
                        text: "ES";
                        width: loadButton.width;
                        function clickedCallBack() {
                            udpServer.cmdEStop();
                        }
                        onClicked: {
                            clickedCallBack();
                        }
                        toolTipText: qsTr("急停 End");
                    }
                    FlatButton {
                        id: delButton;
                        text: "DEL";
                        width: loadButton.width;
                        function clickedCallBack() {
                            udpServer.cmdDEList();
                        }
                        onClicked: {
                            clickedCallBack();
                        }
                        toolTipText: qsTr("删除路径 Delete");
                    }
                    Text {
                        y: 4;
                        id: agvInfo;
                        width: agvConsole.width - 4 * delButton.width;
                        //anchors.top: col1.bottom;
                        anchors.topMargin: 12;
                        text: "AGV运动应答";
                        //font.family: "Helvetica"
                        font.pointSize: 12;
                        color: "blue";
                        focus: true;
                    }
                }
                Row {
                    spacing: 4;
                    RectangleStatus{
                        id: agvVoltage
                        text: "0 v";
                        width:54;
                    }
                    RectangleStatus{
                        id: agvPrepos
                        text: "-1";
                        width: 94;
                    }

                    RectangleStatus{
                        id: agvNextpose;
                        text: "-1";
                        width: 94;
                    }
                }
                Row {
                    spacing: 4;
                    TextField {
                        id: idxTextField
                        width: 36;
                        height: 20;
                        textColor: "blue";
                        validator: IntValidator {}
                        placeholderText: qsTr("idx");
                    }
                    TextField {
                        id: xTextField;
                        width: 26;
                        height: 20;
                        text: "25"
                        textColor: "blue";
                        validator: IntValidator {}
                        placeholderText: qsTr("x");
                    }
                    TextField {
                        id: yTextField;
                        width: 26;
                        height: 20;
                        text: "25"
                        textColor: "blue";
                        validator: IntValidator {}
                        placeholderText: qsTr("y");
                    }
                    Button {
                        id: agvInitButton;
                        width: 34;
                        height: 20;
                        text: "Set";
                        onClicked: {
                            if (agvipCombobox.count == 0) {
                                return;
                            }
                            mapGrid.setAgvModel(agvipCombobox.currentText,
                                                idxTextField.text,
                                                xTextField.text,
                                                yTextField.text,
                                                agvRotation.text);
                        }
                    }
                }
                Row {
                    spacing: 4;
                    Text {
                        id: agvDerection;
                        y: 6;
                        text: qsTr("R:")
                    }
                    TextField {
                        width: 50;
                        id: agvRotation;
                        text: "0";
                    }
                    CheckBox {
                        y: 6;
                        id: agvShowCheck;
                        text: "Show?"
                        checked: mapGrid.agvModelIsShow(agvipCombobox.currentText);
                        onCheckedChanged: {
                            if (agvipCombobox.count == 0) {
                                return;
                            }
                            if (checked) {
                                mapGrid.showAgvModel(agvipCombobox.currentText);
                            } else {
                                mapGrid.hideAgvModel(agvipCombobox.currentText)
                            }
                        }
                    }
                }
                Row {
                    spacing: 4;
                    TextField {
                        width: 50;
                        id: agvAct;
                        text: "1";
                    }
                    TextField {
                        width: 50;
                        id: agvTurn;
                        text: "1";
                    }
                    Button {
                        width: 30;
                        text: "test";
                        onClicked: {
                            //mapGrid.agvTestGetMagCurve(agvipCombobox.currentText, Number(agvAct.text), Number(agvTurn.text));
                            console.log("



");
                            mapGrid.agvTestGetCross(agvipCombobox.currentText, Number(agvAct.text), Number(agvTurn.text));
                        }
                    }
                }
            }
        }

                GroupBox {
                    id: agvAlarm;
                    title: "agv alarm";
                    height: agvConsole.height;
                    width: root.width - agvConsole.width - 20
                    Column {
                        anchors.topMargin: 20
                        spacing: 4
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("电量报警:     ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: elecNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: elecAlarm
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("丢磁报警:     ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: dcNomal
                                text: "√";
                            }
                            RectangleStatus{
                                id: dcAlarm;
                                text: "⚠";
                                //color: "red"
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("旋转报警:     ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: rotateNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: rotateAlarm;
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("平台报警:     ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: liftNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: liftAlarm;
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("低电量停机:   ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: lowPowerNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: lowPowerAlarm;
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("驱动电机报警: ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: moterNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: moterAlarm;
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("充电通信报警: ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: chargeNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: chargeAlarm;
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("滚筒电机报警: ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: rollerNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: rollerAlarm;
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("主控通信报警: ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: masterCtrNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: masterCtrAlarm;
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("紧急停止报警: ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: estopNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: estopAlarm;
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("网络中断报警: ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: netInterruptNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: netInterruptAlarm;
                                text: "⚠";
                            }
                        }
                    }
                }
    }
}
