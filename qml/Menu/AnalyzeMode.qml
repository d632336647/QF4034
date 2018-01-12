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
            id: btn_return;
            textLabel: "返回上级";
            icon:"\uf112"
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE"
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
                fileContent.visible = true
                //updateParams()
            }
        }
        RightButton {
            id: btn_exit;
            textLabel: "返回主菜单";
            icon: "\uf090";
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE"

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

    function clearSelectBorder()
    {
        var list = content.children

        for(var i in list)
        {
            list[i].selected(false);
        }
    }
    function loadParam()
    {

        if(Settings.analyzeMode() === 0)
            btn_rt_spectrum.selected(true);
        else if(Settings.analyzeMode() === 1)
            btn_rt_walterfall.selected(true);
        else if(Settings.analyzeMode() === 2)
            btn_files_spectrum.selected(true);
        else if(Settings.analyzeMode() === 3)
            btn_files_walterfall.selected(true);
        else
            btn_files_timedomain.selected(true);


    }
    function setParam(val)
    {
        Settings.analyzeMode(Settings.Set, val)
        analyzeMenu.updateParams()
        //Settings.save();
    }
}

