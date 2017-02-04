import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2

Rectangle {
    id: root;
    width: parent.width;
    property alias slideValue: customPanel.value;
    signal slideChanged;
    Slider {
        id: customPanel;
        width: 240;
        height: 20;
        x: (parent.width - width) / 2;
        stepSize: 0.1;
        value: 1.5;
        minimumValue: 0.2;
        maximumValue: 4;
        tickmarksEnabled: false;
        onValueChanged: {
            root.slideChanged();
        }

        style: SliderStyle {
            groove: Rectangle {
                implicitWidth: 240;
                implicitHeight: 8;
                color: "gray";
                radius: 8;
            }
            handle: Rectangle {
                anchors.centerIn: parent;
                color: control.pressed ? "white" : "lightgray";
                border.color: "gray";
                border.width: 2;
                width: 28;
                height: 28;
                radius: 8;
                Text {
                    anchors.centerIn: parent;
                    text: control.value.toFixed(1);
                    color: "red";
                }
            }
            panel: Rectangle {
                anchors.fill: parent;
                radius: 4;
                color: "lightsteelblue";
                Loader {
                    id: grooveLoader;
                    anchors.centerIn: parent;
                    sourceComponent: groove;
                }
                Loader {
                    id: handleLoader;
                    anchors.verticalCenter: grooveLoader.verticalCenter;
                    x: Math.min(grooveLoader.x + ((control.value - control.minimumValue) * grooveLoader.width) / (control.maximumValue - control.minimumValue), grooveLoader.width - item.width);
                    sourceComponent: handle;
                }
            }
        }
    }
}
