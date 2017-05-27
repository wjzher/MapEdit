import QtQuick 2.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

Window {
    id: root;
    width: 300;
    height: 200;
    title: "Update Map Card ID";
    color: "#EEEEEE";
    modality: Qt.WindowNoState;
    property bool run: false;
    property int currentIndex: 0;
    property int direction: 0;  // 0->up; 1->down; 2->left; 3->right
    property alias agvModel: agvModel;
    property var currentItem: null;
    AgvModel {
        id: agvModel;
        visible: false;
    }
    MessageDialog {
          id: messageDialog
          title: "warning!"
          text: "current item no cardId."
      }
    Row {
        x: 10;
        y: 10
        spacing: 10;
        Column {
            spacing: 4;
            ComboBox {
                id: agvDirectionCombo;
                width: 80;
                model: [
                    "Up",
                    "Down",
                    "Left",
                    "Right"
                ];
            }
            TextField {
                id: startItem;
                width: 80;
                height: 25;
                placeholderText: qsTr("起始Item");
            }
        }
        Column {
            spacing: 4;
            Button {
                id: updateBtn;
                text: "Update";
                onClicked: {
                    currentIndex = parseInt(startItem.text);
                    direction = agvDirectionCombo.currentIndex;
                    currentItem = mapGrid.itemAt(currentIndex);
                    if (currentItem.isCard) {
                        run = true;
                        if (cardCheck.checked) {
                            mapGrid.setItemCardID2(currentIndex, agvDialog.getCurrentCardId());
                            mapGrid.updateMapItemMoveToNext(currentIndex);
                        } else {
                        }
                    } else {
                        messageDialog.open();
                    }
                }
            }
            Button {
                id: stopBtn;
                text: "stop";
                onClicked: {
                    run = false;

                }
            }
        }
        CheckBox {
            id: cardCheck;
            text: "Is ";
            onClicked: {

            }
        }
    }

}
