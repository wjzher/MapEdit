import QtQuick 2.0
import QtQuick.Dialogs 1.2

Text {
    id: root;
    text: "File: ";
    signal fileOpen;
    signal fileSave;
    FileDialog {
        id: fileDialog;
        title: "Please choose a file";
        nameFilters: ["Image Files (*.map)"];
        onAccepted: {
            var file = new String(fileDialog.fileUrl);
            //remove file:///
            if (Qt.platform.os == "windows"){
                mapFilePath.text = file.slice(8);
            } else {
                mapFilePath.text = file.slice(7);
            }
            root.fileOpen();
        }
    }
    Rectangle {
        id: mapFileRect;
        anchors.fill: parent;
        anchors.margins: -2;
        border.width: 1;
        border.color: hovered ? "#c00000" : "black";
        color: "transparent";
        property bool hovered: false;
        MouseArea {
            id: maMapFile;
            anchors.fill: parent;
            hoverEnabled: true;
            onEntered: {
                mapFileRect.hovered = true;
            }
            onExited: {
                mapFileRect.hovered = false;
            }
            onClicked: {
                mapFileRect.hovered = false;
                fileDialog.open();
            }
        }
    }
}
