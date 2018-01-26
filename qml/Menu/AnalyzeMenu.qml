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
            globalConsoleInfo("#####RightControlPanel.qml收到Qt.Key_Left按键消息#####");
            idScopeView.focusPageOfrightControl=root;
            idScopeView.focus=true;
            event.accepted=true;
            break;
        case Qt.Key_PageUp://逆时针
            globalConsoleInfo("#####RightControlPanel.qml收到滚轮逆时针消息#####");
            idScopeView.focusPageOfrightControl=root;
            idScopeView.focus=true;
            event.accepted=true;
            break;
        case Qt.Key_Right:
            globalConsoleInfo("#####RightControlPanel.qml收到滚轮顺时针消息#####");
            root.focus=true;
            root.state="SHOW";
            event.accepted=true;
            break;
    case Qt.Key_PageDown://顺时针
        globalConsoleInfo("#####RightControlPanel.qml收到Qt.Key_Right按键消息#####");
        root.focus=true;
        root.state="SHOW";
        event.accepted=true;
        break;
        case Qt.Key_Enter://功能键 Key_Enter
            event.accepted=true;
            break;
        case Qt.Key_F1:
            globalConsoleInfo("-----------------------------");
            globalConsoleInfo("                 ");
            globalConsoleInfo(root+"!!!!!!收到F1!!!!!");
            Com.jumptoTargetPage(root,gatherMenu,"ClockSeting");
            globalConsoleInfo("----响应 时钟模式 完毕----");
            globalConsoleInfo("                 ");
            globalConsoleInfo("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F2:
            globalConsoleInfo("-----------------------------");
            globalConsoleInfo("                 ");
            globalConsoleInfo(root+"!!!!!!收到F2!!!!!");
            Com.jumptoTargetPage(root,gatherMenu,"TriggerMode");
            globalConsoleInfo("----响应 触发模式 完毕----");
            globalConsoleInfo("                 ");
            globalConsoleInfo("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F3:
            globalConsoleInfo("-----------------------------");
            globalConsoleInfo("                 ");
            globalConsoleInfo(root+"!!!!!!收到F3!!!!!");
            Com.jumptoTargetPage(root,gatherMenu,"GatherMode");
            globalConsoleInfo("----响应 采集模式 完毕----");
            globalConsoleInfo("                 ");
            globalConsoleInfo("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F4:
            globalConsoleInfo("-----------------------------");
            globalConsoleInfo("                 ");
            globalConsoleInfo(root+"!!!!!!收到F4!!!!!");

            ////////////////////////
            Com.clearTopPage(root);

            gatherMenu.focus=true;
            gatherMenu.state="SHOW";
            //////////////////////
            globalConsoleInfo("----响应 采集设置 完毕----");
            globalConsoleInfo("                 ");
            globalConsoleInfo("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F5:
            globalConsoleInfo("-----------------------------");
            globalConsoleInfo("                 ");
            globalConsoleInfo(root+"!!!!!!收到F5!!!!!");
            globalConsoleInfo("                 ");
            globalConsoleInfo("------------------ ----------- ");
            ////////////////////////
            Com.clearTopPage(root);
            analyzeMode.focus=true;
            analyzeMode.state="SHOW";
            //////////////////////
            globalConsoleInfo("----响应  分析模式  完毕----");
            event.accepted=true;
            break;
        case Qt.Key_F6:
            globalConsoleInfo("-----------------------------");
            globalConsoleInfo("                 ");
            globalConsoleInfo(root+"!!!!!!收到F6!!!!!");
            Com.jumptoTargetPage(root,saveCfgMenu,"NameMode");
            globalConsoleInfo("----响应  命名模式   完毕----");
            globalConsoleInfo("                 ");
            globalConsoleInfo("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F7:
            globalConsoleInfo("-----------------------------");
            globalConsoleInfo("                 ");
            globalConsoleInfo(root+"!!!!!!收到F7!!!!!");
            Com.jumptoTargetPage(root,saveCfgMenu,"SaveMode");
            globalConsoleInfo("----响应  保存模式  完毕----");
            globalConsoleInfo("                 ");
            globalConsoleInfo("------------------ ----------- ");
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

                globalConsoleInfo("☆☆☆☆AnalyzeMenu.qml获得焦点☆☆☆☆");
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


