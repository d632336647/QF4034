import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../Inc.js" as Com
import "../UI"

Rectangle{
    id:root

    state: "HIDE"
    width: 200
    //anchors.topMargin: 4
    //anchors.bottomMargin: 4

    //border.color: Com.BottomBorderColor
    //border.width: 1
    color: Com.BGColor_main

    ColumnLayout {
        id:content
        spacing: 4;
        anchors.top: parent.top;
        anchors.left: parent.left
        anchors.leftMargin: 4;
        property int itemWidth: root.width - 8
        RightButton {
            id: btn_return;
            textLabel: "返回上级";
            icon:"\uf112"
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE"
            }
        }
        RightButton {
            id: btn_external;
            textLabel: "外部触发";
            width: parent.itemWidth
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(0)
            }
        }
        RightButton {
            id: btn_internal;
            textLabel: "内部触发";
            width: parent.itemWidth
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(1)
            }
        }

        RightButton {
            id: empty1;
            textLabel: "";
            //icon:"\uf07c"
            onClick: {
            }
        }
        RightButton {
            id: empty2;
            textLabel: "";
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
                root.state = "HIDE"
                root.parent.state = "HIDE"
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
    //！--过渡动画结束

    function clearSelectBorder()
    {
        var list = content.children

        for(var i in list)
        {
            list[i].selected(false);
        }
    }
    function loadParam()
    {
        if(Settings.triggerMode() === 0)
            btn_external.selected(true);
        else
            btn_internal.selected(true);

    }
    function setParam(val)
    {
        Settings.triggerMode(Com.OpSet, val)
        gatherMenu.updateParams()
    }
}

