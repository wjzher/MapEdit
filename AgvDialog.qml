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
        function paramJson (cmd) {
            var v = "{\"agvcmd\":\"";
            v += cmd;
            v += "\"}";
            return v;
        }

        onAgvStatusChanged: {
            console.log("status changed " + inf + " " + status);
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
            width: root.width / 3;
            Row {
                spacing: 8;
                Text {
                    y: 6;
                    text: qsTr("IP:");
                }
                ComboBox {
                    width: 100;
                    id: agvidCombobox;
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
                    onClicked: {
                        var v = udpServer.paramJson("ml");
                        console.log(v);
                        udpServer.sendCommand(20000, v);
                    }
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
            }
        }
        Row {
            spacing: 4
            Row {
                GroupBox {
                    id: agvStatus;
                    title: "agv status";
                    width: (root.width - agvConsole.width) / 3 + 30 ;
                    height: agvConsole.height;
                    Column {
                        spacing: 8;
                        Row {
                            RectangleStatus{
                                text: "←"
                                font: 18;
                            }
                        }
                        Row {
                            spacing: 4;
                            RectangleStatus{
                                text: "↰"
                                width: 30;
                                font: 18;
                            }
                            RectangleStatus{
                                text: "↱"
                                width: 30;
                                font: 18;
                            }
                        }
                        Row {
                            spacing: 4;
                            RectangleStatus{
                                text: "↑"
                                width: 30;
                                font: 18;
                            }
                            RectangleStatus{
                                text: "↓"
                                width: 30;
                                font: 18;
                            }
                        }

                        Row {
                            spacing: 6
                            RectangleStatus{
                                text: "1档";
                                width: 50;
                            }
                            RectangleStatus{
                                text: "0";
                                width: 50;
                            }
                        }

                        Row {
                            spacing: 6
                            RectangleStatus{
                                text: "-1";
                                width: 50;
                            }
                            RectangleStatus{
                                text: "-1";
                                width: 50;
                            }
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
