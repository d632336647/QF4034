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
                root.focus = false
                idRightPannel.focus = true
            }
        }
        RightButton {
            id: btn_outmode;
            textLabel: "输出模式";
            width: parent.itemWidth
            onClick: {

            }
        }
        RightButton {
            id: btn_channelenable;
            textLabel: "通道使能";
            width: parent.itemWidth
            onClick: {

            }
        }

        RightButton {
            id: btn_ddcfreq;
            textLabel: "DDC载频";
            width: parent.itemWidth
            onClick: {

            }
        }
        RightButton {
            id: btn_extractfactor ;
            textLabel: "抽取因子";
            width: parent.itemWidth
            onClick: {

            }
        }
        RightButton {
            id: btn_fsbcoef;
            textLabel: "Fs/B系数";
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
            id: btn_menu;
            textLabel: "返回主菜单";
            icon: "\uf090";
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE"
                idRightPannel.focus = true
            }
        }

    }

    //ClockSeting{
    //    id:clockSeting
    //    anchors.top: parent.top
    //    anchors.bottom: parent.bottom
    //}




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

    }

    function updateParams()
    {
        var outmode = 0;
        var chCount = 2;
        var ddcfreq = 70.000;//MHz
        var extractfactor = 4;
        var fsbcoef  = 0;//1.25B
        console.log("---------------------------PreCondition updateParams------------------------------")
        console.log("outmode:"+outmode+" chCount:"+chCount+" ddcfreq:"+ddcfreq+" extractfactor:"+extractfactor+" fsbcoef:"+fsbcoef)
        console.log(" ")
        Settings.ddcFreq(Com.OpSet, ddcfreq)
        Settings.extractFactor(Com.OpSet, extractfactor)
        Settings.fsbCoef(Com.OpSet, fsbcoef)
        dataSource.setPreConditionParam(outmode, chCount, ddcfreq, extractfactor, fsbcoef);

    }

}


