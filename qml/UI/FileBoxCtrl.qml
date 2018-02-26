import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../Inc.js" as Com
import "../Lib.js" as Lib
import "../UI"

Rectangle{
    id:root

    state: "HIDE"
    width: 200
    anchors.topMargin: 4
    //anchors.bottomMargin: 4

    //border.color: Com.BottomBorderColor
    //border.width: 1
    color: Com.BGColor_main
    signal hideCompleted
    ColumnLayout {
        id:content
        spacing: 4;
        anchors.top: parent.top;
        anchors.left: parent.left
        anchors.leftMargin: 4;
        property int itemWidth: root.width - 8
        RightButton {
            id: btn_return;
            textLabel: "返回菜单";
            icon:"\uf112"
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE";
            }
        }
        RightButton {
            id: btn_select1;
            textLabel: "文件1";
            width: parent.itemWidth
            onClick: {
            }
        }
        RightButton {
            id: btn_select2;
            textLabel: "文件2";
            width: parent.itemWidth
            onClick: {
            }
        }
        RightButton {
            id: btn_select3;
            textLabel: "文件3";
            width: parent.itemWidth
            //icon:"\uf07c"
            onClick: {
            }
        }
        RightButton {
            id: btn_delete;
            textLabel: "关闭文件";
            width: parent.itemWidth
            //icon:"\uf07c"
            onClick: {
            }
        }
        RightButton {
            id: empty3;
            textLabel: "";
            //icon:"\uf07c"
            onClick: {
            }
        }
        RightButton {
            id: empty4;
            textLabel: "";
            //icon:"\uf07c"
            onClick: {
            }
        }
        RightButton {
            id: btn_exit;
            textLabel: "返回主菜单";
            icon: "\uf090";
            width: parent.itemWidth
            onClick: {

            }
        }

    }
    //过渡动画
    states: [
        State {
            name: "SHOW"
            PropertyChanges { target: root; x: root.parent.width-root.width}
            onCompleted:{
            }
        },
        State {
            name: "HIDE"
            PropertyChanges { target: root; x: root.parent.width}
            onCompleted: {
                root.hideCompleted()
            }
         }
    ]

    transitions: [
         Transition {
             from: "SHOW"
             to: "HIDE"
             PropertyAnimation { properties: "x"; easing.type: Easing.OutCubic }
         },
         Transition {
             from: "HIDE"
             to: "SHOW"
             PropertyAnimation { properties: "x"; easing.type: Easing.OutCubic }
         }
    ]
    function btnReturnClick()
    {
        btn_return.keyPressed()
    }
    function btnSelect1Click()
    {
        btn_select1.keyPressed()
    }
    function btnSelect2Click()
    {
        btn_select2.keyPressed()
    }
    function btnSelect3Click()
    {
        btn_select3.keyPressed()
    }
    function btnDeleteClick()
    {
        btn_delete.keyPressed()
    }
    function btnExitClick()
    {
        btn_exit.keyPressed()
    }
}

