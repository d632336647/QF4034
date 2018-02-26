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
    width: 200
    anchors.topMargin: 4
    anchors.bottomMargin: 4

    //border.color: Com.BottomBorderColor
    //border.width: 1
    color: Com.BGColor_main
    property var  analyzeChildren : Com.childArray  //子控件
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
            id: btn_rt_spectrum;
            textLabel: "实时频谱图";
            width: parent.itemWidth
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(0)
            }
        }
        RightButton {
            id: btn_rt_walterfall;
            textLabel: "实时瀑布图";
            width: parent.itemWidth
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(1)
            }
        }
        RightButton {
            id: btn_files_spectrum;
            textLabel: "历史频谱图对比";
            width: parent.itemWidth
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(2)
            }
        }
        RightButton {
            id: btn_files_walterfall;
            textLabel: "历史瀑布图分析";
            width: parent.itemWidth
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(3)
            }
        }
        RightButton {
            id: btn_files_timedomain;
            textLabel: "历史时域波形图";
            width: parent.itemWidth
            onClick: {
                clearSelectBorder()
                selected(true)
                setParam(4)
            }
        }
        RightButton {
            id: btn_historyfiles;
            textLabel: "历史文件";
            width: parent.itemWidth
            onClick: {
                //注意此处不要调换函数调用顺序
                fileContent.focus   = true
                fileContent.visible = true
               //updateParams()
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
        var key = [Qt.Key_F1, Qt.Key_F2, Qt.Key_F3, Qt.Key_F4, Qt.Key_F5, Qt.Key_F6, Qt.Key_F7, Qt.Key_F8]
        var fid = [btn_menu, btn_rt_spectrum, btn_rt_walterfall, btn_files_spectrum, btn_files_walterfall, btn_files_timedomain, btn_historyfiles, btn_return]
        Lib.clickFunctionKey(event.key, key, fid);
        event.accepted = true;
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
    //！--过渡动画结束
    function hideMenu(){
        root.state = "HIDE";
    }
    function turnToMainMenu()
    {
        hideMenu()
        idRightPannel.state = "SHOW";
        idRightPannel.focus = true;
    }
    function turnToParentMenu()
    {
        root.state = "HIDE"
        idRightPannel.focus = true;
    }
    function clearSelectBorder()
    {
        var list = content.children
        for(var i in list){
            list[i].selected(false);
        }
    }
    function loadParam()
    {
        var btn_array = [btn_rt_spectrum, btn_rt_walterfall, btn_files_spectrum, btn_files_walterfall, btn_files_timedomain]
        var idx = Settings.analyzeMode()
        if(idx < 0 || idx > 4)
            return
        clearSelectBorder();
        btn_array[idx].selected(true);
    }
    function setParam(val)
    {
        Settings.analyzeMode(Com.OpSet, val)
        analyzeMenu.updateParams()
        //Settings.save();
    }
}

