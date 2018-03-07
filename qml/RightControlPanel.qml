import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import "Inc.js" as Com
import "Lib.js" as Lib
import "UI"

Rectangle{
    id:root

    width: Com.RightMenuWidth

    anchors.topMargin: 4
    anchors.bottomMargin: 4

    //border.color: Com.bottomBorderColor
    //border.width: 1
    color: Com.bgColorMain
    focus: true

    state: "SHOW"

    ColumnLayout {
        spacing: 4;
        anchors.top: parent.top;
        //anchors.horizontalCenter: parent.horizontalCenter;   //dhy
        //anchors.left: parent.left;
        anchors.left: parent.left
        anchors.leftMargin: 4;
        property int itemWidth: root.width - 8
        objectName: "rightControlColumnLayout";
        RightButton {
            id: btn_menu;
            textLabel: "关闭菜单";
            icon:"\uf090"
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE"
                root.focus = true;
            }
        }
        RightButton {
            id: btn_ddcmenu;
            textLabel: "预处理设置";
            //icon:"\uf07c"
            width: parent.itemWidth
            onClick: {
                preconditionMenu.state = "SHOW"
                preconditionMenu.focus = true;
            }
        }
        RightButton {
            id: btn_capture_config;
            textLabel: "采集设置";
            width: parent.itemWidth
            onClick: {
                gatherMenu.state = "SHOW"
                gatherMenu.focus = true;
            }
        }
        RightButton {
            id: btn_analyzemode;
            textLabel: "分析模式";
            width: parent.itemWidth
            onClick: {
                analyzeMode.loadParam()
                analyzeMode.state = "SHOW"
            }
        }
        RightButton {
            id: btn_analyze_config;
            textLabel: "分析参数";
            width: parent.itemWidth
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
            width: parent.itemWidth
            onClick: {
                saveCfgMenu.state = "SHOW"
                saveCfgMenu.focus = true;
            }
        }
        RightButton {
            property bool isStoring: false
            id: btn_start_store
            textLabel: "启动存储";
            width: parent.itemWidth
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
            id: btn_return;
            textLabel: "关闭菜单";
            width: parent.itemWidth
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
            PropertyChanges { target: root; x: root.parent.width-Com.RightMenuWidth}
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
        var key = [Qt.Key_F1, Qt.Key_F2, Qt.Key_F3, Qt.Key_F4, Qt.Key_F5, Qt.Key_F6, Qt.Key_F7, Qt.Key_F8]
        var fid = [btn_menu, btn_ddcmenu, btn_capture_config, btn_analyzemode, btn_analyze_config, btn_save_config, btn_start_store, btn_return]
        if(Lib.operateSpecView(event.key))
        {
            event.accepted = true;
            return
        }
        if(root.state == "HIDE"){
            for(var i=0; i<key.length; i++){
                if(event.key === key[i]){
                    root.state = "SHOW"
                    idScopeView.svCloseAllOpBtn()
                    break;
                }
            }
        }else{
            Lib.clickFunctionKey(event.key, key, fid)
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
