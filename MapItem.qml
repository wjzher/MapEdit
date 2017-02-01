import QtQuick 2.0
import Qt.MapItemType 1.0

Rectangle {
    id: root;
    property int length: 50;
    property alias text: itemText.text;
    property int type: MapItemType.MapItemXLine;
    signal clicked;
    width: length;
    height: length;
    Canvas {
        anchors.fill: parent;
        property real dis: 4.0;   // 两线间距
        property real div: 12.5;    // 边长/间距
        property real divStopLine: 2.5;     // 边长/stopLine
        onPaint: {
            var ctx = getContext("2d");
            ctx.lineWidth = length / div;
            ctx.strokeStyle = "black";
            switch (root.type) {
            case MapItemType.MapItemXLine:
                ctx.beginPath();
                ctx.moveTo(0, height / 2);
                ctx.lineTo(width, height / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemYLine:
                ctx.beginPath();
                ctx.moveTo(width / 2, 0);
                ctx.lineTo(width / 2, height);
                ctx.stroke();
                break;
            case MapItemType.MapItemCross:
                ctx.beginPath();
                ctx.moveTo(0, height / 2);
                ctx.lineTo(width, height / 2);
                ctx.moveTo(width / 2, 0);
                ctx.lineTo(width / 2, height);
                ctx.stroke();
                break;
            case MapItemType.MapItemXLStop:
                ctx.beginPath();
                ctx.moveTo(0, height / 2);
                ctx.lineTo(width, height / 2);
                ctx.moveTo(ctx.lineWidth / 2, height / 2 - length / divStopLine / 2);
                ctx.lineTo(ctx.lineWidth / 2, height / 2 + length / divStopLine / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemXRStop:
                ctx.beginPath();
                ctx.moveTo(0, height / 2);
                ctx.lineTo(width, height / 2);
                ctx.moveTo(width - ctx.lineWidth / 2, height / 2 - length / divStopLine / 2);
                ctx.lineTo(width - ctx.lineWidth / 2, height / 2 + length / divStopLine / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemYUStop:
                ctx.beginPath();
                ctx.moveTo(width / 2, 0);
                ctx.lineTo(width / 2, height);
                ctx.moveTo(width / 2 - length / divStopLine / 2, ctx.lineWidth / 2);
                ctx.lineTo(width / 2 + length / divStopLine / 2, ctx.lineWidth / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemYDStop:
                ctx.beginPath();
                ctx.moveTo(width / 2, 0);
                ctx.lineTo(width / 2, height);
                ctx.moveTo(width / 2 - length / divStopLine / 2, height - ctx.lineWidth / 2);
                ctx.lineTo(width / 2 + length / divStopLine / 2, height - ctx.lineWidth / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemNULL:
                break;
            default:
                break;
            }
        }
    }

    Text {
        id: itemText;
        anchors.centerIn: parent;
        font.pixelSize: 9;
        text: "";
    }
    MouseArea {
        id: mapItemMa;
        anchors.fill: parent;
        onClicked: {
            root.clicked();
        }
    }
}
