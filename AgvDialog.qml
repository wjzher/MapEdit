import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import Qt.UdpServer 1.0
import QtQuick.Controls 1.4

Window {
    id: root;
    width: 500;
    height: 260;
    title: "AGV Control";
    color: "#EEEEEE";
    modality: Qt.WindowNoState;
    Item {
            focus: true
            Keys.onPressed: {
                switch(event.key) {
                case Qt.Key_Up:
                    mfButton.clickedCallBack();
                    break;
                case Qt.Key_Down:
                    mbButton.clickedCallBack();
                    break;
                case Qt.Key_Left:
                    rccButton.clickedCallBack();
                    break;
                case Qt.Key_Right:
                    rcButton.clickedCallBack();
                    break;
                case Qt.Key_Equal:
                    rotateview.clickedCallBack();
                    break;
                case Qt.Key_Delete:
                    delButton.clickedCallBack();
                    break;
                case Qt.Key_Insert:
                    loadButton.clickedCallBack();
                    break;
                case Qt.Key_Home:
                    startButton.clickedCallBack();
                    break;
                case Qt.Key_End:
                    esButton.clickedCallBack();
                    break;
                case Qt.Key_R:
                    rightButton.clickedCallBack();
                    break;
                case Qt.Key_L:
                    leftButton.clickedCallBack();
                    break;
                case Qt.Key_S:
                    stopButton.clickedCallBack();
                    break;
                case Qt.Key_A:
                case Qt.Key_Space:
                    astopButton.clickedCallBack();
                    break;
                case Qt.Key_U:
                    lfupButton.clickedCallBack();
                    break;
                case Qt.Key_D:
                    lfdButton.clickedCallBack();
                    break;
                case Qt.Key_F1:
                    oaButton.clickedCallBack();
                    break;
                case Qt.Key_F2:
                    csButton.clickedCallBack();
                    break;
                default:
                    return;
                }
            }
        }

    UdpServer {
        id: udpServer;
        property int cmdInf: 20000;
        property int initFlag: 0;
        function paramJson(cmd) {
            var v = "{\"agvcmd\":\"";
            v += cmd;
            v += "\"}";
            return v;
        }
        function paramAgvId() {
            return "{\"agvid\":\"1\"}";
        }
        function cmdMf(speed) {
            var v = paramJson("mf " + speed);
            sendCommand(cmdInf, v);
        }
        function cmdMb(speed) {
            var v = paramJson("mb " + speed);
            sendCommand(cmdInf, v);
        }
        function cmdStop() {
            var v = paramJson("s");
            sendCommand(cmdInf, v);
        }
        function cmdAStop() {
            var v = paramJson("a");
            sendCommand(cmdInf, v);
        }
        function cmdMl() {
            var v = paramJson("ml");
            sendCommand(cmdInf, v);
        }
        function cmdMr() {
            var v = paramJson("mr");
            sendCommand(cmdInf, v);
        }
        function cmdRc() {
            var v = paramJson("rc");
            sendCommand(cmdInf, v);
        }
        function cmdRc2() {
            var v = paramJson("rc2");
            sendCommand(cmdInf, v);
        }
        function cmdRcc() {
            var v = paramJson("rcc");
            sendCommand(cmdInf, v);
        }
        function cmdRcc2() {
            var v = paramJson("rcc2");
            sendCommand(cmdInf, v);
        }
        function cmdOAOn() {
            var v = paramJson("oa 1");
            sendCommand(cmdInf, v);
        }
        function cmdOAOff() {
            var v = paramJson("oa 0");
            sendCommand(cmdInf, v);
        }
        function cmdLiftUp() {
            var v = paramJson("lf 1");
            sendCommand(cmdInf, v);
        }
        function cmdLiftDown() {
            var v = paramJson("lf 0");
            sendCommand(cmdInf, v);
        }
        function cmdCSOn() {
            var v = paramJson("cs 1");
            sendCommand(cmdInf, v);
        }
        function cmdCSOff() {
            var v = paramJson("cs 0");
            sendCommand(cmdInf, v);
        }
        function cmdDEList() {
            var v = paramJson("dellist");
            sendCommand(cmdInf, v);
        }
        function cmdEStop() {
            var v = paramAgvId();
            sendCommand(1005, v);
        }
        function cmdStart() {
            var v = paramAgvId();
            sendCommand(1003, v);
        }
        function agvShowStatus(status) {
            var json = JSON.parse(status);
            var m = json.infos;
            var n = json.alarm;
            switch (m.sta) {
            case 0:
                agvActive.text = "⊖"
                break;
            case 1:
                agvActive.text = "↑"
                break;
            case 2:
                agvActive.text = "↓"
                break;
            case 5:
                agvActive.text = "↻"
                break;
            case 6:
                agvActive.text = "↺"
                break;
            case 7:
                agvActive.text = "⚠"
                break;
            }
            switch (m.turnto) {
            case 1:
                agvBranch.text = "↰"
                break;
            case 2:
                agvBranch.text = "↱"
                break;
            }
            switch (m.v) {
            case 1:
                agvSpeed.text = "1档"
                break;
            case 2:
                agvSpeed.text = "2档";
                break;
            case 2:
                agvSpeed.text = "3档";
                break;
            case 2:
                agvSpeed.text = "4档";
                break;
            case 2:
                agvSpeed.text = "5档";
                break;
            }
            switch (m.liftsta) {
            case 1:
                toplift.opacity = 1;
                bottomlift.opacity = 0;
                break
            case 2:
                bottomlift.opacity = 1;
                toplift.opacity = 0;
                break;
            }
            switch (m.bz[0]) {
            case 0:
                oaview.color = "aquamarine";
                oaButton.color = "aquamarine";
                oaButton.oa = 0;
                if (initFlag == 0) {
                    oaButton.onOff = 1;
                }
                break
            case 1:
                oaview.color = "#EEEEEE";
                oaButton.color = "transparent";
                oaButton.oa = 1;
                if (initFlag == 0) {
                    oaButton.onOff = 0;
                }
                break;
            }
            switch (m.charge) {
            case 0:
                csview.color = "#EEEEEE";
                csButton.color = "transparent";
                csButton.cs = 0;
                if (initFlag == 0) {
                    csButton.onOff = 0;
                }
                break
            case 1:
                csview.color = "aquamarine";
                csButton.color = "aquamarine"
                csButton.cs = 0;
                if (initFlag == 0) {
                    csButton.onOff = 1;
                }
                break;
            }
            agvVoltage.text = m.voltage + "v";
            agvPrepos.text = m.prepos;
            agvNextpose.text = m.nextpos;
            if (!n.dc) {
                dcNomal.color = "aquamarine";
                dcAlarm.color = "#EEEEEE";
            } else {
                dcAlarm.color = "red";
                dcNomal.color = "#EEEEEE";
            }
            if (!n.driver) {
                moterNomal.color = "aquamarine";
                moterAlarm.color = "#EEEEEE";
            } else {
                moterAlarm.color = "red";
                moterNomal.color = "#EEEEEE";
            }
            if (!n.elec) {
                elecNomal.color = "aquamarine";
                elecAlarm.color = "#EEEEEE";
            } else {
                elecAlarm.color = "red";
                elecNomal.color = "#EEEEEE";
            }
            if (!n.lift) {
                liftNomal.color = "aquamarine";
                liftAlarm.color = "#EEEEEE";
            } else {
                liftAlarm.color = "red";
                liftNomal.color = "#EEEEEE";
            }
            if (!n.chargecommu) {
                chargeNomal.color = "aquamarine";
                chargeAlarm.color = "#EEEEEE";
            } else {
                chargeAlarm.color = "red";
                chargeNomal.color = "#EEEEEE";
            }
            if (!n.rotate) {
                rotateNomal.color = "aquamarine";
                rotateAlarm.color = "#EEEEEE";
            } else {
                rotateAlarm.color = "red";
                rotateNomal.color = "#EEEEEE";
            }
        }
        function cmdLoadPath() {
            var v = pathList.pathJson.exportParamObject();
            console.log("LoadPath: " + v);
            sendCommand(1007, v);
        }

        onAgvStatusChanged: {
//            console.log("status changed " + inf + " " + status);
            switch (inf) {
            case 20000:
                agvInfo.text = "AGV运动命令应答";
                break;
            case 1001:
                agvInfo.text = "AGV信息总召";
                break;
            case 1003:
                agvInfo.text = "AGV启动应答";
                break;
            case 1005:
                agvInfo.text = "AGV急停应答";
                break;
            case 1007:
                agvInfo.text = "AGV运动应答";
                break;
            case 5001:
                agvShowStatus(status);
                initFlag = 1;
                break;
            }
        }
        onAgvAddressChanged: {
            console.log("address changed " + ip);
            //            currentIp = ip;
            agvipCombobox.model.append({text: ip});
            initFlag = 0;
        }
    }

    Row{
        id: row;
        anchors.fill: parent;
        anchors.margins: 8;
        spacing: 4;
        GroupBox{
            id: agvConsole;
            title: "agv console";
            height: root.height - 12;
            width: 180;
            Column{
                spacing: 10
                Row {
                    spacing: 8;
                    Text {
                        y: 6;
                        text: qsTr("IP:");
                    }
                    ComboBox {
                        width: 140;
                        id: agvipCombobox;
                        onCountChanged: {
                            if (count == 1) {
                                console.log("agv ip count changed " + currentIndex + " " + model.get(currentIndex).text);
                                udpServer.currentIp = model.get(currentIndex).text;
                            }
                        }

                        model: ListModel {
                            id: model;
                            //                            ListElement {
                            //                                text: "Null";
                            //                            }
                            //                            ListElement {
                            //                                text: "192.168.2.1";
                            //                            }
                            //                            ListElement {
                            //                                text: "192.168.2.2";
                            //                            }
                        }
                        onCurrentIndexChanged: {
                            if (model.get(currentIndex) == null) {
                                return;
                            }
                            console.log("agv ip changed " + currentIndex + " " + model.get(currentIndex).text);
                            udpServer.currentIp = model.get(currentIndex).text;
                            //                            udpServer.cmdLoadPath();
                        }
                    }
                }

                Column {
                    spacing: 4;
                    Row {
                        spacing: 4;
                        FlatButton {
                            id: speedview;
                            property int dir: 0;    // 0 front 1 back
                            text: "0";
                            font.pointSize: 12;
                            toolTipText: qsTr("下发速度");
                            textColor: "black";
                            function clear() {
                                dir = 0;
                                text = 0;
                            }
                            function move() {
                                if (text == 0) {
                                    udpServer.cmdStop();
                                } else {
                                    if (dir == 0) {
                                        udpServer.cmdMf(text);
                                    } else {
                                        udpServer.cmdMb(text);
                                    }
                                }
                            }

                            function up(){
                                if (dir == 0 || speedview.text == 0) {
                                    if (speedview.text < 5) {
                                        speedview.text++;
                                        dir = 0;
                                        move();
                                    }
                                } else {
                                    if (speedview.text > 0) {
                                        speedview.text--;
                                        if (speedview.text == 0) {
                                            dir = 0;
                                        }
                                        move();
                                    }
                                }
                            }
                            function down(){
                                if (dir == 1 || speedview.text == 0) {
                                    if (speedview.text < 5) {
                                        speedview.text++;
                                        dir = 1;
                                        move();
                                    }
                                } else {
                                    if (speedview.text > 0) {
                                        speedview.text--;
                                        if (speedview.text == 0) {
                                            dir = 1;
                                        }
                                        move();
                                    }
                                }
                            }
                        }
                        FlatButton {
                            id: mfButton;
                            text: "↑";
                            function clickedCallBack(){
                                speedview.up();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("前行 Key_Up");
                        }
                        FlatButton {
                            id: rcButton;
                            text: "↻";
                            function clickedCallBack() {
                                if (rotateview.text == 90) {
                                    udpServer.cmdRc();
                                } else {
                                    udpServer.cmdRc2();
                                }
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("顺时针旋转 Key_Right");
                        }
                        FlatButton {
                            id: stopButton;
                            text: "■";
                            function clickedCallBack() {
                                speedview.clear();
                                speedview.move();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("停止 Key_S");
                        }
                    }
                    Row {
                        spacing: 4;
                        FlatButton {
                            id: rotateview;
                            font.pointSize: 12;
                            textColor: "black";
                            text:"90";
                            property int rot: 0  //0: 90°  1: 180°
                            function clickedCallBack() {
                                if (rot == 0) {
                                    text = "180";
                                    rot = 1;
                                } else {
                                    text = "90";
                                    rot = 0;
                                }
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("旋转角度 Key_Equal");
                        }
                        FlatButton {
                            id: mbButton;
                            text: "↓";
                            function clickedCallBack() {
                                speedview.down();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("后退 Key_Down");
                        }
                        FlatButton {
                            id: rccButton;
                            text: "↺";
                            function clickedCallBack() {
                                if (rotateview.text == 90) {
                                    udpServer.cmdRcc();
                                } else {
                                    udpServer.cmdRcc2();
                                }
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("逆时针旋转 Key_Left");
                        }
                        FlatButton {
                            id: astopButton;
                            text: "T";
                            function clickedCallBack() {
                                speedview.clear();
                                udpServer.cmdAStop();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("精确停止 A/space");
                        }
                    }
                }
                Column {
                    spacing: 4;
                    Row {
                        spacing: 4;
                        FlatButton {
                            id: lfupButton;
                            text: "↑";
                            width: lfdButton.width;
                            function clickedCallBack() {
                                udpServer.cmdLiftUp();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("升平台 U");
                        }
                        FlatButton {
                            id: oaButton;
                            text: "OA";
                            width: lfdButton.width;
                            property int oa;     //0 on, 1 off
                            property int onOff: 0;
                            function clickedCallBack(){
                                if (onOff == 0) {
                                    udpServer.cmdOAOn()
                                    onOff = 1;
                                } else {
                                    udpServer.cmdOAOff();
                                    onOff = 0;
                                }
                            }
                            onOaChanged: {
                                if (oa == 0) {
                                    color = "transparent";
                                } else {
                                    color = "aquamarine";
                                }
                            }
                            onOnOffChanged: {
                                if (onOff == 0) {
                                    font.underline = false;
                                } else {
                                    font.underline = true;
                                }
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("避障 F1");
                        }
                        FlatButton {
                            id: leftButton;
                            text: "↰";
                            width: lfdButton.width;
                            function clickedCallBack() {
                                udpServer.cmdMl();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("左分支 L");
                        }
                    }
                    Row {
                        spacing: 4;
                        FlatButton {
                            id: lfdButton;
                            text: "↓";
                            width: 48;
                            function clickedCallBack() {
                                udpServer.cmdLiftDown();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("降平台 D");
                        }
                        FlatButton {
                            id: csButton;
                            text: "CS";
                            width: lfdButton.width;
                            property int cs;  //0:off  1:on
                            property int onOff: 0;
                            function clickedCallBack() {
                                if (onOff == 0) {
                                    udpServer.cmdCSOn();
                                    onOff = 1;
                                } else {
                                    udpServer.cmdCSOff();
                                    onOff = 0;
                                }
                            }
                            onCsChanged: {
                                if (cs == 0) {
                                    color = "transparent";
                                } else {
                                    color = "aquamarine";
                                }
                            }
                            onOnOffChanged: {
                                if (onOff == 0) {
                                    font.underline = false;
                                } else {
                                    font.underline = true;
                                }
                            }

                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("充电继电器 F2");
                        }
                        FlatButton {
                            id: rightButton;
                            text: "↱";
                            width: lfdButton.width;
                            function clickedCallBack() {
                                udpServer.cmdMr();
                            }
                            onClicked: {
                                clickedCallBack();
                            }
                            toolTipText: qsTr("右分支 R");
                        }

                    }
                }
                Row {
                    spacing: 4;
                    FlatButton {
                        id: loadButton;
                        text: "L";
                        function clickedCallBack() {
                            udpServer.cmdLoadPath();
                        }
                        onClicked: {
                            clickedCallBack();
                        }
                        toolTipText: qsTr("加载路径 Insert");
                    }
                    FlatButton {
                        id: startButton;
                        text: "O";
                        function clickedCallBack() {
                            udpServer.cmdStart();
                        }
                        onClicked: {
                            clickedCallBack()
                        }
                        toolTipText: qsTr("解除急停 Home");
                    }
                    FlatButton {
                        id: esButton;
                        text: "ES";
                        function clickedCallBack() {
                            udpServer.cmdEStop();
                        }
                        onClicked: {
                            clickedCallBack();
                        }
                        toolTipText: qsTr("急停 End");
                    }
                    FlatButton {
                        id: delButton;
                        text: "DEL";
                        function clickedCallBack() {
                            udpServer.cmdDEList();
                        }
                        onClicked: {
                            clickedCallBack();
                        }
                        toolTipText: qsTr("删除路径 Delete");
                    }
                }
            }
        }
        Row {
            spacing: 4
            Row {
                GroupBox {
                    id: agvStatus;
                    title: "agv status";
                    width: (root.width - agvConsole.width) / 3 + 10 ;
                    height: agvConsole.height;
                    Column {
                        id: col1;
                        spacing: 4;
                        Row {
                            spacing: 4;
                            RectangleStatus{
                                id: agvActive;
                                text: "↑"
                                width: 45;
                                font: 18;
                            }
                            RectangleStatus{
                                id: agvSpeed;
                                text: "1档";
                                width: 45;
                            }
                        }
                        Row {
                            spacing: 4;
                            RectangleStatus{
                                id: agvBranch
                                text: "↰"
                                width: 45;
                                font: 18;
                            }
                            RectangleStatus{
                                id: agvLeft
                                width: 45;
                                font: 18;
                                Column {
                                    anchors.top:parent.top;
                                    anchors.topMargin: 2;
                                    anchors.left:parent.left;
                                    anchors.leftMargin: 12;
                                    spacing: 4
                                    Rectangle {
                                        id: toplift;
                                        width: 20;
                                        height: 4;
                                        color: "black"
                                        opacity: 0;
                                    }
                                    Rectangle {
                                        id: centerlift;
                                        width: 20;
                                        height: 4;
                                        color: "black"
                                        opacity: 0;
                                    }
                                    Rectangle {
                                        id: bottomlift;
                                        width: 20;
                                        height: 4;
                                        color: "black"
                                        opacity: 0;
                                    }
                                }
                            }
                        }
                        RectangleStatus{
                            id: agvVoltage
                            text: "0 v";
                            width:94;
                        }
                        RectangleStatus{
                            id: agvPrepos
                            text: "-1";
                            width: 94;
                        }

                        RectangleStatus{
                            id: agvNextpose;
                            text: "-1";
                            width: 94;
                        }
                        Row {
                            spacing: 4;
                            RectangleStatus{
                                id: oaview;
                                text: "OA"
                                width: 45;
                                font: 16;
                            }
                            RectangleStatus{
                                id: csview;
                                text: "CS";
                                width: 45;
                                font: 16;
                            }
                        }

                    }
                    Text {
                        id: agvInfo;
                        width: parent.width;
                        anchors.top: col1.bottom;
                        anchors.topMargin: 12;
                        text: "";
                        //font.family: "Helvetica"
                        font.pointSize: 14;
                        color: "blue";
                        focus: true;
                    }
                }
                GroupBox {
                    id: agvAlarm;
                    title: "agv alarm";
                    height: agvStatus.height;
                    width: root.width - agvConsole.width - agvStatus.width - 20
                    Column {
                        anchors.topMargin: 20
                        spacing: 4
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("电量报警: ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: elecNomal;
                                text: "√";
                                //color: "aquamarine";
                            }
                            RectangleStatus{
                                id: elecAlarm
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("丢磁报警: ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: dcNomal
                                text: "√";
                            }
                            RectangleStatus{
                                id: dcAlarm;
                                text: "⚠";
                                //color: "red"
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("旋转报警: ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: rotateNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: rotateAlarm;
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("平台报警: ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: liftNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: liftAlarm;
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("电机报警: ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: moterNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: moterAlarm;
                                text: "⚠";
                            }
                        }
                        Row {
                            Text {
                                y: 6;
                                text: qsTr("通信报警: ")
                                font.pointSize: 10
                            }
                            RectangleStatus{
                                id: chargeNomal;
                                text: "√";
                            }
                            RectangleStatus{
                                id: chargeAlarm;
                                text: "⚠";
                            }
                        }
                    }
                }
            }
        }
    }
}
