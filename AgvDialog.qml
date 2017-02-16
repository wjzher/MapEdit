import QtQuick 2.0
import QtQuick.Controls 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1

Window {
    id: root;
    width: 600;
    height: 400;
    title: "AGV Control";
    color: "#EEEEEE";
    modality: Qt.WindowNoState;
    Column{
        id: column;
        anchors.fill: parent;
        anchors.margins: 8;
        spacing: 4;
        GroupBox{
            id: agvView;
            title: "agv view";
            width: root.width - 15;
            height: root.height / 3;
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
                        width: 100;
                        //height: agvId.height
                        id: agvidCombobox;
                        model: [

                        ];
                    }
                }
            }
        }
        GroupBox{
            id: agvConsole;
            title: "agv console";
            width: agvView.width;
            height: root.height / 4;
            Row{
                anchors.fill: parent;
                anchors.margins: 8;
                spacing: 4;
                Button{
                    id: mfButton;
                    width: 40;
                    height: 20;
                    //anchors.left: parent.left;
                    //anchors.leftMargin: 2;
                    text: "←";
                }
                Button{
                    id: mbButton;
                    width: 40;
                    height: 20;
                    //anchors.left: mfButton.right;
                    //anchors.leftMargin: 2;
                    text: "→";
                }
                Button{
                    id: mlButton;
                    width: 40;
                    height: 20;
                    text: "↖";
                }
                Button{
                    id: mrButton;
                    width: 40;
                    height: 20;
                    text: "↗";
                }
                Button{
                    id: rcButton;
                    width: 40;
                    height: 20;
                    text: "↷";
                }
                Button{
                    id: rccButton;
                    width: 40;
                    height: 20;
                    text: "↶";
                }
                Button{
                    id: rc2Button;
                    width: 40;
                    height: 20;
                    text: "↻";
                }
                Button{
                    id: rcc2Button;
                    width: 40;
                    height: 20;
                    text: "↺";
                }
                Button{
                    id: astopButton;
                    width: 80;
                    height: 20;
                    text: "精确停止";
                }
                Button{
                    id: estopButton;
                    width: 40;
                    height: 20;
                    text: "⚠";
                }
                Button{
                    id: platupButton;
                    width: 40;
                    height: 20;
                    text: "↑";
                }
                Button{
                    id: platdownButton;
                    width: 40;
                    height: 20;
                    text: "↓";
                }

            }
        }
        GroupBox {
            id: agvStatus;
            title: "agv status";
            width: agvView.width;
            height: root.height - agvView.height - agvConsole.height - 20;
        }
    }

}
