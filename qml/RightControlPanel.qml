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
            }
        }
        RightButton {
            id: btn_capture_config;
            textLabel: "采集设置";
            onClick: {
                gatherMenu.state = "SHOW"
                gatherMenu.focus = true;
            }
        }
        RightButton {
            id: btn_analyzemode;
            textLabel: "分析模式";
            onClick: {
                analyzeMode.loadParam()
                analyzeMode.state = "SHOW"
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
            }
        }
        RightButton {
            id: btn_save_config;
            textLabel: "存储设置";
            onClick: {
                saveCfgMenu.state = "SHOW"
                saveCfgMenu.focus = true;
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

    onXChanged: {
        //console.log("x:", root.x)
    }


    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{
        if(Lib.operateSpecView(event.key))
        {
            event.accepted = true;
            return
        }
        if(root.state == "HIDE")
        {
            root.state = "SHOW"
            idScopeView.svCloseAllOpBtn()
        }
        else
        {
            var key = [/*Qt.Key_F1,*/ Qt.Key_F2, Qt.Key_F3, Qt.Key_F4, Qt.Key_F5, Qt.Key_F6, Qt.Key_F7, Qt.Key_F8]
            var fid = [/*empty1,*/ btn_ddcmenu, btn_capture_config, btn_analyzemode, btn_analyze_config, btn_save_config, btn_start_store, empty4]
            Lib.clickFunctionKey(event.key, key, fid);
        }
        event.accepted = true;
    }

    Connections {
        target: dataSource;
        onStoreEnd:{
            btn_start_store.isStoring = false;
            btn_start_store.textLabel = "启动存储"
        }
    }

    Component.onCompleted:
    {

    }

}
