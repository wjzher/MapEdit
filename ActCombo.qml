import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Rectangle {
    id: root;
    width: 180;
    property alias index: comboBox.currentIndex;
    property alias model: comboBox.model;
    property var actJsonVal: [0,2,3,4,7,8,17,20,21];
    Row {
        spacing: 8;
        Text {
            y: 4;
            text: qsTr("Act:");
        }
        ComboBox {
            width: 120;
            id: comboBox;
            model: [
                "无",
                "精确停止",
                "前行",
                "后退",
                "顺时针旋转",
                "逆时针旋转",
                "平台动作",
                "避障",
                "充电"
            ];
        }
    }
}
