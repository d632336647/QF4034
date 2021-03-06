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
    width: Com.RightMenuWidth
    //anchors.topMargin: 4
    //anchors.bottomMargin: 4

    //border.color: Com.bottomBorderColor
    //border.width: 1
    color: Com.bgColorMain

    ColumnLayout {
        id:content
        spacing: 4;
        anchors.top: parent.top;
        anchors.left: parent.left
        anchors.leftMargin: 4;
        property int itemWidth: root.width - 8
        RightButton {
            id: btn_menu;
            textLabel: "返回主菜单";
            icon: "\uf090";
            width: parent.itemWidth
            onClick: {
                turnToMainMenu()
            }
        }
        RightButton {
            id: btn_realmode;
            textLabel: "即采即停";
            width: parent.itemWidth
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(0)
                updateGatherMark()
            }
        }
        RightButton {
            id: btn_timemode;
            textLabel: "时长采集";
            width: parent.itemWidth
            readOnly:true
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(1)
                updateGatherMark()
            }
        }
        RightButton {
            id: btn_filemode;
            textLabel: "大小采集";
            readOnly:true
            width: parent.itemWidth
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(2)
                updateGatherMark()
            }
        }
        RightButton {
            id: btn_cutmode;
            textLabel: "分段采集";
            readOnly:true
            width: parent.itemWidth
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(3)
                updateGatherMark()
            }
        }
        GatherTime {
            id:btn_gatherTime
            width: parent.itemWidth
        }
        RightButton {
            id: empty1;
            textLabel: "";
            //icon:"\uf07c"
            onClick: {
            }
        }
        RightButton {
            id: btn_return;
            textLabel: "返回上级";
            icon:"\uf112"
            width: parent.itemWidth
            onClick: {
                turnToParentMenu()
            }
        }

    }


    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{
        if(Lib.operateSpecView(event.key))
        {
            hideMenu()
            event.accepted = true;
            return
        }
        var key = [Qt.Key_F1,  Qt.Key_F8]
        var fid = [btn_menu, btn_return ]
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
    function hideMenu()
    {
        root.state = "HIDE"
        root.parent.state = "HIDE"
    }
    function turnToMainMenu()
    {
        hideMenu()
        idRightPannel.state="SHOW";
        idRightPannel.focus=true;
    }
    function turnToParentMenu()
    {
        root.state = "HIDE";
        gatherMenu.focus = true;
    }
    function clearSelectBorder()
    {
        var list = content.children
        for(var i in list)
        {
            if(list[i].textLabel !== undefined)
                list[i].selected(false);
        }
    }
    function loadParam()
    {
        if(Settings.captureMode() === 0)
            btn_realmode.selected(true);
        else if(Settings.captureMode() === 1)
            btn_timemode.selected(true);
        else if(Settings.captureMode() === 2)
            btn_filemode.selected(true);
        else
            btn_cutmode.selected(true);

        updateGatherMark()
    }
    function setParam(val)
    {
       Settings.captureMode(Com.OpSet, val)
       gatherMenu.updateParams()
    }

    //关联处理
    function updateGatherMark()
    {
        switch(Settings.captureMode())
        {
        case 0:
            btn_gatherTime.readOnly = true
            break;
        case 1:
        case 3:
            btn_gatherTime.readOnly = false
            btn_gatherTime.unit = "Sec"
            btn_gatherTime.text = "采集时间"
            break;
        case 2:
            btn_gatherTime.readOnly = false
            btn_gatherTime.unit = "MB"
            btn_gatherTime.text = "采集大小"
            break;
        default:
            break;
        }
    }
}

