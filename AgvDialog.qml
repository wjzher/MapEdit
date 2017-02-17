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
                agvStatus(status);
                break;
            }
        }
        function agvStatus(status) {
            var json = JSON.parse(status);
            var m = json.info;
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
            } else {
                dcAlarm.color = "red";
            }
            if (!n.driver) {
                moterNomal.color = "aquamarine";
            } else {
                moterAlarm.color = "red";
            }
            if (!n.elec) {
                elecNomal.color = "aquamarine";
            } else {
                elecAlarm.color = "red";
            }
            if (!n.lift) {
                liftNomal.color = "aquamarine";
            } else {
                liftAlarm.color = "red";
            }
            if (!n.chargecommu) {
                chargeNomal.color = "aquamarine";
            } else {
                chargeAlarm.color = "red";
            }
            if (!n.rotate) {
                rotateNomal.color = "aquamarine";
            } else {
                rotateAlarm.color = "red";
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
                    model: [
                        "空"
                    ];
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
                    text: "←";
                }
                ConsoleBtn{
                    id: mbButton;
                    text: "→";
                }
                ConsoleBtn{
                    id: mlButton;
                    text: "↰";
                }
                ConsoleBtn{
                    id: mrButton;
                    text: "↱";
                }
                ConsoleBtn{
                    id: rcButton;
                    text: "↷";
                }
                ConsoleBtn{
                    id: rccButton;
                    text: "↶";
                }
                ConsoleBtn{
                    id: rc2Button;
                    text: "↻";
                }
                ConsoleBtn{
                    id: rcc2Button;
                    text: "↺";

                }
                ConsoleBtn{
                    id: astopButton;
                    text: "T";
                }
                ConsoleBtn{
                    id: estopButton;
                    text: "⚠";
                }
                ConsoleBtn{
                    id: platupButton;
                    text: "↑";
                }
                ConsoleBtn{
                    id: platdownButton;
                    text: "↓";
                }
                ConsoleBtn{
                    id: starteButton;
                    text: "↓";
                }
                ConsoleBtn{
                    id: stopButton;
                    text: "↓";
                }
                ConsoleBtn{
                    id: oaButton;
                    text: "↓";
                }
                ConsoleBtn{
                    id: relayButton;
                    text: "↓";
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
