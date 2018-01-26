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

    //border.color: Com.BottomBorderColor
    //border.width: 1
    color: Com.BGColor_main
    property int currentBorderSel : 0  //当前焦点元素
    property var  analyzeChildren : Com.childArray  //子控件
    objectName: "preConditionMenu"
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
                root.state = "HIDE"
                root.focus = false;
                idRightPannel.focus = true;

            }
        }
        RightButton {
            id: btn_outmode;
            textLabel: "输出模式";
            width: parent.itemWidth
            readOnly: true
            onClick: {

            }
        }
        RightButton {
            id: btn_channelenable;
            textLabel: "通道使能";
            readOnly: true
            width: parent.itemWidth
            onClick: {


            }
        }
        RightButton {
            id: btn_extractfactor;
            textLabel: "抽取因子";
            width: parent.itemWidth
            onClick: {
                extractFactor.loadParam()
                extractFactor.state = "SHOW"
            }
        }

        RightButton{
            id: btn_fsbcoef;
            textLabel: "Fs/B系数";
            width: parent.itemWidth
            onClick: {
                fsbCoef.loadParam()
                fsbCoef.state = "SHOW"
            }
        }
        DDCFreq{
            id: btn_ddcfreq;
            width: parent.itemWidth
            parentPointer: root
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
                root.state = "HIDE"
                root.focus = false;
                idRightPannel.state="SHOW";
                idRightPannel.focus=true;
            }
        }

    }

    //ClockSeting{
    //    id:clockSeting
    //    anchors.top: parent.top
    //    anchors.bottom: parent.bottom
    //}

    ExtractFactor{
        id: extractFactor;
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
    FsbCoef{
        id: fsbCoef;
        anchors.top: parent.top
        anchors.bottom: parent.bottom
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
                globalConsoleInfo("☆☆☆☆AnalyzeMode.qml获得焦点☆☆☆☆");
                globalConsoleInfo("                                    ");
                globalConsoleInfo("                                    ");
                Com.childArray=Com.resetAndgetItemOfControlPannel(root);

                analyzeChildren=Com.childArray;
                //传递获得焦点的页面元素
                idScopeView.focusPageOfrightControl=root;
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
    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{

        var curFocusindex=0;//当前获得焦点的子元素索引
        globalConsoleInfo("#####PreconditionMenu.qml收到按键消息#####"+event.key);
        switch(event.key)
        {
        case Qt.Key_Escape:
            //btn_exit.click()
            Com.clickchild(0,false);
            break;
        case Qt.Key_Exclam://功能键1
            Com.clickchild(1,false);
            break;
        case Qt.Key_At://功能键2
            Com.clickchild(2,false);
            break;
        case Qt.Key_NumberSign://功能键3
            Com.clickchild(3,false);
            break;
        case Qt.Key_Dollar://功能键4
            Com.clickchild(4,false);
            break;
        case Qt.Key_Percent://功能键5
            Com.clickchild(5,false);
            break;
        case Qt.Key_AsciiCircum://功能键6
            Com.clickchild(6,false);
            break;
        case Qt.Key_Space://功能键 return
            Com.clickchild(7,false);
            break;

        case Qt.Key_Up:
            curFocusindex=Com.getFocusIndex(Com.childArray);
            var whichPrevOject=Com.setPrevFocus(Com.childArray,curFocusindex);
            whichPrevOject.getxxFocus();
            break;
        case Qt.Key_Down:
            curFocusindex=Com.getFocusIndex(Com.childArray);
            var whichNextOject=Com.setNextFocus(Com.childArray,curFocusindex);
            whichNextOject.getxxFocus();
            break;
        case Qt.Key_Left:
            globalConsoleInfo("#####PreconditionMenu.qml收到Qt.Key_Left按键消息#####");
            idScopeView.focusPageOfrightControl=root;
            idScopeView.focus=true;
            event.accepted=true;
            break;
        case Qt.Key_PageUp://逆时针
            globalConsoleInfo("#####PreconditionMenu.qml收到Qt.Key_Left按键消息#####");
            idScopeView.focusPageOfrightControl=root;
            idScopeView.focus=true;
            event.accepted=true;
            break;
        case Qt.Key_Right:
            globalConsoleInfo("#####PreconditionMenu.qml收到Qt.Key_Right按键消息#####");
            root.focus=true;
            root.state="SHOW";
            event.accepted=true;
            break;
        case Qt.Key_PageDown://顺时针
            globalConsoleInfo("#####PreconditionMenu.qml收到Qt.Key_Right按键消息#####");
            root.focus=true;
            root.state="SHOW";
            event.accepted=true;
            break;
        case Qt.Key_Enter:
            //            curFocusindex=Com.getFocusIndex(Com.childArray);
            //            Com.clickchild(curFocusindex,true);
            //            //event.accepted=true;//阻止事件继续传递
            //            globalConsoleInfo("确认按钮触发★→");
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
            break;
        }
        event.accepted=true;//阻止事件继续传递
    }

    Component.onCompleted: {

    }

    function updateParams()
    {
        var outmode = 0;
        var chCount = 2;
        var ddcfreq = Settings.ddcFreq();//MHz
        var extractfactor = Settings.extractFactor();
        var fsbcoef  = Settings.fsbCoef();//1.25B
        console.log("---------------------------PreCondition updateParams------------------------------")
        console.log("outmode:"+outmode+" chCount:"+chCount+" ddcfreq:"+ddcfreq+" extractfactor:"+extractfactor+" fsbcoef:"+fsbcoef)
        console.log(" ")
        var rtn = dataSource.setPreConditionParam(outmode, chCount, ddcfreq, extractfactor, fsbcoef);
        if(rtn)
        {
            idScopeView.changeAnalyzeMode()
            dataSource.forceUpdateAllSeries()
        }
    }

}


