import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4

Rectangle {
    id: root;
    implicitHeight: 30;
    implicitWidth: 30;
    property alias text: consoleText.text
    Button{
        id: consoleBtn;
        anchors.fill: parent;
        Text {
            id:consoleText
            font.pointSize: 18;
            color: "black";
            anchors.centerIn: parent;
        }
    }
}
