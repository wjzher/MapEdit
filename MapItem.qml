import QtQuick 2.0
import Qt.MapItemType 1.0

Rectangle {
    id: root;
    property int length: 50;
    property alias text: itemText.text;
    property int type: MapItemType.MapItemXLine;
    property bool isCard: false;
    property var cardPos: [length / 2, length / 2];
    signal clicked;
    width: length;
    height: length;
    function rePaint() {
        canvas.requestPaint();
    }
    onTypeChanged: rePaint();
    onIsCardChanged: rePaint();
    onCardPosChanged: rePaint();

    Canvas {
        id: canvas;
        anchors.fill: parent;
        property real dis: 4.0;   // 两线间距
        property real div: 12.5;    // 边长/间距
        property real divStopLine: 2.5;     // 边长/stopLine
        property real divMStopLine: (50 / 18);
        onPaint: {
            console.log("GridItem Paint. (" + root.x + ", " + root.y + ")");
            var ctx = getContext("2d");
            ctx.lineWidth = length / div;
            ctx.strokeStyle = "black";
            ctx.beginPath();
//            ctx.fillStyle = "white";
            ctx.clearRect(0, 0, width, height);
            switch (root.type) {
            case MapItemType.MapItemXLine:
                ctx.moveTo(0, height / 2);
                ctx.lineTo(width, height / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemYLine:
                ctx.moveTo(width / 2, 0);
                ctx.lineTo(width / 2, height);
                ctx.stroke();
                break;
            case MapItemType.MapItemCross:
                ctx.moveTo(0, height / 2);
                ctx.lineTo(width, height / 2);
                ctx.moveTo(width / 2, 0);
                ctx.lineTo(width / 2, height);
                ctx.stroke();
                break;
            case MapItemType.MapItemXLStop:
                ctx.moveTo(0, height / 2);
                ctx.lineTo(width, height / 2);
                ctx.moveTo(ctx.lineWidth / 2, height / 2 - length / divStopLine / 2);
                ctx.lineTo(ctx.lineWidth / 2, height / 2 + length / divStopLine / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemXRStop:
                ctx.moveTo(0, height / 2);
                ctx.lineTo(width, height / 2);
                ctx.moveTo(width - ctx.lineWidth / 2, height / 2 - length / divStopLine / 2);
                ctx.lineTo(width - ctx.lineWidth / 2, height / 2 + length / divStopLine / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemYUStop:
                ctx.moveTo(width / 2, 0);
                ctx.lineTo(width / 2, height);
                ctx.moveTo(width / 2 - length / divStopLine / 2, ctx.lineWidth / 2);
                ctx.lineTo(width / 2 + length / divStopLine / 2, ctx.lineWidth / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemYDStop:
                ctx.moveTo(width / 2, 0);
                ctx.lineTo(width / 2, height);
                ctx.moveTo(width / 2 - length / divStopLine / 2, height - ctx.lineWidth / 2);
                ctx.lineTo(width / 2 + length / divStopLine / 2, height - ctx.lineWidth / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemXLMStop:
                ctx.moveTo(0, height / 2);
                ctx.lineTo(width, height / 2);
                ctx.moveTo(ctx.lineWidth / 2 + length / divMStopLine, height / 2 - length / divStopLine / 2);
                ctx.lineTo(ctx.lineWidth / 2 + length / divMStopLine, height / 2 + length / divStopLine / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemXRMStop:
                ctx.moveTo(0, height / 2);
                ctx.lineTo(width, height / 2);
                ctx.moveTo(width - ctx.lineWidth / 2 - length / divMStopLine, height / 2 - length / divStopLine / 2);
                ctx.lineTo(width - ctx.lineWidth / 2 - length / divMStopLine, height / 2 + length / divStopLine / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemYUMStop:
                ctx.moveTo(width / 2, 0);
                ctx.lineTo(width / 2, height);
                ctx.moveTo(width / 2 - length / divStopLine / 2, ctx.lineWidth / 2 + length / divMStopLine);
                ctx.lineTo(width / 2 + length / divStopLine / 2, ctx.lineWidth / 2 + length / divMStopLine);
                ctx.stroke();
                break;
            case MapItemType.MapItemYDMStop:
                ctx.moveTo(width / 2, 0);
                ctx.lineTo(width / 2, height);
                ctx.moveTo(width / 2 - length / divStopLine / 2, height - ctx.lineWidth / 2 - length / divMStopLine);
                ctx.lineTo(width / 2 + length / divStopLine / 2, height - ctx.lineWidth / 2 - length / divMStopLine);
                ctx.stroke();
                break;
            case MapItemType.MapItemNULL:
                break;
            default:
                break;
            }
            if (root.isCard) {
                ctx.fillStyle = "blue";
                ctx.beginPath();
                ctx.arc(root.cardPos[0], root.cardPos[1], length / div / 2,
                        0, 2 * Math.PI, false);
                ctx.fill();
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
