import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import Qt.UdpServer 1.0
import QtQuick.Controls 1.4

Window {
    id: root;
    width: 600;
    height: 400;
    title: "AGV Control";
    modality: Qt.WindowNoState;

    UdpServer {
        id: udpServer;
        onAgvStatusChanged: {
            console.log("status changed " + inf + " " + status);
        }
        onAgvAddressChanged: {
            console.log("address changed " + ip);
            currentIp = ip;
        }
    }

    Button {
        text: "Send";
        onClicked: {
            udpServer.sendCommand(1005, "{\"agvid\":1}");
        }
    }

}
