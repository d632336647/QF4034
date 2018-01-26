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
                root.state = "HIDE";
                gatherMenu.focus = true;
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
            id: btn_exit;
            textLabel: "返回主菜单";
            icon: "\uf090";
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE"
                root.parent.state = "HIDE"
                root.focus = false;
                root.parent.state="HIDE";//非直接菜单必须加这句
                idRightPannel.state="SHOW";
                idRightPannel.focus=true;
            }
        }
    }


    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{
        var curFocusindex=0;//当前获得焦点的子元素索引

        globalConsoleInfo("#####GatherMode.qml收到按键消息#####"+event.key);
        switch(event.key)
        {
        case Qt.Key_Escape:

            Com.clickchild(0,false);
            event.accepted=true;
            break;
        case Qt.Key_Exclam://功能键1
            Com.clickchild(1,false);
            event.accepted=true;
            break;
        case Qt.Key_At://功能键2
            Com.clickchild(2,false);
            event.accepted=true;
            break;
        case Qt.Key_NumberSign://功能键3
            Com.clickchild(3,false);
            event.accepted=true;
            break;
        case Qt.Key_Dollar://功能键4
            Com.clickchild(4,false);
            event.accepted=true;
            break;
        case Qt.Key_Percent://功能键5
            Com.clickchild(5,false);
            event.accepted=true;
            break;
        case Qt.Key_AsciiCircum://功能键6
            Com.clickchild(6,false);
            event.accepted=true;
            break;
        case Qt.Key_Space://功能键 return
            Com.clickchild(7,false);
            event.accepted=true;
            break;

        case Qt.Key_Up:
            curFocusindex=Com.getFocusIndex(Com.childArray);
            var whichPrevOject=Com.setPrevFocus(Com.childArray,curFocusindex);
            whichPrevOject.getxxFocus();
            event.accepted=true;
            break;

        case Qt.Key_Down:
            curFocusindex=Com.getFocusIndex(Com.childArray);
            var whichNextOject=Com.setNextFocus(Com.childArray,curFocusindex);
            whichNextOject.getxxFocus();
            event.accepted=true;
            break;
        case Qt.Key_Left:
            globalConsoleInfo("#####GatherMode.qml收到Qt.Key_Left按键消息#####");
            idScopeView.focusPageOfrightControl=root;
            idScopeView.focus=true;
            event.accepted=true;
            break;
        case Qt.Key_Right:
            globalConsoleInfo("#####GatherMode.qml收到Qt.Key_Right按键消息#####");
            root.focus=true;
            root.state="SHOW";
            event.accepted=true;
            break;

        case Qt.Key_F1:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!GatherMode.qml收到C_FREQUENCY_CHANNEL信号!!!!!");

            Com.clearTopPage(root);
            analyzeMenu.focus=true;
            analyzeMenu.state="SHOW";

            console.info("----GatherMode.qml响应 ◇分析参数◇ 完毕----");
            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F5:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!GatherMode.qml收到C_SPAN_X_SCALE!!!!!");
            //记录上一个焦点转移的页面
            idScopeView.focusPageOfrightControl=root;
            //idScopeView.getPeakAndmarkEle();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                //更新slider和checkButton
                idScopeView.whichTypePageOfEle.getAllsliders();
                idScopeView.whichTypePageOfEle.getAllcheckButtons();
                idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;
                idScopeView.whichTypePageOfEle.zoomXY="x";
                console.info("----GatherMode.qml响应 ◇C_SPAN_X_SCALE◇ 完毕----");
            }
            else
            {
                console.info("#####GatherMode.qml 图谱不存在！无法响应X轴缩放######");
                console.info(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0]);
            }

            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F9:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!GatherMode.qml收到C_AMPLITUDE_Y_SCALE!!!!!");
            idScopeView.focusPageOfrightControl=root;
            //idScopeView.getPeakAndmarkEle();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;
                idScopeView.whichTypePageOfEle.zoomXY="y";
                console.info("----GatherMode.qml响应 ◇C_AMPLITUDE_Y_SCALE◇ 完毕----");
            }
            else
            {
                console.info("#####GatherMode.qml 图谱不存在！无法响应Y轴缩放######");
                console.info(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0]);
            }
            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;

        case Qt.Key_F15:
            //case Qt.Key_F2:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!GatherMode.qml收到C_MARKER!!!!!");
            console.info("                 ");
            console.info("------------------ ----------- ");
            ////////////////////////
            idScopeView.focusPageOfrightControl=root;
            //idScopeView.judgeVisiblePage();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.peakPointBtn)
            {
                idScopeView.peakPointBtn.checkboxClick();
                idScopeView.whichTypePageOfEle.getAllsliders();
            }
            //////////////////////
            console.info("----GatherMode.qml响应  ◇C_MARKER◇  完毕----");
            event.accepted=true;
            break;
            //case Qt.Key_F3:
        case Qt.Key_F16:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!GatherMode.qml收到C_PEAK_SEARCH!!!!!");
            idScopeView.focusPageOfrightControl=root;

            if((idScopeView.peakPointBtn)&&(!idScopeView.peakPointBtn.checked))
            {
                idScopeView.peakPointBtn.checkboxClick();
                idScopeView.whichTypePageOfEle.getAllsliders();
            }

            if(idScopeView.markBtn)
            {

                idScopeView.markBtn.checkboxClick();
                //焦点给第一个三角滑块
                idScopeView.whichTypePageOfEle.getAllsliders();//必须重新激活三角滑块
                if((idScopeView.whichTypePageOfEle.uiSliderIndex>=0)&&(idScopeView.whichTypePageOfEle.uiSliderIndex<idScopeView.whichTypePageOfEle.noCheckbuttonEleArray.length)&&idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[idScopeView.whichTypePageOfEle.uiSliderIndex].visible)
                {
                    idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[idScopeView.whichTypePageOfEle.uiSliderIndex].focus=true;
                }
            }
            console.info("----GatherMode.qml响应  ◇C_PEAK_SEARCH◇   完毕----");
            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;

            //case Qt.Key_End://呼出菜单
        case Qt.Key_F13:
            if(idBottomPannel.menuBtn)
            {
                idBottomPannel.menuBtn.clicked();
            }
            console.info("●●●●●●GatherMode.qml  呼出菜单按钮触发●●●●●●idBottomPannel.menuBtn"+idBottomPannel.menuBtn);
            event.accepted=true;
            break;
            //case Qt.Key_Insert://模式切换
        case Qt.Key_F10:
            if(idBottomPannel.modeSwitch)
            {
                idBottomPannel.modeSwitch.clicked();
            }
            console.info("●●●●●●GatherMode.qml  模式切换按钮触发●●●●●●idBottomPannel.modeSwitch"+idBottomPannel.modeSwitch);
            event.accepted=true;
            break;
            //case Qt.Key_Delete://参数更新
        case Qt.Key_F19:
            if(idBottomPannel.paramsUpdate)
            {
                idBottomPannel.paramsUpdate.clicked();
            }
            console.info("●●●●●●GatherMode.qml   参数更新按钮触发●●●●●●Com.paramsUpdate"+idBottomPannel.paramsUpdate);
            console.info("----GatherMode.qml响应 ◇C_PRESET◇ 完毕----");
            event.accepted=true;
            break;

        default:
            break;
        }

    }
    function keyup()
    {
        globalConsoleInfo("key up")
    }
    function keydowm()
    {
        globalConsoleInfo("key down")
    }
    function keyenter()
    {
        globalConsoleInfo("key enter")
    }


    //过渡动画
    states: [
        State {
            name: "SHOW"
            PropertyChanges { target: root; x: root.parent.width-root.width}
            onCompleted:{
                root.focus = true;
                globalConsoleInfo("                                    ");
                globalConsoleInfo("                                    ");
                globalConsoleInfo("☆☆☆☆GatherMode.qml获得焦点☆☆☆☆");
                globalConsoleInfo("                                    ");
                globalConsoleInfo("                                    ");
                //传递获得焦点的页面元素
                idScopeView.focusPageOfrightControl=root;
                globalConsoleInfo("☆☆☆☆idScopeView.focusPageOfrightControl☆☆☆☆"+idScopeView.focusPageOfrightControl);
                Com.childArray=Com.resetAndgetItemOfControlPannel(root);
                Com.GlobalTotalchildArray=Com.resetGlobalItemOfElement(root);
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

