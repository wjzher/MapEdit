import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Rectangle {
    id: root;
    width: 190;
    height: comboBox.height;
    color: "transparent";
    property alias index: comboBox.currentIndex;
    Row {
        spacing: 8;
        Text {
            y: 4;
            text: qsTr("Arc Set:");
        }
        ComboBox {
            id: comboBox;
            model: [
                "NULL",
                "XLU",
                "XLD",
                "XRU",
                "XRD",
                "YLU",
                "YLD",
                "YRU",
                "YRD"
            ];
        }
    }
}
