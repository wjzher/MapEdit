import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import Qt.UdpServer 1.0
import QtQuick.Controls 1.4

Window {
    id: root;
    width: 500;
    height: 260;
    title: "AGV Control";
    color: "#EEEEEE";
    modality: Qt.WindowNoState;

    UdpServer {
        id: udpServer;
        property int cmdInf: 20000;
        function paramJson(cmd) {
            var v = "{\"agvcmd\":\"";
            v += cmd;
            v += "\"}";
            return v;
        }
        function paramAgvId() {
            return "{\"agvid\":\"1\"";
        }
        function cmdMf(speed) {
            var v = paramJson("mf " + speed);
            sendCommand(cmdInf, v);
        }
        function cmdMb(speed) {
            var v = paramJson("mb " + speed);
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
        function cmdMl() {
            var v = paramJson("ml");
            sendCommand(cmdInf, v);
        }
        function cmdMr() {
            var v = paramJson("mr");
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
        function cmdEStop() {
            var v = paramAgvId();
            sendCommand(1005, v);
        }
        function cmdStart() {
            var v = paramAgvId();
            sendCommand(1003, v);
        }
        function agvShowStatus(status) {
            var json = JSON.parse(status);
            var m = json.infos;
            var n = json.alarm;
            switch (m.sta) {
            case 1:
                agvActive.text = "←"
                break;
            case 2:
                agvActive.text = "→"
                break;
            case 5:
                agvActive.text = "↻"
                break;
            case 6:
                agvActive.text = "↺"
                break;
            case 7:
                agvActive.text = "⚠"
                break;
            }
            switch (m.turnto) {
            case 1:
                agvBranch.text = "↰"
                break;
            case 2:
                agvBranch.text = "↱"
                break;
            }
            switch (m.v) {
            case 1:
                agvSpeed.text = "1档"
                break;
            case 2:
                agvSpeed.text = "2档";
                break;
            case 2:
                agvSpeed.text = "3档";
                break;
            case 2:
                agvSpeed.text = "4档";
                break;
            case 2:
                agvSpeed.text = "5档";
                break;
            }
            switch (m.liftsta) {
            case 1:
                agvLeft.text = "↑";
                break
            case 2:
                agvLeft.text = "↓";
                break;
            }
            agvVoltage.text = m.voltage + "v";
            agvPrepos.text = m.prepos;
            agvNextpose.text = m.nextpos;
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
        }

        onAgvStatusChanged: {
//            console.log("status changed " + inf + " " + status);
            switch (inf) {
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
                agvShowStatus(status);
                break;
            }
        }
        onAgvAddressChanged: {
            console.log("address changed " + ip);
            currentIp = ip;
            agvipCombobox.model.append({text: ip});
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
            width: 180;
            Column{
                spacing: 10
                Row {
                    spacing: 8;
                    Text {
                        y: 6;
                        text: qsTr("IP:");
                    }
                    ComboBox {
                        width: 100;
                        id: agvipCombobox;
                        model: ListModel {
                            id: model;
//                            ListElement {
//                                text: "Null";
//                            }
                        }
                    }
                }

                Column {
                    spacing: 4;
                    Row {
                        spacing: 4;
                        FlatButton {
                            id: speedview;
                            property int dir: 0;    // 0 front 1 back
                            text: "0";
                            font.pointSize: 12;
                            textColor: "black";
                            function clear() {
                                dir = 0;
                                text = 0;
                                move();
                            }
                            function move() {
                                if (text == 0) {
                                    udpServer.cmdStop();
                                } else {
                                    if (dir == 0) {
                                        udpServer.cmdMf(text);
                                    } else {
                                        udpServer.cmdMb(text);
                                    }
                                }
                            }

                            function up(){
                                if (dir == 0) {
                                    if (speedview.text < 5) {
                                        speedview.text++;
                                        move();
                                    }
                                } else {
                                    if (speedview.text > 0) {
                                        speedview.text--;
                                        if (speedview.text == 0) {
                                            dir = 0;
                                        }
                                        move();
                                    }
                                }
                            }
                            function down(){
                                if (dir == 1) {
                                    if (speedview.text < 5) {
                                        speedview.text++;
                                        move();
                                    }
                                } else {
                                    if (speedview.text > 0) {
                                        speedview.text--;
                                        if (speedview.text == 0) {
                                            dir = 1;
                                        }
                                        move();
                                    }
                                }
                            }
                        }
                        FlatButton {
                            id: mfButton;
                            text: "↑";
                            onClicked: {
                                speedview.up();
                            }
                        }
                        FlatButton {
                            id: rcButton;
                            text: "↻";
                            onClicked: {
                                if (rotateview.text == 90) {
                                udpServer.cmdRc();
                                } else {
                                    udpServer.cmdRc2();
                                }
                            }
                        }
                        FlatButton {
                            id: stopButton;
                            text: "s";
                            onClicked: {
                                speedview.clear();
                            }
                        }
                    }
                    Row {
                        spacing: 4;
                        FlatButton {
                            id: rotateview;
                            font.pointSize: 12;
                            textColor: "black";
                            text:"90";
                            property int rot: 0
                            onClicked: {
                                if (rot == 0) {
                                    text = "180";
                                    rot = 1;
                                } else {
                                    text = "90";
                                    rot = 0;
                                }
                            }
                        }
                        FlatButton {
                            id: mbButton;
                            text: "↓";
                            onClicked: {
                                speedview.down();
                            }
                        }
                        FlatButton {
                            id: rccButton;
                            text: "↺";
                            onClicked: {
                                if (rotateview.text == 90) {
                                udpServer.cmdRcc();
                                } else {
                                    udpServer.cmdRcc2();
                                }
                            }
                        }
                        FlatButton {
                            id: astopButton;
                            text: "a";
                            onClicked: {
                                udpServer.cmdAStop()
                            }
                        }
                    }
                }
                Column {
                    spacing: 4;
                    Row {
                        spacing: 4;
                        FlatButton {
                            id: lfupButton;
                            text: "↑";
                            width: lfdButton.width;
                            onClicked: {
                                udpServer.cmdLiftUp();
                            }
                        }
                        FlatButton {
                            id: oaButton;
                            text: "oa";
                            width: lfdButton.width;
                            property int oa: 0;     //0 off, 1 on
                            function oaview() {
                                if (oa == 0) {
                                    textColor = "royalblue";
                                    udpServer.cmdOAOn();
                                    oa = 1;
                                } else {
                                    textColor = "deeppink";
                                    udpServer.cmdOAOff();
                                    oa = 0;
                                }
                            }
                            onClicked: {
                                oaButton.oaview();
                            }
                        }
                        FlatButton {
                            id: leftButton;
                            text: "↰";
                            width: lfdButton.width;
                            onClicked: {
                                udpServer.cmdMl();
                            }
                        }
                    }
                    Row {
                        spacing: 4;
                        FlatButton {
                            id: lfdButton;
                            text: "↓";
                            width: 48;
                            onClicked: {
                                udpServer.cmdLiftDown();
                            }
                        }
                        FlatButton {
                            id: csButton;
                            text: "cs";
                            width: lfdButton.width;
                            property int cs: 0;
                            onClicked: {
                                if (cs == 0) {
                                    textColor = "royalblue";
                                    udpServer.cmdCSOn();
                                    cs = 1;
                                } else {
                                    textColor = "deeppink";
                                    udpServer.cmdCSOff();
                                    cs = 0;
                                }
                            }
                        }
                        FlatButton {
                            id: rightButton;
                            text: "↱";
                            width: lfdButton.width;
                            onClicked: {
                                udpServer.cmdMr();
                            }
                        }

                    }
                }
                Row {
                    spacing: 4;
                    FlatButton {
                        id: loadButton;
                        text: "l";
                        width: lfdButton.width;
                    }
                    FlatButton {
                        id: resButton;
                        text: "o";
                        width: lfdButton.width;
                    }
                    FlatButton {
                        id: esButton;
                        text: "es";
                        width: lfdButton.width;
                        onClicked: {
                            udpServer.cmdAStop()
                        }
                    }
                }
            }
        }
        Row {
            spacing: 4
            Row {
                GroupBox {
                    id: agvStatus;
                    title: "agv status";
                    width: (root.width - agvConsole.width) / 3 + 10 ;
                    height: agvConsole.height;
                    Column {
                        spacing: 4;
                        Row {
                            spacing: 4;
                            RectangleStatus{
                                id: agvActive;
                                text: "←"
                                width: 45;
                                font: 18;
                            }
                            RectangleStatus{
                                id: agvSpeed;
                                text: "1档";
                                width: 45;
                            }
                        }
                        Row {
                            spacing: 4;
                            RectangleStatus{
                                id: agvBranch
                                text: "↰"
                                width: 45;
                                font: 18;
                            }
                            RectangleStatus{
                                id: agvLeft
                                text: "↑"
                                width: 45;
                                font: 18;
                            }
                        }
                        RectangleStatus{
                            id: agvVoltage
                            text: "0 v";
                            width:94;
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

                        Text {
                            id: agvInfo;
                            width: parent.width;
                            text: "";
                            //font.family: "Helvetica"
                            font.pointSize: 18;
                            color: "blue";
                            focus: true;
                        }
                    }
                }
                GroupBox {
                    id: agvAlarm;
                    title: "agv alarm";
                    height: agvStatus.height;
                    width: root.width - agvConsole.width - agvStatus.width - 20
                    Column {
                        anchors.topMargin: 20
                        spacing: 4
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("电量报警: ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: elecNomal;
                                text: "√";
                                //color: "aquamarine";
                            }
                            RectangleStatus{
                                id: elecAlarm
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("丢磁报警: ")
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
                                text: qsTr("旋转报警: ")
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
                                text: qsTr("平台报警: ")
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
                                text: qsTr("电机报警: ")
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
                                text: qsTr("通信报警: ")
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
                    }
                }
            }
        }
    }
}
