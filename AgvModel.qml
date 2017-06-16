import QtQuick 2.0
import Qt.MapItemType 1.0
import Qt.MapData 1.0

Rectangle {
    id: rect;
    width: 100;
    height: 58;
    color: "#FF5809";
    opacity: 0.5;
    border.color: "red";
    border.width: 2;
    radius: 6;
    //    property alias arcPathAnimation: arcPathAnimation;
    property alias text: agvText.text;
    property int gridIndex: 0;     // AGV所在格子
    property int gridX: 0;          // 格子里AGV的坐标X, 相对于scale 1.0的情况
    property int gridY: 0;          // 格子里AGV的坐标Y
    property int r: 0;              // AGV角度, 逆时针
    property bool initFlag: false;       // 标记是否初始化成功
    property int magToCenter: 43;
    property int magLength: 20;
    property string agvStatus: "";
    property var speedVal: [0.178, 0.318, 0.444, 0.530, 0.628];
    property double dstRot: 0;
    //    property int pointRotation: 360 - r;
    rotation: 360 - r;
    //    property double orx: 0.0;
    //    property double ory: 0.0;
    //    property double orAngle: 0.0;
    //    onRChanged: {
    //        rect.orx = rect.width / 2;
    //        rect.ory = rect.height / 2;
    //        rect.orAngle = 360 - r;
    //        console.log("set r = " + rect.orx + " " + rect.ory + " " + rect.orAngle);
    //    }
    //    transform: Rotation {
    //        origin.x: rect.orx;
    //        origin.y: rect.ory;
    //        angle: rect.orAngle;
    //    }
    Text {
        id: agvText;
        anchors.centerIn: parent;
        color: "gray";
        text: "";
        rotation: rect.rotation;
    }
    Canvas {
        id: canvas;
        anchors.fill: parent;
        onPaint: {
            var plu = [magToCenter + rect.width / 2, magLength / 2 + rect.height / 2];
            var pld = [magToCenter + rect.width / 2, -magLength / 2 + rect.height / 2];
            var pru = [-magToCenter + rect.width / 2, magLength / 2 + rect.height / 2];
            var prd = [-magToCenter + rect.width / 2, -magLength / 2 + rect.height / 2];
            var ctx = getContext("2d");
            ctx.lineWidth = 3;
            ctx.strokeStyle = "lightblue";
            ctx.beginPath();
            ctx.moveTo(plu[0], plu[1]);
            ctx.lineTo(pld[0], pld[1]);
            ctx.moveTo(pru[0], pru[1]);
            ctx.lineTo(prd[0], prd[1]);
            ctx.stroke();
        }
    }

    Rectangle {
        width: 15;
        height: 50;
        anchors.verticalCenter: parent.verticalCenter;
        anchors.right: parent.right;
        anchors.rightMargin: 4;
        color: "#FF5809";
        opacity: 0.5
        border.color: "red";
        border.width: 1;
        radius: 6;
    }
    onInitFlagChanged: {
        if (initFlag == true) {
            agvTimer.running = true;
        } else {
            agvTimer.running = false;
        }
    }
    function printLine(obj) {
        if (obj.type == 0) {
            console.log("Line [ p1 (" + obj.p1.x + ", " + obj.p1.y
                        + "), p2 (" + obj.p2.x + ", " + obj.p2.y + ") ]")
        } else {
            console.log("Arc [ center (" + obj.center.x + ", " + obj.center.y
                        + "), startAngle (" + obj.startAngle + ", " + obj.endAngle + ") ]");
        }
    }
    function lineAdd(a, b) {
        var line = [];
        line[0] = a;
        if (b != null) {
            line[1] = b;
        }
        return line;
    }
    // 得到scale 1.0的X坐标
    function getOriginX() {
        var grid = parent.parent;
        var tmp = (((rect.gridIndex % grid.columns)
                    * grid.gridLength)
                   - rect.width / 2 + rect.gridX);
        return tmp;
    }
    // 得到scale 1.0的Y坐标
    function getOriginY() {
        var grid = parent.parent;
        var tmp = parseInt(rect.gridIndex / grid.columns)
                * grid.gridLength
                - rect.height / 2 + rect.gridY;
        return tmp;
    }
    function itemGetOriginX(item) {
        return item.x / rect.scale;
    }
    function itemGetOriginY(item) {
        return item.y / rect.scale;
    }
    // agv move
    function agvMove(dx, dy, dr) {
        rect.x += dx * scale;
        rect.y += dy * scale;
        rect.r += dr;
    }
    // 按照当前agv坐标判断所在index
    function updateAgvGridIndex(grid) {
        var length = grid.mapGrid.cellWidth;
        // 中心点的坐标需要加width一半的偏移，不管scale是否为1
        var x = rect.x + rect.width / 2;    // 取到AGV的中心坐标
        var y = rect.y + rect.height / 2;
        console.log("updateAgvGridIndex: " + rect.x + " " + rect.y
                    + " " + rect.width / 2 + " " + rect.height / 2);
        gridIndex = (parseInt(y / length)) * grid.columns + parseInt(x / length);
        console.log("updateAgvGridIndex: " + x + " " + y
                    + " " + parseInt(y / length) + " " + grid.columns);
        console.log("updateAgvGridIndex: length = " + length);
        gridX = (parseInt(x) % length) / scale;
        gridY = (parseInt(y) % length) / scale;
        console.log("updateAgvGridIndex:" + "(" + gridX + ", " + gridY + ")" + " " + gridIndex)
        return;
    }
    // 坐标转换index
    function coordinateTransIndex(grid, x, y) {
        var index = grid.mapGrid.indexAt(x, y);
        console.log("圆心坐标转换index: " + index);
        return index;
    }
    // set agv position
    function agvSetPosition(i, x, y, r) {
        gridIndex = i;
        gridX = x;
        gridY = y;
        rect.r = r;
    }
    // 坐标转换[x, y], 将相对于AGV Model中心点的坐标，转换为相对于grid坐标
    function agvCoordinateTransformation(x, y) {
        var point = [0, 0];
        var rad = - Math.PI * rect.r / 180;
        // 先做角度变换
        point[1] = x * Math.sin(rad) + y * Math.cos(rad);
        point[0] = x * Math.cos(rad) - y * Math.sin(rad);
        // 再做偏移变换
        point[0] += rect.getOriginX() + rect.width / 2;
        point[1] += rect.getOriginY() + rect.height / 2;
        console.log("agvCoordinateTransformation: " + "[" + rect.x + ", " + rect.y + "]" + ", h: " + rect.height + " w: " + rect.width)
        return point;
    }

    // 返回磁传感器位置[[x1, y1], [x2, y2]], 线段坐标相对于mapGrid
    function agvGetMagSensor(sta) {
        var p1 = [0, 0], p2 = [0, 0];
        if (sta == 1) {
            // 前行
            p1[0] = magToCenter;
            p1[1] = magLength / 2;
            p2[0] = magToCenter;
            p2[1] = -magLength / 2;
        } else {
            // 后退
            p1[0] = -magToCenter;
            p1[1] = magLength / 2;
            p2[0] = -magToCenter;
            p2[1] = -magLength / 2;
        }
        //console.log("1: agv MagSensor: " + p1 + " -> " + p2);
        p1 = agvCoordinateTransformation(p1[0], p1[1]);
        //console.log("2: agv MagSensor: " + p1);
        p2 = agvCoordinateTransformation(p2[0], p2[1]);
        //console.log("3: agv MagSensor: " + p2);
        console.log("agv MagSensor: " + p1 + " -> " + p2);
        return { type : 0, p1 : { x : p1[0], y : p1[1] }, p2 : { x : p2[0], y : p2[1] }};
    }
    //返回AGV方向，direction x正方向为1, y正方向为2, x负方向为-1, y负方向为-2;
    function getAgvDirection(r) {
        var direction = 0;
        var angle = 45;
        if (((r >= 360 - angle) && (r < 360)) || ((r <= 0) && (r >= -angle)) || ((r >= 0) && (r <= angle))) {
            direction = 1;
        } else if (((r >= 270 - angle) && (r <= 270  + angle)) || ((r >= -135) && (r <= -45))) {
            direction = -2;
        } else if (((r >= 180 - angle) && (r <= 180 + angle))  || ((r >= -225) && (r <= -135))) {
            direction = -1;
        } else if (((r >= 90 - angle) && (r <= 90 + angle))  || ((r >= -315) && (r <= -225))){
            direction = 2;
        }
        return direction;
    }
    //agv运行方向
    function getAgvMoveDirection(sta, dir) {
        if (((dir == 1) && (sta == 1)) || ((dir == -1) && (sta == 2))) {
            return 1;
        } else if (((dir == -1) && (sta == 1)) || ((dir == 1) && (sta == 2))) {
            return -1;
        } else if (((dir == 2) && (sta == 1)) || ((dir == -2) && (sta == 2))) {
            return 2;
        } else if (((dir == -2) && (sta == 1)) || ((dir == 2) && (sta == 2))) {
            return -2;
        } else {
            return 0;
        }
    }
    //当前格子是否存在与x轴平行的直线
    function isXLineExist(item) {
        if ((item.type == MapItemType.MapItemXLine)
                || (item.type == MapItemType.MapItemCross)
                || (item.type == MapItemType.MapItemXLStop)
                || (item.type == MapItemType.MapItemXRStop)
                || (item.type == MapItemType.MapItemXLMStop)
                || (item.type == MapItemType.MapItemXRMStop)) {
            return true;
        } else {
            console.log("warning: without Xline");
            return false;
        }
    }
    //当前格子是否存在与y轴平行的直线
    function isYLineExist(item) {
        if ((item.type == MapItemType.MapItemYLine)
                || (item.type == MapItemType.MapItemCross)
                || (item.type == MapItemType.MapItemYUStop)
                || (item.type == MapItemType.MapItemYDStop)
                || (item.type == MapItemType.MapItemYUMStop)
                || (item.type == MapItemType.MapItemYDMStop)) {
            return true;
        } else {
            console.log("warning: without Yline");
            return false;
        }
    }
    //当前格子是否曲线弯道
    function isArcLineExist(item) {
        if (item.isArc != MapItemType.ArcNULL) {
            return true;
        } else {
            console.log("warning: without arcLine");
            return false;
        }
    }
    // 计算两点之间坐标差值
    function calPointDiff(p1, p2) {
        return Math.abs(p1.x - p2.x) + Math.abs(p1.y - p2. y);
    }
    // 连接两条线段，返回最终线段，如果距离太远，则返回false
    function linesConnect(l1, l2) {
        var a = [[l1.p1, l2.p1], [l1.p2, l2.p1], [l1.p1, l2.p2], [l1.p2, l2.p2]];
        var i;
        console.log("linesConnect " + a);
        for (i = 0; i < a.length; i++) {
            var diff = calPointDiff(a[i][0], a[i][1]);
            console.log("diff " + i + " " + diff);
            if (diff < 4) {
                break;
            }
        }
        if (i == a.length) {
            console.log("linesConnect: waring lines too far");
            printLine(l1);
            printLine(l2);
            return false;
        }
        var line;
        switch (i) {
        case 0:
            line = { type : 0, p1 : l1.p2, p2 : l2.p2 };
            break;
        case 1:
            line = { type : 0, p1 : l1.p1, p2 : l2.p2 };
            break;
        case 2:
            line = { type : 0, p1 : l1.p2, p2 : l2.p1 };
            break;
        case 3:
            line = { type : 0, p1 : l1.p1, p2 : l2.p1 };
            break;
        default:
            return false;
        }
        return line;
    }
    //返回当前格子内与x轴平行的直线的线段
    function getXLineCurve(item) {
        var line, line1, line2;
        if (isXLineExist(item) == true) {
            line = { type : 0, p1 : { x : 0, y : item.length / 2 },
                p2 : { x : item.length, y : item.length / 2 } };
            console.log("getXLineCurve:");
            printLine(line);
            curveTransformation(line, item);
            console.log("getXNegativeArcOrLine  get line." );
            return line;
        } else {
            console.log("warning: without XlineCure");
            return false;
        }
    }
    //返回当前格子内与y轴平行的直线的线段
    function getYLineCurve(item) {
        var line;
        if (isYLineExist(item) == true) {
            line = { type : 0, p1 : { x : item.length * scale / 2, y : 0 },
                p2 : { x : item.length * scale / 2, y : item.length * scale } };
            curveTransformation(line, item);
            return line;
        } else {
            console.log("warning: without YlineCure");
            return false;
        }
    }
    // 得到半条线, isPositive 表示正负方向, isX 表示XY轴
    function _getHalfLineCurve(item, isX, isPositive) {
        var p1 = [], p2 = [];
        if (isX) {
            // xLine case
            console.log("_getHalfLineCurve isX true");
            if (isPositive) {
                console.log("_getHalfLineCurve isPositive is true");
                p1[0] = item.length / 2;
                p1[1] = item.length / 2;
                p2[0] = item.length + item.length * 2;
                p2[1] = item.length / 2;
            } else {
                console.log("_getHalfLineCurve isPositive is false");
                p1[0] = 0 - item.length * 2;
                p1[1] = item.length / 2;
                p2[0] = item.length / 2;
                p2[1] = item.length / 2;
            }
        } else {
            if (isPositive) {
                p1[0] = item.length / 2;
                p1[1] = item.length / 2;
                p2[0] = item.length / 2;
                p2[1] = item.length + item.length * 2;
            } else {
                p1[0] = item.length /2;
                p1[1] = 0 - item.length * 2;
                p2[0] = item.length / 2;
                p2[1] = item.length / 2;
            }
        }
        var line = { type: 0, p1: {x: p1[0], y: p1[1]}, p2: {x: p2[0], y: p2[1]}};
        curveTransformation(line, item);
        return line;
    }

    //cutLeftUp or cutRightDown
    function getHalfLineCurve(item, isX) {
        if (isX) {
            console.log("getHalfLineCurve isX true");
            if (item.cutRightDown == true){
                console.log("getHalfLineCurve cutRightDown is true");
                return _getHalfLineCurve(item, isX, false);
            } else if (item.cutLeftUp == true) {
                console.log("getHalfLineCurve cutLeftUp is true");
                return _getHalfLineCurve(item, isX, true);
            } else {
                console.log("getHalfLineCurve cut none");
                return false;
            }
        } else {
            console.log("getHalfLineCurve isX false");
            if (item.cutRightDown == true){
                console.log("getHalfLineCurve cutRightDown is true");
                return _getHalfLineCurve(item, isX, false);
            } else if (item.cutLeftUp == true) {
                console.log("getHalfLineCurve cutRightDown is true");
                return _getHalfLineCurve(item, isX, true);
            } else {
                return false;
            }
        }
    }
    function onlyArcLineCurve(item, dir) {
        var line;
        var grid = parent.parent;
        var circle = arcLineCurve(item);
        var index = coordinateTransIndex(grid, circle.center.x, circle.center.y);
        if ((item.isArc == MapItemType.ArcYLU) || (item.isArc == MapItemType.ArcXRD)) {
            console.log("1 only curve keep.......1" + dir)
            if ((dir == 2) || (dir == -1)) {
                console.log("only curve keep.......1");
                line = _getHalfLineCurve(grid.itemAt(index - 2 * grid.columns), true, false);
                printLine(line);
            } else if ((dir == -2) || (dir == 1)) {
                console.log("only curve keep.......2");
                line = _getHalfLineCurve(grid.itemAt(index + 2), false, true);
            }
            printLine(line);
            return line;
        }
        if ((item.isArc == MapItemType.ArcYRU) || (item.isArc == MapItemType.ArcXLD)) {
            console.log("2 only curve keep.......1" + dir)
            if (dir > 0) {
                console.log("only curve keep.......3");
                line = _getHalfLineCurve(grid.itemAt(index - 2 * grid.columns), true, true);
            } else if (dir < 0) {
                console.log("only curve keep.......4");
                line = _getHalfLineCurve(grid.itemAt(index - 2), false, true);
            }
            printLine(line);
            return line;
        }
        if ((item.isArc == MapItemType.ArcYRD) || (item.isArc == MapItemType.ArcXLU)) {
            console.log("3 only curve keep.......1" + dir)
            if ((dir == 2) || (dir == -1)) {
                console.log("only curve keep.......5");
                line = _getHalfLineCurve(grid.itemAt(index - 2), false, false);
            } else if ((dir == -2) || (dir == 1)) {
                console.log("only curve keep.......6");
                line = _getHalfLineCurve(grid.itemAt(index + 2 * grid.columns), true, true);
            }
            printLine(line);
            return line;
        }
        if ((item.isArc == MapItemType.ArcYLD) || (item.isArc == MapItemType.ArcXRU)) {
            console.log("4 only curve keep.......1" + dir)
            if (dir > 0) {
                console.log("only curve keep.......7");
                line = _getHalfLineCurve(grid.itemAt(index + 2), false, false);
            } else if (dir < 0) {
                console.log("only curve keep.......8");
                line = _getHalfLineCurve(grid.itemAt(index + 2 * grid.columns), true, false);
            }
            printLine(line);
            return line;
        }
        console.log("only curve false;;;;;;;;;;;;;;;;");
    }

    function arcLineCurve(item) {
        var grid = parent.parent;
        var center = arcCenterTransformation(item);
        var arcType;
        if (item.isArc != MapItemType.ArcNULL) {
            arcType = { type : 1, center : {x : center.x, y : center.y},
                r : 100, startAngle : item.arcParam[2], endAngle : item.arcParam[3]};
            return arcType;
        }
        else {
            console.log("warning: get arcLineCurve but isArc == 0");
            return false;
        }
    }
    //圆心坐标转换
    function  arcCenterTransformation(item) {
        return { x : itemGetOriginX(item) + item.arcParam[0], y : itemGetOriginY(item) + item.arcParam[1] };
    }
    //坐标转换
    function transformation(p, item) {
        return { x : itemGetOriginX(item) + p.x, y : itemGetOriginY(item) + p.y };
    }
    // 单个曲线坐标转换
    function curveTransformation(line, item) {
        if (line.type == 0) {
            line.p1 = transformation(line.p1, item);
            line.p2 = transformation(line.p2, item);
        } else {
            line.center = transformation(line.center, item);
        }
    }
    //x轴正方向运动时走直线还是弧线 返回1为直线 2为弧线
    function getXPositiveArcOrLine(item, turn, dir) {
        var arcOrLine;
        // agv在旋转过程中返回2  走曲线
        if ((rect.r != 0) && (rect.r != 180) && (rect.r != 90) && (rect.r != 270)) {
            return 2;
        }
        if (activeArcNotEqual(item, dir, true) == false) {
            return 1;
        }
        if((isXLineExist(item) == true) && (isArcLineExist(item) == true)) {
            if (((((item.isArc == MapItemType.ArcXRD) || (item.isArc == MapItemType.ArcYLU)) && (turn == 1))
                 || (((item.isArc == MapItemType.ArcXRU) || (item.isArc == MapItemType.ArcYLD)) && (turn == 2)))) {
                arcOrLine = 1;
            } if (((((item.isArc == MapItemType.ArcXRD) || (item.isArc == MapItemType.ArcYLU)) && (turn == 2))
                   || (((item.isArc == MapItemType.ArcXRU) || (item.isArc == MapItemType.ArcYLD)) && (turn == 1)))) {
                arcOrLine = 2;
            }
            return arcOrLine;
        }
        console.log("getXPositiveArcOrLine Bug.")
        return 0;

    }
    //x轴负方向运动时走直线还是弧线 返回1为直线 2为弧线
    function getXNegativeArcOrLine(item, turn, dir) {
        var arcOrLine;
        // agv在旋转过程中返回2  走曲线
        if ((rect.r != 0) && (rect.r != 180) && (rect.r != 90) && (rect.r != 270)) {
            return 2;
        }
        if (activeArcNotEqual(item, dir, true) == false) {
            return 1;
        }
        if((isXLineExist(item) == true) && (isArcLineExist(item) == true)) {
            if (((((item.isArc == MapItemType.ArcXLU) || (item.isArc == MapItemType.ArcYRD)) && (turn == 1))
                 || (((item.isArc == MapItemType.ArcXLD) || (item.isArc == MapItemType.ArcYRU)) && (turn == 2)))) {
                arcOrLine = 1;
            } if (((((item.isArc == MapItemType.ArcXLU) || (item.isArc == MapItemType.ArcYRD)) && (turn == 2))
                   || (((item.isArc == MapItemType.ArcXLD) || (item.isArc == MapItemType.ArcYRU)) && (turn == 1)))) {
                arcOrLine = 2;
            }
            return arcOrLine;
        }
        console.log("getXNegativeArcOrLine Bug.")
        return 0;
    }
    //y轴正方向运动时走直线还是弧线 返回1为直线 2为弧线
    function getYNegativeArcOrLine(item, turn, dir) {
        var arcOrLine;
        // agv在旋转过程中返回2  走曲线
        if ((rect.r != 0) && (rect.r != 180) && (rect.r != 90) && (rect.r != 270)) {
            return 2;
        }
        if (activeArcNotEqual(item, dir, false) == false) {
            return 1;
        }
        if((isYLineExist(item) == true) && (isArcLineExist(item) == true)) {
            if (((((item.isArc == MapItemType.ArcYLD) || (item.isArc == MapItemType.ArcXRU)) && (turn == 1))
                 || (((item.isArc == MapItemType.ArcYRD) || (item.isArc == MapItemType.ArcXLU)) && (turn == 2)))) {
                arcOrLine = 1;
            } if (((((item.isArc == MapItemType.ArcYLD) || (item.isArc == MapItemType.ArcXRU)) && (turn == 2))
                   || (((item.isArc == MapItemType.ArcYRD) || (item.isArc == MapItemType.ArcXLU)) && (turn == 1)))) {
                arcOrLine = 2;
            }
            return arcOrLine;
        }
        console.log("getYPositiveArcOrLine Bug.")
        return 0;
    }
    //y轴负方向运动时走直线还是弧线 返回1为直线 2为弧线
    function getYPositiveArcOrLine(item, turn, dir) {
        var arcOrLine;
        // agv在旋转过程中返回2  走曲线
        if ((rect.r != 0) && (rect.r != 180) && (rect.r != 90) && (rect.r != 270)) {
            return 2;
        }
        if (activeArcNotEqual(item, dir, false) == false) {
            return 1;
        }
        if((isYLineExist(item) == true) && (isArcLineExist(item) == true)) {
            if (((((item.isArc == MapItemType.ArcYRU) || (item.isArc == MapItemType.ArcXLD)) && (turn == 1))
                 || (((item.isArc == MapItemType.ArcYLU) || (item.isArc == MapItemType.ArcXRD)) && (turn == 2)))) {
                arcOrLine = 1;
            } if (((((item.isArc == MapItemType.ArcYRU) || (item.isArc == MapItemType.ArcXLD)) && (turn == 2))
                   || (((item.isArc == MapItemType.ArcYLU) || (item.isArc == MapItemType.ArcXRD)) && (turn == 1)))) {
                arcOrLine = 2;
            }
            return arcOrLine;
        }
        console.log("getYNegativeArcOrLine Bug.")
        return 0;
    }
    // 如果neighbour，则导出相应的arc标识
    function getActualArcType(item) {
        if (item.isArc == MapItemType.ActNULL) {
            return MapItemType.ActNULL;
        }

        if (item.isNeighbour) {
            if (item.isArc == MapItemType.ArcXLD) {
                return MapItemType.ArcYRU;
            } else if (item.isArc == MapItemType.ArcXLU) {
                return MapItemType.ArcYRD;
            } else if (item.isArc == MapItemType.ArcXRD) {
                return MapItemType.ArcYLU;
            } else if (item.isArc == MapItemType.ArcXRU) {
                return MapItemType.ArcYLD;
            } else if (item.isArc == MapItemType.ArcYLU) {
                return MapItemType.ArcXRD;
            } else if (item.isArc == MapItemType.ArcYLD) {
                return MapItemType.ArcXRU;
            } else if (item.isArc == MapItemType.ArcYRD) {
                return MapItemType.ArcXLU;
            } else if (item.isArc == MapItemType.ArcYRU) {
                return MapItemType.ArcXLD;
            }
        } else {
            return item.isArc;
        }
    }

    //判断弧线是否有用，根据direction
    function activeArcNotEqual(item, dir, isX) {
        var t;
        t = getActualArcType(item);
        if (isX) {
            if (dir > 0) {
                if (t == MapItemType.ArcXRD || t == MapItemType.ArcXRU) {
                    return true;
                } else {
                    return false;
                }
            } else {
                if (t == MapItemType.ArcXLD || t == MapItemType.ArcXLU) {
                    return true;
                } else {
                    return false;
                }
            }
        } else {
            if (dir > 0) {
                if (t == MapItemType.ArcYLU || t == MapItemType.ArcYRU
                        || t == MapItemType.ArcXRD || t == MapItemType.ArcXLD) {
                    return true;
                } else {
                    return false;
                }
            } else {
                if (t ==  MapItemType.ArcYRD || t == MapItemType.ArcYLD
                        || t == MapItemType.ArcXRU || t == MapItemType.ArcXLU) {
                    return true;
                } else {
                    return false;
                }
            }
        }
    }
    // item -> this item; nextItem -> next item; isX: 1 X, 0 Y
    function getLines(item, nextItem, sta, turn, isPositive, isX) {
        if (isX) {
            return getXLines(item, nextItem, sta, turn, isPositive);
        } else {
            return getYLines(item, nextItem, sta, turn, isPositive);
        }
    }
    //确定agv在圆弧上
    function agvOnCurve(item, sta, isPositive) {
        console.log("agvOnCurve.......1" );
        var grid = parent.parent;
        var itemone = grid.itemAt(gridIndex);
        var mag1x, mag1y, mag2x, mag2y, magCx, magCy;  // 传感器两个点坐标
        var magCv = agvGetMagSensor(sta);
        var center = arcCenterTransformation(itemone);
        var agvCenter, magC;
        var line1, line2, line;
        //agv中心坐标
        var agvCenterX = rect.getOriginX() + rect.width / 2;
        var agvCenterY = rect.getOriginY() + rect.height / 2;
        mag1x = magCv.p1.x;
        mag1y = magCv.p1.y;
        mag2x = magCv.p2.x;
        mag2y = magCv.p2.y;
        //磁导航传感器中心
        magCx = (mag1x + mag2x) / 2;
        magCy = (mag1y + mag2y) / 2;

        console.log("agvOnCurve.......2" );
        agvCenterX = agvCenterX - center.x;
        agvCenterY = agvCenterY - center.y;
        magCx = magCx - center.x;
        magCy = magCy - center.y;
        console.log("agvOnCurve.......3" );
        agvCenter = agvCenterX * agvCenterX +  agvCenterY * agvCenterY;
        console.log("agvOnCurve.......4" );
        magC = magCx * magCx + magCy * magCy;
        console.log("2. agv center = " + agvCenter);
        if (agvCenter > 9999 && agvCenter < 10001) {
            console.log("agv center = " + agvCenter);
            line1 = arcLineCurve(item);
            console.log("agv not at curve.  line1 " + line1)
            printLine(line1);
            line2 = onlyArcLineCurve(item, isPositive);
            console.log("agv not at curve.  line2 " + line2)
            printLine(line2);
            line = lineAdd(line1, line2);
            console.log("agv not at curve.  line")
            return line;
        } else {
            console.log("agv不在圆弧上: " + agvCenterX + " " + agvCenterY  + " " + magCx + " " + magCy
                        + " " + agvCenter + " " + magC);
            console.log("agv not at curve.")
        }
    }

    // item -> this item; nextItem -> next item
    function getYLines(item, nextItem, sta, turn, isPositive) {
        var r = rect.r;
        var line1, line2, line3, line;
        //判断agv是否处在正在旋转过程中
        if ((isXLineExist(item) != false) && (isArcLineExist(item) == true)) {
            line1 = arcLineCurve(item);
            line2 = onlyArcLineCurve(item, isPositive);
            line = lineAdd(line1, line2);
            console.log("agv是否处在正在旋转过程中");
            return line;
        }
        // 当前item只存在弧线不存在直线，AGV在弧上
        if (isYLineExist(item) == false) {
            console.log("warning: without isYLineExist");
            if (isXLineExist(item) == false) {
                if (isArcLineExist(item) == true) {
                    line1 = arcLineCurve(item);
                    console.log("agv onlyarcLineCurve.  y line1: ")
                    printLine(line1);
                    line2 = onlyArcLineCurve(item, isPositive);
                    console.log("agv onlyarcLineCurve.  y line2: ")
                    printLine(line2);
                    line = lineAdd(line1, line2);
                    return line;
                } return false;
            } return false;
        }
        // check cutLeft or cutRight
        // 有半条线和弧，朝弧方向运动
        if (((item.cutRightDown == true) && isPositive == -2)
                || ((item.cutLeftUp == true) && isPositive == 2)){
            //line1 = getHalfLineCurve(item, false);
            //printLine(line1);
            line2 = arcLineCurve(item);
            printLine(line2);
            line = lineAdd(line2);
            return line;
        }
        // 有半条线和弧，朝弧的相反方向运动
        if (((item.cutRightDown == true) && isPositive == 2)
                || ((item.cutLeftUp == true) && isPositive == -2)){
            line1 = getHalfLineCurve(item, false);
            printLine(line1);
            line = lineAdd(line1);
            return line;
        }
        // 当前item不存在弧线
        if (item.isArc == false) {
            printLine(getYLineCurve(item));
            printLine(getYLineCurve(nextItem));
            line1 = getYLineCurve(item);
            line2 = getYLineCurve(nextItem);
            line = linesConnect(line1, line2);
            if (line == false) {
                console.log("lines connect err. ");
                return false;
            }
            line = lineAdd(line);
            return line;
        }
        // y正方向
        // 存在直线和弧线的情况下，按照分支情况走直线
        if (getYPositiveArcOrLine(item, turn, isPositive) == 1) {
            line1 = getYLineCurve(item);
            line2 = getYLineCurve(nextItem);
            line = linesConnect(line1, line2);
            if (line == false) {
                console.log("lines connect err. ");
                return false;
            }
            console.log("存在直线和弧线的情况下，按照分支情况走直线  1;");
            line = lineAdd(line);
            return line;
        }
        // 存在直线和弧线的情况下，按照分支情况走曲线
        if (getYPositiveArcOrLine(item, turn, isPositive) == 2) {
            //line1 = _getHalfLineCurve(item, false, true);
            //printLine(line1);
            line1 = arcLineCurve(item);
            printLine(line1);
            line2 = onlyArcLineCurve(item, isPositive);
            line = lineAdd(line1, line2);
            console.log("存在直线和弧线的情况下，按照分支情况走直线  2;");
            return line;
        }
        // y负方向
        // 存在直线和弧线的情况下，按照分支情况走直线
        if (getYNegativeArcOrLine(item, turn, isPositive) == 1) {
            console.log("getYNegativeArcOrLine== 1")
            printLine(getYLineCurve(item));
            printLine(getYLineCurve(nextItem));
            line1 = getYLineCurve(item);
            line2 = getYLineCurve(nextItem);
            line = linesConnect(line1, line2);
            if (line == false) {
                console.log("lines connect err. ");
                return false;
            }
            line = lineAdd(line);
            console.log("存在直线和弧线的情况下，按照分支情况走直线  3 ;");
            return line;
        }
        // 存在直线和弧线的情况下，按照分支情况走曲线
        if (getYNegativeArcOrLine(item, turn, isPositive) == 2) {
            console.log("getYNegativeArcOrLine == 2")
            //line = arcLineCurve(item);
            //printLine(line);
            //line1 = _getHalfLineCurve(item, false, false);
            //printLine(line1);
            line1 = arcLineCurve(item);
            line2 = onlyArcLineCurve(item, isPositive);
            printLine(line2);
            line = lineAdd(line1, line2);
            console.log("存在直线和弧线的情况下，按照分支情况走直线  4;");
            return line;
        }
    }
    // item -> this item; nextItem -> next item
    function getXLines(item, nextItem, sta, turn, isPositive) {
        var r = rect.r;
        var line1, line2, line;
        //判断agv是否处在正在旋转过程中
        if ((isYLineExist(item) != false) && (isArcLineExist(item) == true)) {
            line1 = arcLineCurve(item);
            line2 = onlyArcLineCurve(item, isPositive);
            line = lineAdd(line1, line2);
            console.log("agv是否处在正在旋转过程中");
            return line;
        }
        // 当前item只存在弧线不存在直线，AGV在弧上
        if (isXLineExist(item) == false) {
            console.log("warning: without isXLineExist");
            if (isYLineExist(item) == false) {
                if (isArcLineExist(item) == true) {
                    line1 = arcLineCurve(item);
                    console.log("agv onlyarcLineCurve.  x line1: ")
                    printLine(line1);
                    line2 = onlyArcLineCurve(item, isPositive);
                    console.log("agv onlyarcLineCurve.  x line2: ")
                    printLine(line2);
                    line = lineAdd(line1, line2);
                    return line;
                } return false;
            } return false;
        }
        // check cutLeft or cutRight
        // 有半条线和弧，朝弧方向运动
        if (((item.cutRightDown == true) && isPositive == 1)
                || ((item.cutLeftUp == true) && isPositive == -1)){
            //line1 = getHalfLineCurve(item, true);
            //printLine(line1);
            line2 = arcLineCurve(item);
            printLine(line2);
            line = lineAdd(line2);
            return line;
        }
        // 有半条线和弧，朝弧的反方向运动
        if (((item.cutRightDown == true) && isPositive == -1)
                || ((item.cutLeftUp == true) && isPositive == 1)){
            line1 = getHalfLineCurve(item, true);
            printLine(line1);
            line = lineAdd(line1, null);
            return line;
        }
        // 当前item不存在弧线
        if (item.isArc == false) {;
            printLine(getXLineCurve(item));
            printLine(getXLineCurve(nextItem));
            //line1 = getXLineCurve(item);
            line1 = getXLineCurve(item);
            line2 = getXLineCurve(nextItem);
            line = linesConnect(line1, line2);
            if (line == false) {
                console.log("lines connect err. ");
                return false;
            }
            line = lineAdd(line, null);
            return line;
        }
        // x正方向
        // 存在直线和弧线的情况下，按照分支情况走直线
        if (getXPositiveArcOrLine(item, turn, isPositive) == 1) {
            console.log("getXPositiveArcOrLine== 1")
            printLine(getXLineCurve(item));
            printLine(getXLineCurve(nextItem));
            line1 = getXLineCurve(item);
            line2 = getXLineCurve(nextItem);
            line = linesConnect(line1, line2);
            if (line == false) {
                console.log("lines connect err. ");
                return false;
            }
            line = lineAdd(line);
            return line;
        }
        // 存在直线和弧线的情况下，按照分支情况走曲线
        if (getXPositiveArcOrLine(item, turn, isPositive) == 2) {
            console.log("getXPositiveArcOrLine== 2")
            //line1 = _getHalfLineCurve(item, true, true);
            //printLine(line1);
            line1 = arcLineCurve(item);
            line2 = onlyArcLineCurve(item, isPositive);
            printLine(line2);
            line = lineAdd(line1, line2);
            return line;
        }
        // x负方向
        // 存在直线和弧线的情况下，按照分支情况走直线
        if (getXNegativeArcOrLine(item, turn, isPositive) == 1) {
            console.log("getXNegativeArcOrLine== 1")
            printLine(getXLineCurve(item));
            console.log("printine success");
            printLine(getXLineCurve(nextItem));
            line1 = getXLineCurve(item);
            line2 = getXLineCurve(nextItem);
            line = linesConnect(line1, line2);
            if (line == false) {
                console.log("lines connect err. ");
                return false;
            }
            line = lineAdd(line);
            return line;
        }
        // 存在直线和弧线的情况下，按照分支情况走曲线
        if (getXNegativeArcOrLine(item, turn, isPositive) == 2) {
            console.log("getXNegativeArcOrLine == 2")
            //line1 = _getHalfLineCurve(item, true, false);
            //printLine(line1);
            line1 = arcLineCurve(item);
            line2 = onlyArcLineCurve(item, isPositive);
            printLine(line2);
            line = lineAdd(line1, line2);
            return line;
        }
        // 转换坐标系
    }
    function itemRight(index, grid) {
        var last = (index + 1) % grid.columns
        if (last == 0) {
            console.log("err cannot get itemRight " + index)
            return null;
        } else {
            var gridIndex = index + 1;
            var item = grid.itemAt(gridIndex);
            return item;
        }
    }
    function itemLeft(index, grid) {
        var last = index % grid.columns
        if (last == 0) {
            console.log("err cannot get itemLeft " + index)
            return null;
        } else {
            var gridIndex = index - 1;
            var item = grid.itemAt(gridIndex);
            return item;
        }
    }
    function itemUp(index, grid) {
        var last = index % grid.columns
        if (last == index) {
            console.log("err cannot get itemUp " + index)
            return null;
        } else {
            var gridIndex = index - grid.columns;
            var item = grid.itemAt(gridIndex);
            return item;
        }
    }
    function itemDown(index, grid) {
        if (index >= (grid.columns * (grid.rows - 1))) {
            console.log("err cannot get itemDown " + index)
            return null;
        } else {
            var gridIndex = index + grid.columns;
            var item = grid.itemAt(gridIndex);
            return item;
        }
    }
    // sta 为目标动作
    // 得到地磁曲线
    function getMagCurve(sta, turn) {
        var r = rect.r;
        var grid = parent.parent;
        var direction = getAgvDirection(r);
        var item = grid.itemAt(gridIndex);
        if (direction == 0) {
            console.log("off track. direction == 0");
            return false;
        }
        console.log("getMagCurve agv dir " + direction);
        direction = getAgvMoveDirection(sta, direction);
        if (direction == 0) {
            console.log("getAgvMoveDirection failed.");
            return false;
        }
        console.log("getMagCurve agv move dir " + direction);
        if (direction == 1) {
            var nextItem = itemRight(gridIndex, grid);
            if (nextItem == null) {
                return false;
            } else {
                return getLines(item, nextItem, sta, turn, direction, true);
            }
        } if (direction == -1) {
            nextItem = itemLeft(gridIndex, grid);
            if (nextItem == null) {
                return false;
            } else {
                return getLines(item, nextItem, sta, turn, direction, true);
            }
        } if (direction == 2) {
            nextItem = itemUp(gridIndex, grid);
            if (nextItem == null) {
                return false;
            } else {
                return getLines(item, nextItem, sta, turn, direction, false);
            }
        } if (direction == -2) {
            nextItem = itemDown(gridIndex, grid);
            if (nextItem == null) {
                return false;
            } else {
                return getLines(item, nextItem, sta, turn, direction, false);
            }
        }
    }
    function segmentsIntr(a, b, c, d) {
        //线段ab的法线N1
        var nx1 = (b.y - a.y), ny1 = (a.x - b.x);

        //线段cd的法线N2
        var nx2 = (d.y - c.y), ny2 = (c.x - d.x);

        //两条法线做叉乘, 如果结果为0, 说明线段ab和线段cd平行或共线,不相交
        var denominator = nx1*ny2 - ny1*nx2;
        if (denominator == 0) {
            return false;
        }

        //在法线N2上的投影
        var distC_N2 = nx2 * c.x + ny2 * c.y;
        var distA_N2 = nx2 * a.x + ny2 * a.y - distC_N2;
        var distB_N2 = nx2 * b.x + ny2 * b.y - distC_N2;

        // 点a投影和点b投影在点c投影同侧 (对点在线段上的情况,本例当作不相交处理);
        if (distA_N2*distB_N2 >= 0) {
            return false;
        }

        //
        //判断点c点d 和线段ab的关系, 原理同上
        //
        //在法线N1上的投影
        var distA_N1 = nx1 * a.x + ny1 * a.y;
        var distC_N1 = nx1 * c.x + ny1 * c.y - distA_N1;
        var distD_N1 = nx1 * d.x + ny1 * d.y - distA_N1;
        if (distC_N1 * distD_N1 >= 0) {
            return false;
        }

        //计算交点坐标
        var fraction = distA_N2 / denominator;
        var dx = fraction * ny1;
        var dy = -fraction * nx1;
        return { x: a.x + dx , y: a.y + dy };
    }
    // 判断点(x, y)是否在sa->ea内，要求sa < ea [-PI, PI]
    function pointIsAtArc(x, y, x0, y0, sa, ea) {
        x -= x0;
        y -= y0;
        var th = Math.atan2(y, x);
        console.log("th = " + th);
        if (th < 0) {
            th += 2 * Math.PI;
        }
        console.log("th2 = " + th);
        if (th > sa && th < ea) {
            console.log(x + ", " + y + " at (" + x0 + ", " + y0 + ") (" + sa + " -> " + ea + ")");
            return true;
        }
        console.log(x + ", " + y + " not at (" + x0 + ", " + y0 + ") (" + sa + " -> " + ea + ")");
        return false;
    }
    // 求圆和线段的交点，参考http://thecodeway.com/blog/?p=932
    function segmentArcIntr(p1, p2, c0, r, sa, ea) {
        var p;
        var x2 = p2.x;
        var x1 = p1.x;
        var y1 = p1.y;
        var y2 = p2.y;
        var x3 = c0.x;
        var y3 = c0.y;
        var a = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
        var b = 2 * ((x2 - x1) * (x1 - x3) + (y2 - y1) * (y1 - y3));
        var c = x3 * x3 + y3 * y3 + x1 * x1 + y1 * y1 - 2 * (x3 * x1 + y3 * y1) - r * r;
        var b2 = b * b;
        var ac4 = a * c * 4;
        if (b2 <= ac4) {
            console.log("segmentArcIntr b2 < 4ac: " + b2 + " " + ac4);
            return false;
        }
        var u1 = (-b + Math.sqrt(b2 - ac4)) / 2 / a;
        var u2 = (-b - Math.sqrt(b2 - ac4)) / 2 / a;
        console.log("segmentArcIntr: u1 " + u1 + ", u2 " + u2);
        if ((u1 < 0 && u2 < 0) || (u1 > 1 && u2 > 1)) {
            console.log("segmentArcIntr 没有交点且在圆外");
            return false;
        }
        if ((u1 > 1 && u2 <0) || (u1 < 0 && u2 > 1)) {
            console.log("segmentArcIntr 没有交点且在圆内");
            return false;
        }
        console.log("segmentArcIntr 与圆存在交点");
        var x = 0.0, y = 0.0;
        if (u2 < 1 && u2 > 0) {
            x = x1 + (x2 - x1) * u2;
            y = y1 + (y2 - y1) * u2;
            console.log("存在一个交点 u2 (" + x + ", " + y + ")");
            if (pointIsAtArc(x, y, c0.x, c0.y, sa, ea) == true) {
                return { x: x , y: y }
            }
            return false;
            //return pointIsAtArc(x, y, c0.x, c0.y, sa, ea);
        } else if (u1 < 1 && u1 > 0) {
            x = x1 + (x2 - x1) * u1;
            y = y1 + (y2 - y1) * u1;
            console.log("存在一个交点 u1 (" + x + ", " + y + ")");
            if (pointIsAtArc(x, y, c0.x, c0.y, sa, ea) == true) {
                return { x: x , y: y }
            }
            return false;
            //return pointIsAtArc(x, y, c0.x, c0.y, sa, ea);
        } else if (u1 < 1 && u1 > 0 && u2 < 1 && u2 > 0) {
            console.log("存在两个交点");
            x = x1 + (x2 - x1) * u1;
            y = y1 + (y2 - y1) * u1;
            console.log("一个交点 u1 (" + x + ", " + y + ")");
            if (pointIsAtArc(x, y, c0.x, c0.y, sa, ea)) {
                return true;
            }
            x = x1 + (x2 - x1) * u2;
            y = y1 + (y2 - y1) * u2;
            console.log("一个交点 u2 (" + x + ", " + y + ")");
            if (pointIsAtArc(x, y, c0.x, c0.y, sa, ea) == true) {
                return { x: x , y: y }
            }
            return false;
            //return pointIsAtArc(x, y, c0.x, c0.y, sa, ea);
        } else {
            console.log("segmentArcIntr Bug: can not reach");
            return false;
        }
    }
    // 判断两曲线是否有交点，cv1 直线，cv2 直线/曲线
    // 线段cv定义 { type: 0, p1: {x: 0, y: 0}, p2: {x: 0, y: 0} }
    // 弧线cv定义 { type: 1, center: {x: 0, y: 0}, r: 100, startAngle: PI, endAngle: PI / 2 }
    function curveIsCross(cv1, cv2) {
        if (cv1.type == null || cv2.type == null) {
            return false;
        }
        if (cv1.type != 0) {
            return false;
        }
        if (cv1.type == 0 && cv2.type == 0) {
            console.log("curveIsCross two lines")
            return segmentsIntr(cv1.p1, cv1.p2, cv2.p1, cv2.p2);
        }
        if (cv1.type == 0 && cv2.type == 1) {
            console.log("curveIsCross lines & arc")
            return segmentArcIntr(cv1.p1, cv1.p2, cv2.center, cv2.r, cv2.startAngle, cv2.endAngle);
        }
        return false;
    }

    function checkAGVIsOnMagSensor(act, cv) {
        // 得到Mag Sensor曲线
        var magCv = agvGetMagSensor(act);
        // 判断是否有交点
    }

    // 计算圆弧r上经过d的角度
    function calDeltaAngle(r, d) {
        return d / r;
    }

    // 计算此次行走距离，返回行走距离 点
    function calDeltaDistance(sp) {
        if (sp > 5 || sp < 1) {
            return 0;
        }
        sp -= 1;
        return agvTimer.interval * speedVal[sp] / 1000 * 100;   // cm <=> 点
    }
    // 计算下一个位置
    // cv: 磁条曲线list
    // crossType: 与MagSensor相交的曲线类型 0: 直线; 1: 圆弧
    // dir: 行走方向，相对于世界坐标系
    function calNextPosition(cv, crossType, dir) {
        if (crossType == 1) {

        }

        if (cv.length == 1) {

        }
    }
    function isAgvMove(infos) {
        var sta = infos.sta;
        if (sta == 1 || sta == 2 || sta == 3 || sta == 4
                || sta == 5 || sta == 6 || sta == 9) {
            return true;
        }
        return false;
    }
    function agvCurveMove(dir, cv, act) {
        var grid = parent.parent;
        var radius = 100;
        var a = 5 * Math.PI;
        var center, rot;
        var x = 0, y = 0, r = 0;
        //var index = coordinateTransIndex(grid, cv.x, cv.y);
        var t, angle;
        var item = grid.itemAt(gridIndex);
        var agvCenterX = rect.getOriginX() + rect.width / 2;
        var agvCenterY = rect.getOriginY() + rect.height / 2;
        t = getActualArcType(item);
        //center = arcCenterTransformation(item);
        //agv得到移动偏移量
        console.log("agvCurveMove xy = " + agvCenterX + " " + agvCenterY);
        rot = pycalPoint(agvCenterX, agvCenterY, a, act);
        x = rot.xx;
        y = rot.yy;
        console.log("rot 1 xy = " + x + " " + y);
        //agv偏移之后的旋转角度
        rot = pycalPoint(agvCenterX + x, agvCenterY + y, magToCenter, act);

        console.log("rot 2 xy = " + agvCenterX + x + " " + agvCenterY + y);
        angle = rot.angle;
        if (t == MapItemType.ArcXRD || t == MapItemType.ArcYLU) {
            if (dir == 1 || dir == -2) {
                if (act == 1) {
                    r = -angle;
                } else if (act == 2) {
                    r = 180 -angle;
                }
            } else if (dir == -1 || dir == 2) {
                if (act == 1) {
                    r = 90 + (90 - angle);
                } else if (act == 2) {
                    r = 270 + (90 - angle);
                }
            }
        } else if (t == MapItemType.ArcXRU || t == MapItemType.ArcYLD) {
            if (dir == 1 || dir == 2) {
                if (act == 1) {
                    r = angle;
                } else if (act == 2) {
                    r = 180 + angle;
                }
            } else if (dir == -1 || dir == -2) {
                if (act == 1) {
                    r = 270 - (90 - angle);
                } else if (act == 2) {
                    r = 90 - (90 - angle);
                }
            }
        } else if (t == MapItemType.ArcYRD || t == MapItemType.ArcXLU) {
            if (dir == 1 || dir == -2) {
                if (act == 1) {
                    r = 270 + (90 - angle);
                } else if (act == 2) {
                    r = 90 + (90 - angle);
                }
            } else if (dir == -1 || dir == 2) {
                if (act == 1) {
                    r = 180 - angle;
                } else if (act == 2) {
                    r = - angle;
                }
            }
        } else if (t == MapItemType.ArcYRU || t == MapItemType.ArcXLD) {
            if (dir == -1 || dir == -2) {
                if (act == 1) {
                    r = 180 + angle;
                } else if (act == 2) {
                    r = angle;
                }
            } else if (dir == 1 || dir == 2) {
                if (act == 1) {
                    r = 90 - (90 - angle);
                } else if (act == 2) {
                    r = 270 - (90 - angle);
                }
            }
            console.log("ArcYRU  ArcXLD  dir = " + dir)
        } else {
            x = 0;
            y = 0;
            r = 0;
        }
        console.log("agvCurveMove x y r: " + x + " " + y + " " + r);
        return { x : x, y : y, r : r };
    }
    //弧长为a时，xy值得变化
    function zeroXY(a) {
        var x, y;
        var radius = 100;
        var m = Math.sin(a / radius);
        var n = Math.cos(a / radius);
        x = radius * m;
        y = radius - radius * n;
        return {x: x, y: y};
    }
    function minAB(a, b) {
        if (a < b) {
            return a;
        } else if (a > b) {
            return b;
        } else {
            console.log(" a = b. ->false")
            return false;
        }
    }
    function calXCircle2(by, r, l) {
        var cy;
        if (by > 0) {
            cy = by - l * l / 2 / r;
        } else {
            cy = by + l * l / 2 / r;
        }
        var cxx = r * r - cy * cy;
        var cx1 = -Math.sqrt(cxx);
        var cx2 = -cx1;
        return [cx1, cy, cx2, cy];
    }

    function calYCircle2(bx, r, l) {
        var cx;
        if (bx > 0) {
            cx = bx - l * l / 2 / r;
        } else {
            cx = bx + l * l / 2 / r;
        }
        var cyy = r * r - cx * cx;
        var cy1 = -Math.sqrt(cyy);
        var cy2 = -cy1;
        return [cx, cy1, cx, cy2];
    }

    function calCircle2(x0, y0, l) {
        var ax = 0;
        var ay = 0;
        var bx = x0;
        var by = y0;
        var ab = Math.sqrt(Math.pow(ax - bx, 2) + Math.pow(ay - by, 2));
        var ac = 100;
        var bc = l;
        console.log(ab + " " + ac + " " + bc)
        var L = ab;
        var K1, K2, X0, Y0, R;
        var cx1, cx2, cy1, cy2;
        if (bx == ax || by == ay) {
            if (bx == ax) {
                return calXCircle2(by, ab, l);
            } else {
                return calYCircle2(bx, ab, l);
            }
        } else {
            K1 = (by - ay) / (bx - ax);
            K2 = -1 / K1;
        }

        X0 = ax + (bx - ax) * (Math.pow(ac, 2) - Math.pow(bc, 2) + Math.pow(L, 2)) / (2 * Math.pow(L, 2));
        Y0 = ay + K1 * (X0 - ax);

        R = Math.pow(ac, 2) - Math.pow((X0 - ax), 2) - Math.pow((Y0 - ay), 2);

        //则要求点C1(cx1,cy1),C2(cx2,cy2)的坐标为
        cx1 = X0 - Math.sqrt(R / (1 + Math.pow(K2, 2)));
        cy1 = Y0 + K2 * (cx1 - X0);
        cx2 = X0 + Math.sqrt(R / (1 + Math.pow(K2, 2)));
        cy2 = Y0 + K2 * (cx2 - X0);
        return [cx1, cy1, cx2, cy2];
    }
    //x,y->agv中心 l->弦长  startX, startY->agv初始姿态点
    function pycalPoint(x, y, l, sta) {
        var grid = parent.parent;
        var item = grid.itemAt(gridIndex);
        var center = arcCenterTransformation(item);
        var x1, y1, x2, y2, angle, angle1;
        var xx, yy; //最终返回的需要平移的距离；
        var mag1x, mag1y, mag2x, mag2y, magCx, magCy;
        var line1, line2;
        var compare;
        var magCv = agvGetMagSensor(sta);
        mag1x = magCv.p1.x;
        mag1y = magCv.p1.y;
        mag2x = magCv.p2.x;
        mag2y = magCv.p2.y;
        console.log("传感器两个点初始值 = " + mag1x + " " + mag1y + " " + mag2x + " " + mag2y);
        //磁导航传感器中心
        magCx = (mag1x + mag2x) / 2;
        magCy = (mag1y + mag2y) / 2;
        //坐标转换
        x = x - center.x;
        y = y - center.y;
        console.log("magC初始值 = " + magCx + " " + magCy);
        magCx = magCx - center.x;
        magCy = magCy - center.y;
        //计算交点
        var pycal;
        console.log("pycal x y l : " + x + " " + y + " " + l);
        pycal = calCircle2(x, y, l);
        console.log(pycal);
        //与圆分别有两个交点
        x1 = pycal[0];
        y1 = pycal[1];
        x2 = pycal[2];
        y2 = pycal[3];
        console.log("pycal = " + "(" + x1 + "，" + y1 + ")"  + "(" + x2 + "，" + y2 + ")" );
        //计算两点和磁导航中心之间的分别直线距离进行比较
        line1 = Math.sqrt((x1 - magCx) * (x1 - magCx) + (y1 - magCy) * (y1 - magCy));
        line2 = Math.sqrt((x2 - magCx) * (x2 - magCx) + (y2 - magCy) * (y2 - magCy));
        console.log("magC = " + magCx + " " + magCy);
        console.log("line = " + line1 + " " + line2);
        //对两个交点进行判断取舍
        compare = minAB(line1, line2);
        if(compare == line1) {
            xx = x1;
            yy = y1;
        } else if (compare == line2) {
            xx = x2;
            yy = y2;
        } else {
            return false;
        }
        angle = Math.atan(Math.abs(yy - y) / Math.abs(xx - x));
        //console.log( "求出点的坐标和agv中心坐标1 = " + xx + " " + yy + " " + x + " " + y);
        angle = angle / 2 / Math.PI * 360;

        //算出agv移动到相交点时的偏移
        xx = xx - x;
        yy = yy - y;
        return { xx: xx , yy: yy, angle: angle};

    }
    //x,y->agv中心 l->弦长  startX, startY->agv初始姿态点
    function magSensorCenter(x, y, l) {
        //var l = magToCenter;
        var grid = parent.parent;
        var item = grid.itemAt(gridIndex);
        var center = arcCenterTransformation(item);
        var centerX = rect.getOriginX() + rect.width / 2;
        var centerY = rect.getOriginY() + rect.height / 2;
        var r = 100;   //半径
        var x1, x2, y1, y2;    //已知弦长的下一个与圆的交点
        var zero;
        var m, n, p, q, t, t1, angle, angle1;
        x = x - center.x;
        y = y - center.y;
        centerX = centerX - center.x;
        centerY = centerY - center.y;
        console.log("agv中心值 x = " + x + "  y = " + y);
        if ((y == 0)) {
            zero = zeroXY(l);
            x1 = zero.x;
            x2 = zero.x;
            y1 = zero.y;
            y2 = zero.y;
            console.log("if y == 0   x1 = " + x1 + "  x2 = " + x2 + " y1 = " + y1 + "  y2 = " + y2);
            return { x1: x1 , y1: y1, x2: x2, y2: y2};
        }
        m = r * r - l * l / 2;
        n = 1 + (x * x) / (y * y);
        p = (2 * m * x) / (y * y);
        q = (m * m) / (y * y) - r * r;
        t = p * p - 4 * n * q;
        if (t < 0) {
            console.log("t < 0  false");
            return false;
        }
        if (t == 0) {
            x1 = x2 = p / (2 * n);
            y1 = y2 = Math.abs( Math.sqrt(r * r - x1 * x1));
            console.log("x1 = " + x1 + "  x2 = " + x2 + " y1 = " + y1 + "  y2 = " + y2);
            return { x1: x1 , y1: y1, x2: x2, y2: y2};
        }
        t1 = Math.sqrt(t);
        //求出相交点坐标
        x1 = (p + t1) / (2 * n);
        x2 = (p - t1) / (2 * n);
        y1 = Math.abs( Math.sqrt(r * r - x1 * x1));
        y2 = Math.abs( Math.sqrt(r * r - x2 * x2));
        //angle = Math.sqrt((startX - x1) * (startX - x1) + (startY - y1) * (startY - y1)) / r;
        //angle = Math.asin(Math.abs(y1 - y) / l);
        //angle = angle / 2 / Math.PI * 360;
        console.log("交点坐标 x1 = " + x1 + "  x2 = " + x2 + " y1 = " + y1 + "  y2 = " + y2);

        angle = Math.atan(Math.abs(y1 - Math.abs(y)) / Math.abs(x1 - Math.abs(x)));
        console.log( "求出点的坐标和agv中心坐标1 = " + y1 + " " + y + " " + x1 + " " + x);
        //console.log(" Math.atan1 = " + Math.abs(y1 - Math.abs(y)) + " " + Math.abs(x1 - Math.abs(centerX)))
        angle = angle / 2 / Math.PI * 360;
        console.log( "angle1 ====== " + angle);


        angle1 = Math.atan(Math.abs(y2 - Math.abs(y)) / Math.abs(x2 - Math.abs(x)));
        console.log( "求出点的坐标和agv中心坐标2 = " + y2 + " " + y + " " + x2 + " " + x);
        //console.log(" Math.atan2 = " + Math.abs(y2 - Math.abs(y)) + " " + Math.abs(x2 - Math.abs(centerX)))
        angle1 = angle1 / 2 / Math.PI * 360;
        console.log( "angle2 ====== " + angle1);

        //算出agv移动到相交点时的偏移
        x1 = Math.abs(Math.abs(x1) - Math.abs(x));
        x2 = Math.abs(Math.abs(x2) - Math.abs(x));
        y1 = Math.abs(Math.abs(y1) - Math.abs(y));
        y2 = Math.abs(Math.abs(y2) - Math.abs(y));


        console.log("偏移量  x1 = " + x1 + "  x2 = " + x2 + " y1 = " + y1 + "  y2 = " + y2);
        return { x1: x1 , y1: y1, x2: x2, y2: y2, angle: angle, angle1: angle1};
    }
    function rotationAngle(x1, y1, x2, y2) {
        var l,zero;          // AGV中心距离磁导航长度
        var cenX = rect.getOriginX() + rect.width / 2;    // 取到AGV的中心坐标
        var cenY = rect.getOriginY() + rect.height / 2;
        var grid = parent.parent;
        var item = grid.itemAt(gridIndex);
        var center = arcCenterTransformation(item);
        //var x1, y1;     // 圆弧顶点坐标
        //var x2, y2;     // AGV中心与圆的交点坐标
        //var a, b;       // 圆心
        var r = 100;    //半径
        var arc = 10 * Math.PI;       //每次所走弧长
        var t;                     // AGV需要旋转角度
        var p, q;
        var c1, a1, d1, e1, f1, m1, n1, l1, t1;
        var xx1, yy1, xx2, yy2;
        l = 2 * r * Math.sin(arc / r / 2);
        console.log("l = " + l);
        //世界坐标转换成小坐标
        x1 = x1 - center.x;
        y1 = y1 - center.y;
        x2 = x2 - center.x;
        y2 = y2 - center.y;
        cenX = cenX - center.x;
        cenY = cenY - center.y;
        console.log("x = " + x1 + "  y = " + y1);
        c1 = l * l - x1 * x1 - y1 * y1;
        a1 = r * r;
        d1 = (a1 -c1) / 2;
        if ((x1 == 0)) {
            zero = zeroXY(arc);
            xx1 = zero.x;
            xx2 = zero.x;
            yy1 = zero.y;
            yy2 = zero.y;
        } else if ((y1 == 0)) {
            zero = zeroXY(arc);
            xx1 = zero.y;
            xx2 = zero.y;
            yy1 = zero.x;
            yy2 = zero.x;
        } else {
            e1 = d1 / x1;
            console.log("e1 = " + e1);
            f1 = y1 / x1;
            m1 = f1 * f1 + 1;
            n1 = 2 * e1 * f1;
            l1 = e1 * e1 - a1;
            t1 = Math.sqrt(n1 * n1 - 4 * m1 * l1);
            if (t1 < 0) {
                return false;
            }
            console.log("l = " + l + "  c1 = " + c1 + " a1 = " + a1 + "  d1 = " + d1);
            yy1 = (n1 + t1) / (2 * m1);
            yy2 = (n1 - t1) / (2 * m1);
            xx1 = Math.abs( Math.sqrt(a1 - yy1 * yy1));
            xx2 = Math.abs( Math.sqrt(a1 - yy2 * yy2));
            console.log("centerx = " + cenX + " " + cenY + " " + xx2+ " " + yy2);
            xx2 = Math.abs(xx2 - cenX) ;
            yy2 = Math.abs(yy2 - cenY);
            console.log("centerx = " + cenX + " " + cenY + " " + xx2+ " " + yy2);
        }
        p = Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) / r;
        t = p + arc / r / 2;
        t = t / 2 / Math.PI * 360;
        console.log("xx1 = " + xx1 + "  xx2 = " + xx2 + " yy1 = " + yy1 + "  yy2 = " + yy2 + " t = " + t);
        return { x1: xx1 , y1: yy1, x2: xx2, y2: yy2, angle: t};
    }

    // agv移动距离 返回值为偏移量
    function agvMoveTo(sp, act, direction, type, cv) {
        var magCv;
        var x = 0, y = 0, r = 0;
        var Online;
        if (type == 0) {
            Online = agvCenterOnline(type, direction, act, sp);
            console.log("x,y,r = " + Online.x + " " + Online.y + " " + Online.r);
            return {x: Online.x, y: Online.y, r: Online.r};
        } else if (type == 1) {
            return agvCurveMove(direction, cv, act);
        }
    }
    //旋转到平移的角度转换
    function moveRot(direction, act) {
        //平移原始角度
        if(act == 1) {
            switch(direction) {
            case 1:
                r = 0;
                break;
            case -1:
                r = 180;
                break;
            case 2:
                r = 90;
                break;
            case -2:
                r = 270;
                break;
            default:
                return false;
            }
        } else if (act == 2) {
            switch(direction) {
            case 1:
                r = 180;
                break;
            case -1:
                r = 0;
                break;
            case 2:
                r = 270;
                break;
            case -2:
                r = 90;
                break;
            default:
                return false;
            }
        }
        return r;
    }
    //判断agv中心是否在圆上
    function judgePointOnCurve(agvX, agvY, a) {
        var agvxy;
        var lineArc;
        var point; //agv中心是否落在四分之一圆内
        var gridX, gridY, agvGridX, agvGridY;
        var grid = parent.parent;
        var item = grid.itemAt(gridIndex);
        var indexX, indexY, oncurve;  //agv所在index中心的xy值  oncurve为xy坐标平方和（方便判断点是否在圆上）
        var center = arcCenterTransformation(item);
        //所在item的中心点
        gridX = (gridIndex % grid.columns) * grid.gridLength + grid.gridLength / 2;
        gridY = parseInt(gridIndex / grid.columns) * grid.gridLength + grid.gridLength / 2;

        agvGridX = Math.abs(gridX - indexX);
        agvGridY = Math.abs(gridY - indexY);

        //agv坐在item弧线
        if (item.isArc) {
            lineArc = arcLineCurve(item);
            //判断agv中心是否落在四分之一圆内
            point = pointIsAtArc(agvX, agvY, lineArc.center.x, lineArc.center.y, lineArc.startAngle, lineArc.endAngle);
            console.log("agvx, agvy=== " + agvX + " " + agvY)
            if (point == true) {
                return 1; //点在圆上
            } else {
                return 0; //点不在圆上
            }
        } else {
            return 0; //点不在圆上
        }
    }
    //曲线到直线之间角度转换
    function curveToLine(angle) {
        var rot;
        if((r > 0 && r < 45) || (r > 180 && r < 225)
                || (r > 90 && r < 135) || (r > 270 && r < 315)
                || (r > -90 && r < -45) || (r > -180 && r < -135)
                || (r > -270 && r < -225) || (r > -360 && r < -315)) {
            rot = r - angle;
            console.log("rect.r += " + rot);
        } else if((r > 315 && r < 360) || (r > 135 && r < 180)
                  || (r > 45 && r < 90) || (r > 225 && r < 270)
                  || (r < 0 && r > -45) || (r > -225 && r < -180)
                  || (r > -135 && r < -90) || (r > -315 && r < -270)) {
            rot = r + angle;
            console.log("rect.r -= " + rot);
        }
        return rot;
    }
    //计算出旋转完成到平移的时候agv的偏移
    function agvCenterOnline(type, direction, sta, sp) {
        var oncurve;
        var grid = parent.parent;
        var index, indexX, indexY;
        var item = grid.itemAt(gridIndex);
        var agvCenterX = rect.getOriginX() + rect.width / 2;
        var agvCenterY = rect.getOriginY() + rect.height / 2;
        var mag1x, mag1y, mag2x, mag2y, magCx, magCy;
        var x, y, r, rot;
        var a = 5 * Math.PI;
        var magCv = agvGetMagSensor(sta);
        //传感器中心点坐标
        mag1x = magCv.p1.x;
        mag1y = magCv.p1.y;
        mag2x = magCv.p2.x;
        mag2y = magCv.p2.y;
        magCx = (mag1x + mag2x) / 2;
        magCy = (mag1y + mag2y) / 2;
        //传感器中心所在index
        index = coordinateTransIndex(grid, magCx, magCy);
        //传感器中心所在index的中心xy值
        indexX = (index % grid.columns) * grid.gridLength + grid.gridLength / 2;
        indexY = parseInt(index / grid.columns) * grid.gridLength + grid.gridLength / 2;
        //判断agv中心是否正在圆上运动
        oncurve = judgePointOnCurve(agvCenterX, agvCenterY, a);
        //agv在圆上
        if(oncurve == 1) {
            console.log("agv中心在弧上行走..");
            rot = pycalPoint(agvCenterX, agvCenterY, a, sta);
            x = rot.xx;
            y = rot.yy;
            //agv中心和磁传感器中心点的角度
            if (direction == 1 || direction == -1) {
                //agv中心到传感器所在item的中心的角度
                r = Math.acos(Math.abs(indexY - (agvCenterY + y)) / magToCenter);
                //agv需要旋转的角度
                r = curveToLine(r);
            } else if (direction == 2 || direction == -2) {
                r = Math.acos(Math.abs(indexX - (agvCenterX + x)) / magToCenter);
                r = curveToLine(r);
            }
            console.log("rect.r  ===== " + rect.r)
            console.log("agv中心在弧上行走..x: x , y: y, r: r = " + x + " " + y + " " + r);
            return { x: x , y: y, r: r};
        } else {
            console.log("agv中心在直线上行走..");
            r = moveRot(direction, sta);
            if(direction == 1) {
                x = calDeltaDistance(sp);
                y = 0;
            } else if(direction == -1) {
                x = -calDeltaDistance(sp);
                y = 0;
            } else if(direction == 2) {
                y = -calDeltaDistance(sp);
                x = 0;
            } else if(direction == -2) {
                y = calDeltaDistance(sp);
                x = 0;
            } else {
                console.log("direction = " + direction);
                x = 0;
                y = 0;
                r = 0;
            }
            console.log("direction = " + direction);
            console.log("agv中心在直线上行走..x: x , y: y, r: r = " + x + " " + y + " " + r);
            return { x: x , y: y, r: r};
        }
    }
    // agv原地旋转
    function crossRotation(sta, turn) {
        var rotation1 = 8;
        var grid = parent.parent;
        var item = grid.itemAt(gridIndex);
        var line;
        //var rr;
        // agv原地旋转
        if (sta == 3) {
            console.log("sta = " + sta)
            if(item.type == MapItemType.MapItemCross) {
                if (turn == 2) {
                    r += rotation1;
                    console.log("rotation = " + r);
                    dstRot += rotation1;
                    console.log("dstRot = " + dstRot);
                } else if(turn == 1) {
                    r -= rotation1;
                    console.log("rotation = " + r);
                    dstRot += rotation1;
                    console.log("dstRot = " + dstRot);
                }
                if ((dstRot >= (90 - rotation1)) || dstRot == 90){
                    r += 90 - dstRot;
                    dstRot = 0;
                    console.log("rotation1 = " + r);
                    return r;
                }
            } else {
                r = 0;
            }
            return r;
        }
    }
    function crossTestLine(sta, turn) {
        var r = rect.r;
        var cv, crossPoint;
        var i;
        var direction = getAgvDirection(r);
        console.log("r = " + r)
        if (sta != 3) {
            if (direction == 0) {
                console.log("off track. direction == 0");
                return false;
            }
            direction = getAgvMoveDirection(sta, direction);
            if (direction == 0) {
                console.log("getAgvMoveDirection failed.");
                return false;
            }
            // 得到磁导航曲线
            var magCv = agvGetMagSensor(sta);
            // 得到磁条曲线
            cv = getMagCurve(sta, turn);
            console.log("cv.length = " + cv.length);
            if (cv == false) {
                console.log("get curve failed. ");
                return false;
            }
            // 判断AGV是否在磁条上
            for (i = 0; i < cv.length; i++) {
                console.log("check curve corss...");
                printLine(magCv);
                printLine(cv[i]);
                crossPoint = curveIsCross(magCv, cv[i]);
                console.log("crossPoint " + crossPoint.x + " " + crossPoint.y)
                if (crossPoint != false) {
                    break;
                }
                console.log("curve " + i + " Is not Cross")
            }
            if (i == cv.length) {
                console.log("agv 脱磁");
                return false;
            }
            var type = cv[i].type;
            var agvTo = agvMoveTo(turn, sta, direction, type, cv[i]);
            console.log("agvMoveTo(turn, 1, type): " + turn + " " +  type);
            rect.r = 0;

            agvMove(agvTo.x, agvTo.y, agvTo.r);
            console.log("agvTo.x, agvTo.y, agvTo.r: " + agvTo.x + " " + agvTo.y + " " + agvTo.r)
            console.log("agv current center = " + rect.x + " " + rect.width / 2 + " " + rect.y + " " + rect.width / 2);
        } else {
            r = crossRotation(sta, turn);
            //agvMove(0, 0, r);
        }
        updateAgvGridIndex(parent.parent);
        console.log(gridIndex + " " + gridX + " "  + gridY)
        // 判断动作，进行移动
    }

    Timer {
        id: agvTimer;
        interval: 100;
        running: false;
        repeat: true;
        onTriggered: {
            var cv;     // 磁条曲线
            var json = JSON.parse(agvStatus);
            var infos = json.infos;
            if (infos == null) {
                return;
            }
            var alarm = json.alarm;
            if (alarm == null) {
                return;
            }
            // 只有运动时才有效
            if (isAgvMove() == false) {
                return;
            }
            // 得到磁条曲线
            cv = getMagCurve(infos.sta, infos.turnto);
            // 判断AGV是否在磁条上

            // 判断动作，进行移动



            // 保存移动后的数据
        }
    }
    //    PathAnimation {
    //        id: arcPathAnimation;
    //        target: rect;
    //        duration: 8000;
    //        orientation:  PathAnimation.LeftFirst;
    //        orientationEntryDuration : 200;
    //        orientationExitDuration : 200;
    //        path: Path {
    //            id: arcStartPath;
    //            startX: 0; startY: 0;
    //            PathLine {id: xlinath; x: arcStartPath.startX; y: arcStartPath.startY - 204;}
    //            PathArc {
    //                id: arcEndPath;
    //                x: xlinath.x - 102; y: xlinath.y - 102;
    //                radiusX: 100; radiusY: 100;
    //                direction:PathArc.Counterclockwise;
    //            }
    //            PathLine {id: ylinath; x: arcEndPath.x - 306; y: arcEndPath.y}
    //        }
    //    }

    //    function linePath(xline, yline, xarc, yarc) {
    //        arcStartPath.startX = rect.x;
    //        arcStartPath.startY = rect.y;
    //        xlinath.x = arcStartPath.startX + xline;
    //        xlinath.y = arcStartPath.startY + yline;
    //        arcEndPath.x = xlinath.x + xarc;
    //        arcEndPath.y = xlinath.y + yarc;
    //        arcPathAnimation.running = true;
    //    }
}
