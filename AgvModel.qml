import QtQuick 2.0

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
    property int gridIndex: 50;     // AGV所在格子
    property int gridX: 0;          // 格子里AGV的坐标X
    property int gridY: 0;          // 格子里AGV的坐标Y
    property int r: 0;              // AGV角度, 逆时针
    property int magToCenter: 43;
    property int magLength: 30;
    rotation: 360 - r;
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
    function agvUpdate() {
        rect.x = parent.x + ((gridIndex % parent.parent.columns) * parent.cellWidth) - width / 2 + gridX;
        rect.y = parent.y + parseInt(gridIndex / parent.parent.columns) * parent.cellHeight - height / 2 + gridY;
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
        agvUpdate();
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
    Timer {
        interval: 100;
        running: true;
        repeat: true;
        onTriggered: {

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
