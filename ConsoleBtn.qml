import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.4

Rectangle {
    id: root;
    property alias text: consoleText.text
    Button{
        id: consoleBtn;
        implicitHeight: 30;
        implicitWidth: 30;
        Text {
            id:consoleText
            font.pointSize: 18;
            color: "black";
            anchors.centerIn: parent;
        }
    }
}
