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
    //anchors.topMargin: 4
    //anchors.bottomMargin: 4

    //border.color: Com.BottomBorderColor
    //border.width: 1
    color: Com.BGColor_main
    objectName: "clockSetting"
    ColumnLayout {
        id:content
        spacing: 4;
        anchors.top: parent.top;
        anchors.left: parent.left
        anchors.leftMargin: 4;
        property int itemWidth: root.width - 8
        RightButton {
            id: btn_return;
            textLabel: "返回";
            icon:"\uf112"
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE"
                root.focus = false;
                gatherMenu.focus = true;
            }
        }
        RightButton {
            id: btn_externallock;
            textLabel: "外时钟";
            width: parent.itemWidth
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(0)

            }
        }
        RightButton {
            id: btn_externalrefer;
            textLabel: "内时钟";
            width: parent.itemWidth
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(1)

            }
        }
        RightButton {
            id: btn_boardcrystal;
            textLabel: "外参考";
            width: parent.itemWidth
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(2)
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
            id: btn_exit;
            textLabel: "返回主菜单";
            icon: "\uf090";
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE";
                root.parent.state="HIDE";//非直接菜单必须加这句
                idRightPannel.state="SHOW";
                idRightPannel.focus=true;
            }
        }
    }

    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{
        if(Lib.operateSpecView(event.key))
        {
            root.state = "HIDE"
            root.parent.state = "HIDE"
            event.accepted = true;
            return
        }
        var key = [Qt.Key_F1,  Qt.Key_F2,        Qt.Key_F3,         Qt.Key_F4,        Qt.Key_F8]
        var fid = [btn_return, btn_externallock, btn_externalrefer, btn_boardcrystal, btn_exit ]
        Lib.clickFunctionKey(event.key, key, fid);
        event.accepted = true;
    }

    //过渡动画
    states: [
        State {
            name: "SHOW"
            PropertyChanges { target: root; x: root.parent.width-root.width}
            onCompleted:{
                root.focus = true;
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
        if(Settings.clkMode() === 0)
            btn_externallock.selected(true);
        else if(Settings.clkMode() === 1)
            btn_externalrefer.selected(true);
        else
            btn_boardcrystal.selected(true);
    }
    function setParam(val)
    {
        Settings.clkMode(Com.OpSet, val)
        gatherMenu.updateParams()
    }
}

