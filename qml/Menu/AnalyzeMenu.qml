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
    width: Com.RightMenuWidth
    anchors.topMargin: 4
    anchors.bottomMargin: 4
    objectName: "analyzeMenu"
    //border.color: Com.bottomBorderColor
    //border.width: 1
    color: Com.bgColorMain

    ColumnLayout {
        id:content
        spacing: 4;
        anchors.top: parent.top;
        anchors.left: parent.left
        anchors.leftMargin: 4;
        property int itemWidth: root.width - 8
        RightButton {
            id: btn_menu;
            textLabel: "退出菜单";
            icon:"\uf112"
            width: parent.itemWidth
            onClick: {
                turnToMainMenu()
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
            id: btn_switch;
            textLabel: "通道切换";
            //icon:"\uf07c"
            onClick: {
                var ch = Settings.paramsSetCh();
                ch = ch?0:1;
                Settings.paramsSetCh(Com.OpSet, ch);
                idScopeView.svSetActiveChannel()
                btn_centerfreq.state = "toFront"
                btn_bandwidth.state  = "toFront"
                btn_fftpoints.state  = "toFront"
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
            id: btn_return;
            textLabel: "返回上级";
            icon: "\uf090";
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
        var key = [Qt.Key_F1, Qt.Key_F2, Qt.Key_F3, Qt.Key_F4, Qt.Key_F5, Qt.Key_F6, Qt.Key_F8]
        var fid = [btn_menu, btn_centerfreq, btn_bandwidth, btn_fftpoints, btn_reference, btn_switch, btn_return]
        Lib.clickFunctionKey(event.key, key, fid);
        event.accepted = true;
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
    //！--过渡动画结束
    Component.onCompleted: {
        setAnalyzeParam()
        idBottomPannel.updateParams()
    }
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
        root.state = "HIDE";
        idRightPannel.state = "SHOW"
        idRightPannel.focus = true;
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


