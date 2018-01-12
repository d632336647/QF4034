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
    objectName: "gatherMenu"
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
            id: btn_clockmode;
            textLabel: "时钟模式";
            width: parent.itemWidth
            onClick: {
                clockSeting.loadParam()
                clockSeting.state = "SHOW"
            }
        }
        SampleRate{
            id:btn_samplerate
            width: parent.itemWidth
        }

        RightButton {
            id: btn_triggermode;
            textLabel: "触发模式";
            width: parent.itemWidth
            onClick: {
                triggerMode.loadParam()
                triggerMode.state = "SHOW"
            }
        }
        RightButton {
            id: btn_gathermode;
            textLabel: "采集模式";
            width: parent.itemWidth
            onClick: {
                gatherMode.loadParam()
                gatherMode.state = "SHOW"
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

    ClockSeting{
        id:clockSeting
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    TriggerMode{
        id:triggerMode
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
    GatherMode{
        id:gatherMode
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }

    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{
        switch(event.key)
        {
        case Qt.Key_0:
            btn_exit.click()
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
        updateParams();
        preconditionMenu.updateParams();

    }

    function updateParams()
    {
        var clkMode     = Settings.clkMode();
        var captureRate = Settings.captureRate();
        var triggerMode = Settings.triggerMode();
        var captureMode = Settings.captureMode();
        var captureSize = Settings.captureSize();
        console.log("---------------------------CaptureMenu updateParams-------------------------------")
        console.log("clkMode:"+clkMode+" captureRate:"+captureRate+" triggerMode:"+triggerMode+" captureMode:"+captureMode+" captureSize:"+captureSize)
        console.log(" ")
        dataSource.setCaptureParam(clkMode, captureRate, triggerMode, captureMode, captureSize);
        idBottomPannel.updateParams()
    }

    function setSampRateReadOnly(en)
    {
        btn_samplerate.readOnly = en
    }

}


