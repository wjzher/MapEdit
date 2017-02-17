import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import Qt.UdpServer 1.0
import QtQuick.Controls 1.4

Window {
    id: root;
    width: 600;
    height: 400;
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
            width: root.width / 4;
            Rectangle {
                id: agvId;
                width: 80;
                Row {
                    spacing: 8;
                    Text {
                        y: 4;
                        text: qsTr("Current ID:");
                    }
                    ComboBox {
                        width: 50;
                        //height: agvId.height
                        id: agvidCombobox;
                        model: [
                            "空"

                        ];
                    }
                }
            }
//            Column{
//                anchors.fill: parent;
//                anchors.margins: 8;
//                spacing: 4;
                ConsoleBtn{
                    id: mfButton;
                    width: 30;
                    height: 30;
                    anchors.left:parent.left
                    anchors.leftMargin: parent.width / 2 - 34
                    anchors.top: agvId.bottom
                    anchors.topMargin: 50
                    text: "←";
                }
                ConsoleBtn{
                    id: mbButton;
                    anchors.top: mfButton.top
                    anchors.left: mfButton.right
                    anchors.leftMargin: 8
                    text: "→";
                }
                ConsoleBtn{
                    id: mlButton;
                    width: 30;
                    height: 30;
                    anchors.left:mfButton.left
                    anchors.top: mfButton.bottom
                    anchors.topMargin: 8
                    text: "↰";
                    onClicked: {
                        var v = udpServer.paramJson("ml");
                        console.log(v);
                        udpServer.sendCommand(20000, v);
                    }
                }
                ConsoleBtn{
                    id: mrButton;
                    anchors.top: mlButton.top
                    anchors.left: mfButton.right
                    anchors.leftMargin: 8
                    text: "↱";
                }
                ConsoleBtn{
                    id: rcButton;
                    width: 30;
                    height: 30;
                    anchors.left:mfButton.left
                    anchors.top: mlButton.bottom
                    anchors.topMargin: 8
                    text: "↷";
                }
                ConsoleBtn{
                    id: rccButton;
                    anchors.top: rcButton.top
                    anchors.left: rcButton.right
                    anchors.leftMargin: 8
                    text: "↶";
                }
                ConsoleBtn{
                    id: rc2Button;
                    width: 30;
                    height: 30;
                    anchors.left:mfButton.left
                    anchors.top: rcButton.bottom
                    anchors.topMargin: 8
                    text: "↻";
                }
                ConsoleBtn{
                    id: rcc2Button;
                    anchors.top: rc2Button.top
                    anchors.left: rc2Button.right
                    anchors.leftMargin: 8
                    text: "↺";

                }
                ConsoleBtn{
                    id: astopButton;
                    width: 30;
                    height: 30;
                    anchors.left:mfButton.left
                    anchors.top: rc2Button.bottom
                    anchors.topMargin: 8
                    text: "T";
                }
                ConsoleBtn{
                    id: estopButton;
                    width: 30;
                    height: 30;
                    anchors.top: astopButton.top
                    anchors.left: astopButton.right
                    anchors.leftMargin: 8
                    text: "⚠";
                }
                ConsoleBtn{
                    id: platupButton;
                    width: 30;
                    height: 30;
                    anchors.left:mfButton.left
                    anchors.top: astopButton.bottom
                    anchors.topMargin: 8
                    text: "↑";
                }
                ConsoleBtn{
                    id: platdownButton;
                    width: 30;
                    height: 30;
                    anchors.top: platupButton.top
                    anchors.left: platupButton.right
                    anchors.leftMargin: 8
                    text: "↓";
                }

//            }
        }
        GroupBox {
            id: agvStatus;
            title: "agv status";
            height: agvConsole.height;
            width: root.width - agvConsole.width - 22;
        }
    }
}
