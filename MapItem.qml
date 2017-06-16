import QtQuick 2.0
import Qt.MapItemType 1.0

Rectangle {
    id: root;
    property int length: 50;
    property alias text: itemText.text;
    property int type: MapItemType.MapItemXLine;
    property int cardID: 0;
    property bool isCard: false;
    property var cardPos: [length / 2, length / 2];     // card坐标
    property int isArc: MapItemType.ArcNULL;
    property var arcParam: [0.0, 0.0, 0.0, 0.0];      // x, y, startAngle, endAngle
    property var neighbourPos: [];      // dx, dy, dx, dy...
    property bool isNeighbour: false;
    property bool cutLeftUp: false;
    property bool cutRightDown: false;
    property bool cutMagStop: false;
    property alias agvIpText: agvIpText.text;
    signal clicked;
    width: length;
    height: length;

    function rePaint() {
        canvas.requestPaint();
    }
    onTypeChanged: rePaint();
    onIsCardChanged: rePaint();
    onCardPosChanged: rePaint();
    onIsArcChanged: rePaint();
    onAgvIpTextChanged: rePaint();
    onCutLeftUpChanged: rePaint();
    onCutRightDownChanged: rePaint();
    onCutMagStopChanged: rePaint();
    Canvas {
        id: canvas;
        anchors.fill: parent;
        property real dis: 4.0;   // 两线间距
        property real div: 12.5;    // 边长/间距
        property real divStopLine: 2.5;     // 边长/stopLine
        property real divMStopLine: (50 / 18);
        onPaint: {
//            console.log("GridItem Paint. (" + root.x + ", " + root.y + ") card: ", root.isCard);
            var ctx = getContext("2d");
            ctx.lineWidth = length / div;
            ctx.strokeStyle = "black";
            ctx.beginPath();
//            ctx.fillStyle = "white";
            ctx.clearRect(0, 0, width, height);
            switch (root.type) {
            case MapItemType.MapItemXLine:
                if (cutLeftUp == false) {
                    ctx.moveTo(0, height / 2);
                    ctx.lineTo(width / 2, height / 2);
                }
                if (cutRightDown == false) {
                    ctx.moveTo(width / 2, height / 2);
                    ctx.lineTo(width, height / 2);
                }
                ctx.stroke();
                break;
            case MapItemType.MapItemYLine:
                if (cutLeftUp == false) {
                    ctx.moveTo(width / 2, 0);
                    ctx.lineTo(width / 2, height / 2);
                }
                if (cutRightDown == false) {
                    ctx.moveTo(width / 2, height / 2);
                    ctx.lineTo(width / 2, height);
                }
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
                ctx.moveTo(ctx.lineWidth / 2, width / 2 - width / divStopLine / 2);
                ctx.lineTo(ctx.lineWidth / 2, width / 2 + width / divStopLine / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemXRStop:
                ctx.moveTo(0, height / 2);
                ctx.lineTo(width, height / 2);
                ctx.moveTo(width - ctx.lineWidth / 2, width / 2 - width / divStopLine / 2);
                ctx.lineTo(width - ctx.lineWidth / 2, width / 2 + width / divStopLine / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemYUStop:
                ctx.moveTo(width / 2, 0);
                ctx.lineTo(width / 2, height);
                ctx.moveTo(width / 2 - width / divStopLine / 2, ctx.lineWidth / 2);
                ctx.lineTo(width / 2 + width / divStopLine / 2, ctx.lineWidth / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemYDStop:
                ctx.moveTo(width / 2, 0);
                ctx.lineTo(width / 2, height);
                ctx.moveTo(width / 2 - width / divStopLine / 2, width - ctx.lineWidth / 2);
                ctx.lineTo(width / 2 + width / divStopLine / 2, width - ctx.lineWidth / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemXLMStop:
                if (cutMagStop == false) {
                    ctx.moveTo(0, height / 2);
                    ctx.lineTo(width, height / 2);
                } else {
                    ctx.moveTo(0, height / 2);
                    ctx.lineTo(ctx.lineWidth / 2 + width / divMStopLine, height / 2);
                }
                ctx.moveTo(ctx.lineWidth / 2 + width / divMStopLine, height / 2 - width / divStopLine / 2);
                ctx.lineTo(ctx.lineWidth / 2 + width / divMStopLine, height / 2 + width / divStopLine / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemXRMStop:
                if (cutMagStop == false) {
                    ctx.moveTo(0, height / 2);
                    ctx.lineTo(width, height / 2);
                } else {
                    ctx.moveTo(width - ctx.lineWidth / 2 - width / divMStopLine, height / 2);
                    ctx.lineTo(width, height / 2);
                }
                ctx.moveTo(width - ctx.lineWidth / 2 - width / divMStopLine, height / 2 - width / divStopLine / 2);
                ctx.lineTo(width - ctx.lineWidth / 2 - width / divMStopLine, height / 2 + width / divStopLine / 2);
                ctx.stroke();
                break;
            case MapItemType.MapItemYUMStop:
                if (cutMagStop == false) {
                    ctx.moveTo(width / 2, 0);
                    ctx.lineTo(width / 2, height);
                } else {
                    ctx.moveTo(width / 2, 0);
                    ctx.lineTo(width / 2, ctx.lineWidth / 2 + width / divMStopLine);
                }
                ctx.moveTo(width / 2 - width / divStopLine / 2, ctx.lineWidth / 2 + width / divMStopLine);
                ctx.lineTo(width / 2 + width / divStopLine / 2, ctx.lineWidth / 2 + width / divMStopLine);
                ctx.stroke();
                break;
            case MapItemType.MapItemYDMStop:
                if (cutMagStop == false) {
                    ctx.moveTo(width / 2, 0);
                    ctx.lineTo(width / 2, height);
                } else {
                    ctx.moveTo(width / 2, width - ctx.lineWidth / 2 - width / divMStopLine);
                    ctx.lineTo(width / 2, height);
                }
                ctx.moveTo(width / 2 - width / divStopLine / 2, width - ctx.lineWidth / 2 - width / divMStopLine);
                ctx.lineTo(width / 2 + width / divStopLine / 2, width - ctx.lineWidth / 2 - width / divMStopLine);
                ctx.stroke();
                break;
            case MapItemType.MapItemNULL:
                break;
            default:
                break;
            }
            if (root.isArc != MapItemType.ArcNULL) {
                var vx = root.length / root.arcParam[0];
                var vy = root.length / root.arcParam[1];
                var r = root.width * 2;
                var startAngle = root.arcParam[2], endAngle = root.arcParam[3];
                vx = root.width / vx;
                vy = root.height / vy;
                ctx.beginPath();
                console.log("arc " + vx + " " + vy + " " + r + " "
                            + startAngle + " " + endAngle + " " + root.width + " " + root.length);
                ctx.arc(vx, vy, r, startAngle, endAngle, false);
                ctx.stroke();
            }
            if (root.isCard) {
                var vx = root.length / root.cardPos[0];
                var vy = root.length / root.cardPos[1];
                if (agvIpText.text == "") {
                    ctx.fillStyle = "magenta";
                } else {
                    ctx.fillStyle = "darkBlue";
                }
                ctx.beginPath();
                ctx.arc(root.width / vx, root.height / vy, length / div,
                        0, 2 * Math.PI, false);
                ctx.fill();
            }
        }
    }

    Text {
        id: agvIpText;
        anchors.bottom: parent.bottom;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.bottomMargin: 2;
        font.pixelSize: 11;
        text: "";
        color: "darkBlue";
    }

    Text {
        id: itemText;
        anchors.top: parent.top;
        anchors.margins: 2;
        anchors.left: parent.left;
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
