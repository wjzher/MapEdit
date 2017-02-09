import QtQuick 2.0

Rectangle {
    id: root;
    Canvas {
        contextType: "2d"
        visible: true
        anchors.fill: parent;
        onPaint: {//绘图事件的响应
            context.lineWidth=2;
            context.strokeStyle="red";
            context.fillStyle="blue";
            context.beginPath();
            context.rect(1,0,12,12);//一定要注意画图的区域不能超过画布的大小，不然会看不到或者只看到一部分
            context.fill();
            context.stroke();
        }
//        onPaint: {
//            var ctx = getContext("2d");
//            ctx.lineWidth = 2;
//            ctx.strokeStyle = "red";
//            ctx.fillStyle = "blue";
//            ctx.beginPath();
//            ctx.rect(10, 8, 12, 8);
//            ctx.fill();
//            ctx.stroke();
//        }
    }
}
