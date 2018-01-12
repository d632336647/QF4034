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

        RightButton {
            id: empty1;
            textLabel: "退出程序";
            icon:"\uf090"
            onClick: {
                Settings.save()
                captureThread.exit()
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
        //console.log("x:", root.x)
    }
    onXChanged: {
        //console.log("x:", root.x)
    }


    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{
        switch(event.key)
        {
        case Qt.Key_0:
            root.state = "SHOW"
            break;
        case Qt.Key_1:
            btn_capture_config.click()
            break;
        case Qt.Key_2:
            btn_analyze_config.click()
            break;
        case Qt.Key_3:
            btn_save_config.click()
            break;
        case Qt.Key_4:
            //Lib.jumpToMenu(Settings, root.parent, "gatherMenu");
            //Lib.jumpToMenu(Settings, root.parent, "clockSetting");
            //Lib.menuLoadParam(Settings, root.parent, "clockSetting");
            //btn_start_store.click()
            break;
        case Qt.Key_5:
            break;
        case Qt.Key_6:
            break;
        case Qt.Key_7:
            break;
        case Qt.Key_Enter:
            //event.accepted = true;
            break;
        }
    }

    Connections {
        target: dataSource;
        onStoreEnd:{
//          console.log(writedLen);
            btn_start_store.isStoring = false;
            btn_start_store.textLabel = "启动存储"
        }
    }





}
