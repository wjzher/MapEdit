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
    property int gridX: 0;          // 格子里AGV的坐标X
    property int gridY: 0;          // 格子里AGV的坐标Y
    property int r: 0;              // AGV角度, 逆时针
    property bool initFlag: false;       // 标记是否初始化成功
    property int magToCenter: 43;
    property int magLength: 20;
    property string agvStatus: "";
    property var speedVal: [0.178, 0.318, 0.444, 0.530, 0.628];
    rotation: 360 - r;
    Text {
        id: agvText;
        anchors.centerIn: parent;
        color: "gray";
        text: "";
        rotation: rect.rotation;
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
    // agv move
    function agvMove(dx, dy, dr) {
        x += dx;
        y += dy;
        r += dr;
    }
    // set agv position
    function agvSetPosition(i, x, y, r) {
        gridIndex = i;
        gridX = x;
        gridY = y;
        rect.r = r;
    }
    // 坐标转换[x, y]
    function agvCoordinateTransformation(x, y) {
        var point = [0, 0];
        var rad = - Math.PI * r / 180;
        // 先做角度变换
        point[1] = x * Math.sin(rad) + y * Math.cos(rad);
        point[0] = x * Math.cos(rad) - y * Math.sin(rad);
        // 再做偏移变换
        point[0] += rect.x;
        point[1] += rect.y;
        return point;
    }

    // 返回磁传感器位置[[x1, y1], [x2, y2]], 线段坐标相对于mapGrid
    function agvGetMagSensor(act) {
        var magArr = [];
        var p1 = [0, 0], p2 = [0, 0];
        if (act == 3) {
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
        p1 = agvCoordinateTransformation(p1[0], p1[1]);
        p2 = agvCoordinateTransformation(p2[0], p2[1]);
        magArr[0] = p1;
        magArr[1] = p2;
        console.log("agv MagSensor: " + magArr[0] + " -> " + magArr[1])
        return magArr;
    }
    function getAgvDirection(act, r) {
        var direction;
        var angle = 15;
        if (((act = 3) && (((r >= 360 - angle) && (r <= 360)) || ((r >= 0) && (r <= angle))))
                || ((act = 4) && ((r >= 180 - angle) && (r <= 180 + angle)))) {
            direction = 1;
        } if (((act = 3) && ((r >= 90 - angle) && (r <= 90  + angle)))
              || ((act = 4) && ((r >= 270 - angle) && (r <= 270 + angle)))) {
            direction = 2;
        } if (((act = 4) && (((r >= 360 - angle) && (r <= 360)) || ((r >= 0) && (r <= angle))))
              || ((act = 3) && ((r >= 180 - angle) && (r <= 180 + angle)))) {
            direction = 3;
        } if (((act = 4) && ((r >= 75) && (r <= 105)))
              || ((act = 3) && ((r >= 270 - angle) && (r <= 270 + angle)))) {
            direction = 4;
        }
        else {
            direction = 0;
        }
        return direction;
    }
    function xLine(item) {
        var p1 = [0, 0], p2 = [0, 0];
        var lineType = [];
        if ((item.type == MapItemType.MapItemXLine)
                || (item.type == MapItemType.MapItemCross)
                || (item.type == MapItemType.MapItemXLStop)
                || (item.type == MapItemType.MapItemXRStop)
                || (item.type == MapItemType.MapItemXLMStop)
                || (item.type == MapItemType.MapItemXRMStop)) {
            p1[0] = item.x;
            p1[1] = item.y + item.length / 2;
            p2[0] = item.x + item.length;
            p2[1] = item.y + item.length / 2;
            lineType[0] = p1;
            lineType[1] = p2;
            //lineType = { type: 0, p1: {x: p1[0], y: p1[1]}, p2: {x: p2[0], y: p2[1]}};
            return lineType;
        } else {
            return false;
        }
    }
    function yLine(item) {
        var p1 = [0, 0], p2 = [0, 0];
        var lineType = [];
        if ((item.type == MapItemType.MapItemYLine)
                || (item.type == MapItemType.MapItemCross)
                || (item.type == MapItemType.MapItemYUStop)
                || (item.type == MapItemType.MapItemYDStop)
                || (item.type == MapItemType.MapItemYUMStop)
                || (item.type == MapItemType.MapItemYDMStop)) {
            p1[0] = item.x + item.length / 2;
            p1[1] = item.y;
            item = grid.itemAt(gridIndex - grid.columns);
            p2[0] = item.x + item.length / 2;
            p2[1] = item.y + item.length;
            lineType[0] = p1;
            lineType[1] = p2;
            //lineType = { type: 0, p1: {x: p1[0], y: p1[1]}, p2: {x: p2[0], y: p2[1]}};
            return lineType;
        } else {
            return false;
        }
    }
    function xArcLine(item) {
        var grid = parent.parent;
        var startAngle, endAngle;
        var center = [0, 0];
        var arcType;
        if (item.isArc != MapItemType.ArcNULL) {
            if ((item.isArc == MapItemType.ArcXRD) || (item.isArc == MapItemType.ArcYLU)) {
                center[0] = item.x + grid.cellWidth * 2;
                center[1] = item.x + grid.cellHeight * 2;
                startAngle = -90;
                endAngle = 0;
            } if ((item.isArc == MapItemType.ArcXRU) || (item.isArc == MapItemType.ArcYLD)) {
                center[0] = item.x + grid.cellWidth * 2;
                center[1] = item.x - grid.cellHeight * 2;
                startAngle = 0;
                endAngle = 90;
            } if ((item.isArc == MapItemType.ArcYRD) || (item.isArc == MapItemType.ArcXLU)) {
                center[0] = item.x - grid.cellWidth * 2;
                center[1] = item.x - grid.cellHeight * 2;
                startAngle = 90;
                endAngle = 180;
            } if ((item.isArc == MapItemType.ArcXLD) || (item.isArc == MapItemType.ArcYRU)) {
                center[0] = item.x - grid.cellWidth * 2;
                center[1] = item.x + grid.cellHeight * 2;
                startAngle = 180;
                endAngle = -90;
            }
            arcType = { type: 1, center: {x: center[0], y: center[1]}, r: 100, startAngle: startAngle, endAngle: endAngle }
            return arcType;
        } else {
            return false;
        }
    }
    function yArcLine(item) {
        var grid = parent.parent;
        var startAngle, endAngle;
        var center = [0, 0];
        var arcType;
        if (item.isArc != MapItemType.ArcNULL) {
        if ((item.isArc == MapItemType.ArcXRD) || (item.isArc == MapItemType.ArcYLU)) {
            center[0] = item.x - grid.cellWidth * 2;
            center[1] = item.x - grid.cellHeight * 2;
            startAngle = -90;
            endAngle = 0;
        } if ((item.isArc == MapItemType.ArcXRU) || (item.isArc == MapItemType.ArcYLD)) {
            center[0] = item.x - grid.cellWidth * 2;
            center[1] = item.x + grid.cellHeight * 2;
            startAngle = 0;
            endAngle = 90;
        } if ((item.isArc == MapItemType.ArcYRD) || (item.isArc == MapItemType.ArcXLU)) {
            center[0] = item.x + grid.cellWidth * 2;
            center[1] = item.x + grid.cellHeight * 2;
            startAngle = 90;
            endAngle = 180;
        } if ((item.isArc == MapItemType.ArcXLD) || (item.isArc == MapItemType.ArcYRU)) {
            center[0] = item.x + grid.cellWidth * 2;
            center[1] = item.x - grid.cellHeight * 2;
            startAngle = 180;
            endAngle = -90;
        }
        arcType = { type: 1, center: {x: center[0], y: center[1]}, r: 100, startAngle: startAngle, endAngle: endAngle }
        return arcType;
        } else {
            return false;
        }
    }
    function getMapItemType(act, turn, r) {
        var grid = parent.parent;
        var direction;
        var item;
        var p1 = [0, 0], p2 = [0, 0];
        item = grid.itemAt(gridIndex);
        direction = getAgvDirection(act, r);
        if (direction == 1) {
            if ((item.type == MapItemType.MapItemXLine)
                    || (item.type == MapItemType.MapItemCross)
                    || (item.type == MapItemType.MapItemXLStop)
                    || (item.type == MapItemType.MapItemXRStop)
                    || (item.type == MapItemType.MapItemXLMStop)
                    || (item.type == MapItemType.MapItemXRMStop)) {
                p1[0] = item.x;
                p1[1] = item.y + item.length / 2;
                item = grid.itemAt(gridIndex + 1);
                if (((item.isArc != MapItemType.ArcNULL)
                     || (((item.isArc == MapItemType.ArcXRD)
                          || (item.isArc == MapItemType.ArcYLU))
                         && (turn == 1))
                     || (((item.isArc == MapItemType.ArcXRU)
                          || (item.isArc == MapItemType.ArcYLD))
                         && (turn == 2)))
                        && ((item.type == MapItemType.MapItemXLine)
                            || (item.type == MapItemType.MapItemCross)
                            || (item.type == MapItemType.MapItemXLStop)
                            || (item.type == MapItemType.MapItemXRStop)
                            || (item.type == MapItemType.MapItemXLMStop)
                            || (item.type == MapItemType.MapItemXRMStop))) {
                    p2[0] = item.x + item.length;
                    p2[1] = item.y + item.length / 2;
                } else if (((item.isArc == MapItemType.ArcXRD)
                            || (item.isArc == MapItemType.ArcYLU))
                           && (turn == 2)|| (item.type == MapItemType.MapItemNULL)) {

                } else if ((((item.isArc == MapItemType.ArcXRU)
                             || (item.isArc == MapItemType.ArcYLD)) && (turn == 1))
                           || item.type == MapItemType.MapItemNULL) {

                }
            } else {
            }
        }if (direction == 2) {
            if ((item.type == MapItemType.MapItemYLine)
                    || (item.type == MapItemType.MapItemCross)
                    || (item.type == MapItemType.MapItemYUStop)
                    || (item.type == MapItemType.MapItemYDStop)
                    || (item.type == MapItemType.MapItemYUMStop)
                    || (item.type == MapItemType.MapItemYDMStop)) {
                p1[0] = item.x + item.length / 2;
                p1[1] = item.y;
                item = grid.itemAt(gridIndex - grid.columns);
                p2[0] = item.x + item.length / 2;
                p2[1] = item.y + item.length;
            }
        } if (direction == 3) {
            if ((item.type == MapItemType.MapItemXLine)
                    || (item.type == MapItemType.MapItemCross)
                    || (item.type == MapItemType.MapItemXLStop)
                    || (item.type == MapItemType.MapItemXRStop)
                    || (item.type == MapItemType.MapItemXLMStop)
                    || (item.type == MapItemType.MapItemXRMStop)) {
                p1[0] = item.x;
                p1[1] = item.y + item.length / 2;
                item = grid.itemAt(gridIndex - 1);
                p2[0] = item.x + item.length;
                p2[1] = item.y + item.length / 2;
            }
        } if (direction == 4) {
            if ((item.type == MapItemType.MapItemYLine)
                    || (item.type == MapItemType.MapItemCross)
                    || (item.type == MapItemType.MapItemYUStop)
                    || (item.type == MapItemType.MapItemYDStop)
                    || (item.type == MapItemType.MapItemYUMStop)
                    || (item.type == MapItemType.MapItemYDMStop)) {
                p1[0] = item.x + item.length / 2;
                p1[1] = item.y;
                item = grid.itemAt(gridIndex + grid.columns);
                p2[0] = item.x + item.length / 2;
                p2[1] = item.y + item.length;
            }
        } else {
        }
        //console.log("getMapItemType " + )
    }

    // act 为目标动作
    function getMagCurve(act) {
        var grid = parent.parent;
        var item = grid.itemAt(gridIndex);
        var direction = getAgvDirection(act, r);
        var xLineType, yLineType;
        var xLineType1, xLineType2, yLineType1, yLineType2;
        var xArcType, yArcType;
        //var xLineType = xLine(item);
        //var yLineType = xLine(item);
        //var xArcType = xArcLine(item);
        //var yArcType = yArcLine(item);
        if (direction == 1) {
            if ((xArcLine(item) == false) && (xLine(item) != false)) {
                xLineType1 = xLine(item);
                item = grid.itemAt(gridIndex + 1);
                if ((xArcLine(item) == false) && (xLine(item) != false)) {
                    xLineType2 = xLine(item);
                }
                xLineType = { type: 0, p1: {x: xLineType1[0], y: xLineType1[0]}, p2: {x: xLineType2[1], y: xLineType2[1]}};
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
            return pointIsAtArc(x, y, c0.x, c0.y, sa, ea);
        } else if (u1 < 1 && u1 > 0) {
            x = x1 + (x2 - x1) * u1;
            y = y1 + (y2 - y1) * u1;
            console.log("存在一个交点 u1 (" + x + ", " + y + ")");
            return pointIsAtArc(x, y, c0.x, c0.y, sa, ea);
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
            return pointIsAtArc(x, y, c0.x, c0.y, sa, ea);
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
            return segmentsIntr(cv1.p1, cv1.p2, cv2.p1, cv2.p2);
        }
        if (cv1.type == 0 && cv2.type == 1) {
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
            cv = getMagCurve();
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
