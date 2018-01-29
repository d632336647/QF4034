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
    anchors.topMargin: 4
    anchors.bottomMargin: 4
    objectName: "analyzeMenu"
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
            id: btn_exit;
            textLabel: "返回上级";
            icon:"\uf112"
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE";
                root.focus = false;
                idRightPannel.focus = true;
            }
        }
        CenterFreq {
            id: btn_centerfreq;
            width: parent.itemWidth
            parentPointer: root
        }
        ViewBandwidth {
            id: btn_bandwidth;
            width: parent.itemWidth
            parentPointer: root
        }
        FFTPoints{
            id: btn_fftpoints;
            width: parent.itemWidth
            parentPointer: root
        }
        ReferenceLevel {
            id: btn_reference;
            width: parent.itemWidth
            parentPointer: root
        }

        RightButton {
            id: empty1;
            textLabel: "通道切换";
            //icon:"\uf07c"
            onClick: {
                var ch = Settings.paramsSetCh();
                ch = ch?0:1;
                Settings.paramsSetCh(Com.OpSet, ch);
                btn_centerfreq.state = "toFront"
                btn_bandwidth.state  = "toFront"
                btn_fftpoints.state = "toFront"
                btn_reference.state  = "toFront"
                root.reloadParams();
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
            id: btn_menu;
            textLabel: "返回主菜单";
            icon: "\uf090";
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE";
                root.focus = false;
                idRightPannel.state="SHOW";
                idRightPannel.focus=true;
            }
        }
    }




    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{
        var therightnameEle;
        var theTaregetrightnameEle;
        globalConsoleInfo("#####AnalyzeMenu.qml收到按键消息#####"+event.key);
        switch(event.key)
        {
        case Qt.Key_Escape:
            globalConsoleInfo("#####AnalyzeMenu.qml收到Qt.Key_Escape按键消息#####");
            Com.clickchild(0,false);
            event.accepted=true;
            break;
        case Qt.Key_Exclam://功能键1
            globalConsoleInfo("#####AnalyzeMenu.qml收到功能键1按键消息#####");
            Com.clickchild(1,false);
            event.accepted=true;
            break;
        case Qt.Key_At://功能键2
            globalConsoleInfo("#####AnalyzeMenu.qml收到功能键2按键消息#####");
            Com.clickchild(2,false);
            event.accepted=true;
            break;
        case Qt.Key_NumberSign://功能键3
            globalConsoleInfo("#####AnalyzeMenu.qml收到功能键3按键消息#####");
            Com.clickchild(3,false);
            event.accepted=true;
            break;
        case Qt.Key_Dollar://功能键4
            globalConsoleInfo("#####AnalyzeMenu.qml收到功能键4按键消息#####");
            Com.clickchild(4,false);
            event.accepted=true;
            break;
        case Qt.Key_Percent://功能键5
            globalConsoleInfo("#####AnalyzeMenu.qml收到功能键5按键消息#####");
            Com.clickchild(5,false);
            event.accepted=true;
            break;
        case Qt.Key_AsciiCircum://功能键6
            globalConsoleInfo("#####AnalyzeMenu.qml收到功能键6按键消息#####");
            Com.clickchild(6,false);
            event.accepted=true;
            break;
        case Qt.Key_Space://功能键 return
            globalConsoleInfo("#####AnalyzeMenu.qml收到功能键 return按键消息#####");
            Com.clickchild(7,false);
            event.accepted=true;
            break;
        case Qt.Key_Left:
            console.info("#####AnalyzeMenu.qml收到Qt.Key_Left按键消息#####");
            idScopeView.focusPageOfrightControl=root;
            idScopeView.focus=true;
            event.accepted=true;
            break;

        case Qt.Key_Right:

            console.info("#####AnalyzeMenu.qml收到Qt.Key_Right按键消息#####");
            root.focus=true;
            root.state="SHOW";
            event.accepted=true;
            break;

        case Qt.Key_Enter://功能键 Key_Enter
            event.accepted=true;
            break;
        case Qt.Key_F1:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!AnalyzeMenu.qml收到C_FREQUENCY_CHANNEL信号!!!!!");

            Com.clearTopPage(root);
            analyzeMenu.focus=true;
            analyzeMenu.state="SHOW";

            console.info("----AnalyzeMenu.qml响应 ◇分析参数◇ 完毕----");
            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F5:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!AnalyzeMenu.qml收到C_SPAN_X_SCALE!!!!!");
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
                console.info("----AnalyzeMenu.qml响应 ◇C_SPAN_X_SCALE◇ 完毕----");
            }
            else
            {
                console.info("#####AnalyzeMenu.qml 图谱不存在！无法响应X轴缩放######");
                console.info(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0]);
            }

            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F9:
            console.info("-----------------------------");
            console.info("                 ");

            idScopeView.focusPageOfrightControl=root;
            //idScopeView.getPeakAndmarkEle();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;
                idScopeView.whichTypePageOfEle.zoomXY="y";
                console.info("----AnalyzeMenu.qml响应 ◇C_AMPLITUDE_Y_SCALE◇ 完毕----");
            }
            else
            {
                console.info("#####AnalyzeMenu.qml 图谱不存在！无法响应Y轴缩放######");
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
            console.info(root+"!!!!!!AnalyzeMenu.qml收到C_MARKER!!!!!");
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
            console.info("----AnalyzeMenu.qml响应  ◇C_MARKER◇  完毕----");
            event.accepted=true;
            break;
        //case Qt.Key_F3:
            case Qt.Key_F16:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!AnalyzeMenu.qml收到C_PEAK_SEARCH!!!!!");
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
            console.info("----AnalyzeMenu.qml响应  ◇C_PEAK_SEARCH◇   完毕----");
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
            console.info("●●●●●● AnalyzeMenu.qml 呼出菜单按钮触发●●●●●●idBottomPannel.menuBtn"+idBottomPannel.menuBtn);
            event.accepted=true;
            break;
        //case Qt.Key_Insert://模式切换
            case Qt.Key_F10:
            if(idBottomPannel.modeSwitch)
            {
                idBottomPannel.modeSwitch.clicked();
            }
            console.info("●●●●●● AnalyzeMenu.qml  模式切换按钮触发●●●●●●idBottomPannel.modeSwitch"+idBottomPannel.modeSwitch);
            event.accepted=true;
            break;
        //case Qt.Key_Delete://参数更新
            case Qt.Key_F19:
            if(idBottomPannel.paramsUpdate)
            {
                idBottomPannel.paramsUpdate.clicked();
            }
            console.info("●●●●●● AnalyzeMenu.qml  参数更新按钮触发●●●●●●Com.paramsUpdate"+idBottomPannel.paramsUpdate);
            console.info("----AnalyzeMenu.qml响应 ◇C_PRESET◇ 完毕----");
            event.accepted=true;
            break;

        default:
            globalConsoleInfo("#####AnalyzeMenu.qml收到未注册消息#####"+event.key);
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
            PropertyChanges { target: root; x: root.parent.width-200}
            onCompleted:{
                root.focus = true;
                globalConsoleInfo("                                    ");
                globalConsoleInfo("                                    ");

                console.info("☆☆☆☆AnalyzeMenu.qml获得焦点☆☆☆☆");
                globalConsoleInfo("                                    ");
                globalConsoleInfo("                                    ");
                //传递获得焦点的页面元素
                idScopeView.focusPageOfrightControl=root;
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
    Component.onCompleted: {
        setAnalyzeParam()
        idBottomPannel.updateParams()
    }
    function reloadParams()
    {
        btn_centerfreq.loadParam()
        btn_bandwidth.loadParam()
        btn_fftpoints.loadParam()
        btn_reference.loadParam()
    }
    function setAnalyzeParam()
    {
        var ch = Settings.paramsSetCh();
        var centerFreq =  Settings.centerFreq(Com.OpGet, 0, ch)
        var bandwidth  =  Settings.bandWidth(Com.OpGet, 0, ch)
        var fftpoints  =  Settings.fftPoints(Com.OpGet, 0, ch)
        console.log("---------------------------AnalyzeMenu updateParams-------------------------------")
        console.log("ch:",ch,"centerFreq:"+centerFreq+" bandwidth:"+bandwidth+" fftpoints:"+fftpoints)
        console.log(" ")
        dataSource.setFFTParam(ch, centerFreq, bandwidth, fftpoints)       
    }
    function updateParams()
    {
        setAnalyzeParam();
        idBottomPannel.updateParams()
        idScopeView.changeAnalyzeMode()
        dataSource.forceUpdateAllSeries()
    }
}


