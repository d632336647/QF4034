import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import "Inc.js" as Com
import "Lib.js" as Lib
import "UI"

Rectangle{
    id:root

    width: 200

    anchors.topMargin: 4
    anchors.bottomMargin: 4

    //border.color: Com.BottomBorderColor
    //border.width: 1
    color: Com.BGColor_main
    focus: true

    state: "SHOW"

    ColumnLayout {
        spacing: 4;
        anchors.top: parent.top;
        anchors.horizontalCenter: parent.horizontalCenter;
        objectName: "rightControlColumnLayout";
        RightButton {
            id: empty1;
            textLabel: "退出程序";
            icon:"\uf090"
            onClick: {
                Settings.save()
                captureThread.exit()
                dataSource.clearPCIE()
                Qt.quit()
            }
        }
        RightButton {
            id: btn_ddcmenu;
            textLabel: "预处理设置";
            //icon:"\uf07c"
            onClick: {
                preconditionMenu.state = "SHOW"
                preconditionMenu.focus = true;
                root.focus = false;

            }
        }
        RightButton {
            id: btn_capture_config;
            textLabel: "采集设置";
            onClick: {
                gatherMenu.state = "SHOW"
                gatherMenu.focus = true;
                root.focus = false;
            }
        }
        RightButton {
            id: btn_analyzemode;
            textLabel: "分析模式";
            onClick: {
                analyzeMode.loadParam()
                analyzeMode.state = "SHOW"
                root.focus = false;
            }
        }
        RightButton {
            id: btn_analyze_config;
            textLabel: "分析参数";
            onClick: {
                //showPopup(idPopAnalyzeCfg, textLabel);
                analyzeMenu.state = "SHOW"
                analyzeMenu.focus = true;
                analyzeMenu.reloadParams()
                root.focus = false;
            }
        }
        RightButton {
            id: btn_save_config;
            textLabel: "存储设置";
            onClick: {
                saveCfgMenu.state = "SHOW"
                saveCfgMenu.focus = true;
                root.focus = false;
            }
        }
        RightButton {
            property bool isStoring: false
            id: btn_start_store
            textLabel: "启动存储";
            onClick: {
                //contentBox.visible = true
                isStoring = !isStoring;
                if(!dataSource.startStopStore(isStoring))
                {
                    isStoring = false;
                    messageBox.title = "错误"
                    messageBox.note  = "未检测到PCIE驱动!"
                    messageBox.isWarning = true
                    messageBox.visible = true
                }
                textLabel = isStoring ? "停止存储" : "启动存储";
            }
        }



        RightButton {
            id: empty4;
            textLabel: "关闭菜单";
            onClick: {
                    //messageBox.title = "错误"
                    //messageBox.note  = "暂时不支持关闭菜单功能!"
                    //messageBox.isWarning = true
                    //messageBox.visible = true
                root.state = "HIDE"
                root.focus = true;
            }
        }

    }

    //过渡动画
    states: [
        State {
            name: "SHOW"
            PropertyChanges { target: root; x: root.parent.width-200}
            onCompleted:{
                root.focus=true;
                //                 Com.childArray=Com.resetAndgetItemOfControlPannel(root);
                //                 Com.GlobalTotalchildArray=Com.resetGlobalItemOfElement(root);
                idScopeView.focusPageOfrightControl=root;
            }
        },
        State {
            name: "HIDE"
            PropertyChanges { target: root; x: root.parent.width}
            onCompleted: {

                idScopeView.focusPageOfrightControl=root;
                idScopeView.judgeVisiblePage();
                if(idScopeView.whichTypePageOfEle)
                {
                    idScopeView.whichTypePageOfEle.focus=true;
                }
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

    onXChanged: {
        //console.log("x:", root.x)
    }


    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{
        var curFocusindex=0;//当前获得焦点的子元素索引

        globalConsoleInfo("#####RightControlPanel.qml收到按键消息#####"+event.key);

        
        switch(event.key)
        {
        case Qt.Key_Escape:
            //btn_exit.click()
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
            Com.setPrevFocus(Com.childArray,curFocusindex);
            event.accepted=true;
            break;

        case Qt.Key_Down:
            curFocusindex=Com.getFocusIndex(Com.childArray);
            Com.setNextFocus(Com.childArray,curFocusindex);
            event.accepted=true;
            break;

        case Qt.Key_Left:
            globalConsoleInfo("#####RightControlPanel.qml收到Qt.Key_Left按键消息#####");
            idScopeView.focusPageOfrightControl=root;
            idScopeView.focus=true;
            event.accepted=true;
            break;
        case Qt.Key_Right:
            globalConsoleInfo("#####RightControlPanel.qml收到Qt.Key_Right按键消息#####");
            idRightPannel.focus=true;
            idRightPannel.state="SHOW";
            event.accepted=true;
            break;

        case Qt.Key_F1:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!RightControlPanel.qml收到C_FREQUENCY_CHANNEL信号!!!!!");

            Com.clearTopPage(root);
            analyzeMenu.focus=true;
            analyzeMenu.state="SHOW";

            console.info("----RightControlPanel.qml响应 ◇分析参数◇ 完毕----");
            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F5:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!RightControlPanel.qml收到C_SPAN_X_SCALE!!!!!");
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
                console.info("----RightControlPanel.qml响应 ◇C_SPAN_X_SCALE◇ 完毕----");
            }
            else
            {
                console.info("#####RightControlPanel.qml 图谱不存在！无法响应X轴缩放######");
                console.info(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0]);
            }

            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F9:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!RightControlPanel.qml收到C_AMPLITUDE_Y_SCALE!!!!!");
            idScopeView.focusPageOfrightControl=root;
            //idScopeView.getPeakAndmarkEle();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;
                idScopeView.whichTypePageOfEle.zoomXY="y";
                console.info("----RightControlPanel.qml响应 ◇C_AMPLITUDE_Y_SCALE◇ 完毕----");
            }
            else
            {
                console.info("#####RightControlPanel.qml 图谱不存在！无法响应Y轴缩放######");
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
            console.info(root+"!!!!!!RightControlPanel.qml收到C_MARKER!!!!!");
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
            console.info("----RightControlPanel.qml响应  ◇C_MARKER◇  完毕----");
            event.accepted=true;
            break;
            //case Qt.Key_F3:
        case Qt.Key_F16:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!RightControlPanel.qml收到C_PEAK_SEARCH!!!!!");
            idScopeView.focusPageOfrightControl=root;
            console.info("---idScopeView.peakPointBtn.visible---"+idScopeView.peakPointBtn.visible);
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
            globalConsoleInfo("----响应  ◇C_PEAK_SEARCH◇   完毕----");
            globalConsoleInfo("                 ");
            globalConsoleInfo("------------------ ----------- ");
            event.accepted=true;
            break;

            //case Qt.Key_End://呼出菜单
        case Qt.Key_F13:
            if(idBottomPannel.menuBtn)
            {
                idBottomPannel.menuBtn.clicked();
            }
            globalConsoleInfo("●●●●●●呼出菜单按钮触发●●●●●●idBottomPannel.menuBtn"+idBottomPannel.menuBtn);
            event.accepted=true;
            break;
            //case Qt.Key_Insert://模式切换
        case Qt.Key_F10:
            if(idBottomPannel.modeSwitch)
            {
                idBottomPannel.modeSwitch.clicked();
            }
            globalConsoleInfo("●●●●●●模式切换按钮触发●●●●●●idBottomPannel.modeSwitch"+idBottomPannel.modeSwitch);
            event.accepted=true;
            break;
            //case Qt.Key_Delete://参数更新
        case Qt.Key_F19:
            if(idBottomPannel.paramsUpdate)
            {
                idBottomPannel.paramsUpdate.clicked();
            }
            console.info("●●●●●●RightControlPanel.qml  参数更新按钮触发●●●●●●Com.paramsUpdate"+idBottomPannel.paramsUpdate);
            console.info("----RightControlPanel.qml响应 ◇C_PRESET◇ 完毕----");
            event.accepted=true;
            break;


        default://对于鼠标滚轮，交给图谱
            root.state="HIDE";
            if(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;
                console.info("========rightControlPannel传递焦点给图谱======="+idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0]);
            }
            else if(idScopeView.whichTypePageOfEle)
            {
                idScopeView.whichTypePageOfEle.focus=true;
                console.info("========rightControlPannel传递焦点给元素======="+idScopeView.whichTypePageOfEle);
            }
            else
            {
                idScopeView.focus=true;
                console.info("========rightControlPannel传递焦点给视图======="+idScopeView);
            }
            break;
        }
        event.accepted=true;
    }

    Connections {
        target: dataSource;
        onStoreEnd:{
//          console.log(writedLen);
            btn_start_store.isStoring = false;
            btn_start_store.textLabel = "启动存储"
        }
    }

    Component.onCompleted:
    {
        globalConsoleInfo("☆☆☆☆RightControlPanel.qml加载完毕☆☆☆☆");
        Com.childArray=Com.resetAndgetItemOfControlPannel(root);
        Com.GlobalTotalchildArray=Com.resetGlobalItemOfElement(root);
        idScopeView.focusPageOfrightControl=root;

    }


}
