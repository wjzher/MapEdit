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
                spacing: 4
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
                Row {
                    spacing: 8;
                    Text {
                        y: 6;
                        text: qsTr("V: ");
                    }
                    ComboBox {
                        width: 100;
                        id: agvspeedCombobox;
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
            GridLayout {
                id: consoleGrid
                rows: 2;
                columns: 4;
                rowSpacing: 4;
                columnSpacing: 4;
                anchors.topMargin: 70
                anchors.fill: parent;
                anchors.margins: 3;
                ConsoleBtn{
                    id: mfButton;
                    text: "→";
                    onClicked: udpServer.cmdMf(agvspeedCombobox.currentIndex);
                }
                ConsoleBtn{
                    id: mbButton;
                    text: "←";
                    onClicked: udpServer.cmdMb(agvspeedCombobox.currentIndex);
                }
                ConsoleBtn{
                    id: mlButton;
                    text: "↰";
                    onClicked: udpServer.cmdMl();
                }
                ConsoleBtn{
                    id: mrButton;
                    text: "↱";
                    onClicked: udpServer.cmdMr();
                }
                ConsoleBtn{
                    id: rcButton;
                    text: "↷";
                    onClicked: udpServer.cmdRc();
                }
                ConsoleBtn{
                    id: rccButton;
                    text: "↶";
                    onClicked: udpServer.cmdRcc();
                }
                ConsoleBtn{
                    id: rc2Button;
                    text: "↻";
                    onClicked: udpServer.cmdRc2();
                }
                ConsoleBtn{
                    id: rcc2Button;
                    text: "↺";
                    onClicked: udpServer.cmdRcc2();
                }
                ConsoleBtn{
                    id: astopButton;
                    text: "T";
                    onClicked: udpServer.cmdAStop();
                }
                ConsoleBtn{
                    id: estopButton;
                    text: "⚠";
                    onClicked: udpServer.cmdEStop();
                }
                ConsoleBtn{
                    id: platupButton;
                    text: "↑";
                    onClicked: udpServer.cmdLiftUp();
                }
                ConsoleBtn{
                    id: platdownButton;
                    text: "↓";
                    onClicked: udpServer.cmdLiftDown();
                }
                ConsoleBtn{
                    id: startButton;
                    text: "►";
                    onClicked: udpServer.cmdStart();
                }
                ConsoleBtn{
                    id: stopButton;
                    text: "■";
                    onClicked: udpServer.cmdStop();
                }
                ConsoleBtn{
                    id: oaButton;
                    text: "OA";
                }
                ConsoleBtn{
                    id: relayButton;
                    text: "CS";
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
