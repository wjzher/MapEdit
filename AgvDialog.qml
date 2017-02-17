import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import Qt.UdpServer 1.0
import QtQuick.Controls 1.4

Window {
    id: root;
    width: 500;
    height: 220;
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

        onAgvStatusChanged: {
            console.log("status changed " + inf + " " + status);
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
                 break;
            }
        }
        function agvStatus(status) {
            var json = JSON.parse(status);
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
        }

        onAgvAddressChanged: {
            console.log("address changed " + ip);
            currentIp = ip;
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
            Row {
                spacing: 8;
                Text {
                    y: 6;
                    text: qsTr("IP:");
                }
                ComboBox {
                    width: 100;
                    id: agvipCombobox;
                    model: [
                        "空"
                    ];
                }
            }
            GridLayout {
                id: consoleGrid
                rows: 2;
                columns: 4;
                rowSpacing: 4;
                columnSpacing: 4;
                anchors.topMargin: 50
                anchors.fill: parent;
                anchors.margins: 3;
                ConsoleBtn{
                    id: mfButton;
                    text: "←";
                }
                ConsoleBtn{
                    id: mbButton;
                    text: "→";
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
                                text: "√";
                                //color: "aquamarine";
                            }
                            RectangleStatus{
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
                                text: "√";
                            }
                            RectangleStatus{
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
                                text: "√";
                            }
                            RectangleStatus{
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
                                text: "√";
                            }
                            RectangleStatus{
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
                                text: "√";
                            }
                            RectangleStatus{
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
                                text: "√";
                            }
                            RectangleStatus{
                                text: "⚠";
                            }
                        }
                    }
                }
            }
        }
    }
}
