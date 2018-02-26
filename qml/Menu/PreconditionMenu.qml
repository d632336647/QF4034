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
            id: btn_menu;
            textLabel: "返回主菜单";
            icon: "\uf090";
            width: parent.itemWidth
            onClick: {
                turnToMainMenu()
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
            id: btn_return;
            textLabel: "返回上级";
            icon:"\uf112"
            width: parent.itemWidth
            onClick: {
                turnToParentMenu()
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
        if(Lib.operateSpecView(event.key))
        {
            hideMenu()
            event.accepted = true;
            return
        }
        var key = [Qt.Key_F1, Qt.Key_F4, Qt.Key_F5, Qt.Key_F6, Qt.Key_F8]
        var fid = [btn_menu,  btn_extractfactor, btn_fsbcoef, btn_ddcfreq, btn_return]
        Lib.clickFunctionKey(event.key, key, fid);
        event.accepted = true;
    }

    Component.onCompleted: {

    }
    function hideMenu()
    {
        root.state = "HIDE"
    }
    function turnToMainMenu()
    {
        hideMenu()
        idRightPannel.focus = true
        idRightPannel.state = "SHOW";
    }
    function turnToParentMenu()
    {
        root.state = "HIDE"
        idRightPannel.focus = true;
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


