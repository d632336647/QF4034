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
    objectName: "analyzeMenu"
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
        CenterFreq {
            id: btn_centerfreq;
            width: parent.itemWidth
        }
        ViewBandwidth {
            id: btn_bandwidth;
            width: parent.itemWidth
        }
        Resolution {
            id: btn_resolution;
            width: parent.itemWidth
        }
        ReferenceLevel {
            id: btn_reference;
            width: parent.itemWidth
        }

        RightButton {
            id: empty1;
            textLabel: "通道切换";
            //icon:"\uf07c"
            onClick: {
                var ch = Settings.paramsSetCh();
                ch = ch?0:1;
                Settings.paramsSetCh(Settings.Set, ch);
                btn_centerfreq.state = "toFront"
                btn_bandwidth.state  = "toFront"
                btn_resolution.state = "toFront"
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
            id: btn_menu;
            textLabel: "返回主菜单";
            icon: "\uf090";
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE"

            }
        }
    }




    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{
        switch(event.key)
        {
        case Qt.Key_0:
            btn_exit.click()
            break;
        case Qt.Key_1:
            btn_centerfreq.inputFocus = true
            break;
        case Qt.Key_2:
            btn_bandwidth.inputFocus = true
            break;
        case Qt.Key_3:
            btn_resolution.inputFocus = true
            break;
        case Qt.Key_4:
            //btn_reference.inputFocus = true
            break;
        case Qt.Key_Up:
            keyup();
            break;
        case Qt.Key_Down:
            keydowm();
            break;
        case Qt.Key_Enter:
            keyenter()
            //event.accepted = true;
            break;
        }
    }
    function keyup()
    {
        console.log("key up")
    }
    function keydowm()
    {
        console.log("key down")
    }
    function keyenter()
    {
        console.log("key enter")
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
        updateParams()
    }
    function reloadParams()
    {
        btn_centerfreq.loadParam()
        btn_bandwidth.loadParam()
        btn_resolution.loadParam()
        btn_reference.loadParam()
    }
    function updateParams()
    {
        var centerFreq =  Settings.centerFreq()
        var bandwidth  =  Settings.bandWidth()
        var resolution =  Settings.resolutionSize()
        console.log("---------------------------AnalyzeMenu updateParams-------------------------------")
        console.log("centerFreq:"+centerFreq+" bandwidth:"+bandwidth+" resolution:"+resolution)
        console.log(" ")
        dataSource.setFFTParam(centerFreq, bandwidth, resolution)
        idScopeView.changeAnalyzeMode()
        idBottomPannel.updateParams()
    }
}


