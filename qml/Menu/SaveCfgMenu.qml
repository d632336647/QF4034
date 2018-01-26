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
                root.focus = false
                idRightPannel.focus = true
            }
        }
        RightButton {
            id: btn_savemode;
            textLabel: "存储模式";
            width: parent.itemWidth
            onClick: {
                saveMode.loadParam()
                saveMode.state = "SHOW"
            }
        }
        RightButton {
            id: btn_namemode;
            textLabel: "命名模式";
            width: parent.itemWidth
            onClick: {
                nameMode.loadParam()
                nameMode.state = "SHOW"
            }
        }
        FileButton{
            id: btn_filepath;
            textLabel: "文件路径";
            //icon:"\uf115"
            width: parent.itemWidth
            onClick: {
                messageBox.title = "注意"
                messageBox.note  = "存储路径已更新!"
                messageBox.isWarning = false
                messageBox.visible = true
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
            id: btn_menu;
            textLabel: "返回主菜单";
            icon:"\uf090"
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE";
                root.focus = false;
                idRightPannel.state="SHOW";
                idRightPannel.focus = true;
            }
        }

    }
    SaveMode{
        id:saveMode
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
    NameMode {
        id:nameMode
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        objectName: "nameMode"
    }


    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{
        var curFocusindex=0;//当前获得焦点的子元素索引
        globalConsoleInfo("#####SaveCfgMenu.qml收到按键消息#####"+event.key);
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
            Com.setPrevFocus(Com.childArray,curFocusindex);
            break;
        case Qt.Key_Down:
            curFocusindex=Com.getFocusIndex(Com.childArray);
            Com.setNextFocus(Com.childArray,curFocusindex);
            break;
        case Qt.Key_Enter:

            //            if(curFocusindex===-1)
            //            {
            //            curFocusindex=Com.getFocusIndex(Com.childArray);
            //            }
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
                globalConsoleInfo("☆☆☆☆SaveCfgMenu.qml获得焦点☆☆☆☆");
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

    function updateParams()
    {
        var saveMode = Settings.saveMode();
        var nameMode = Settings.nameMode();
        var storePath = Settings.filePath();
        dataSource.setStorParam(saveMode, nameMode, storePath);
        idBottomPannel.updateParams()
    }

}


