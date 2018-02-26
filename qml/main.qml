import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2

import Slibx.Uart 1.0
import Slibx.VirtualKey 1.0

import "Inc.js" as Com
import "Lib.js" as Lib
import "UI"
import "Menu"
import "../SliChart"


Rectangle{
    id:root
    objectName: "mainboxRectangle";
    visible: true
    width: 1027
    height: 768
    color: "black"//Com.BGColor_main


    WindTitle{
        id:mainTitle
        anchors.top: parent.top             //对标题栏定位
        anchors.left: parent.left
        anchors.right: parent.right
        height: 0                          //设置标题栏高度
        color: "#1F1F1F"                    //设置标题栏背景颜色
        source:"qrc:/rc/image/app.ico"
        text:"实时频谱监测"
        visible: false
    }
    ScopeView2CH {
        id: idScopeView
        anchors.top: mainTitle.bottom
        anchors.right: parent.right//idRightPannel.left
        anchors.bottom: idBottomPannel.top
        anchors.left: parent.left
        visible: true
    }

    BottomPanel {
        id: idBottomPannel
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: parent.left
    }

    //侧面菜单
    RightControlPanel{
        id: idRightPannel
        anchors.top: mainTitle.bottom
        //anchors.right: parent.right
        anchors.bottom: parent.bottom
        state: "HIDE"
    }
    //！--侧面菜单结束

    GatherMenu {
        id:gatherMenu
        x:root.width
        anchors.top: mainTitle.bottom
        anchors.bottom: idBottomPannel.top
    }
    PreconditionMenu {
        id:preconditionMenu
        x:root.width
        anchors.top: mainTitle.bottom
        anchors.bottom: idBottomPannel.top
    }
    AnalyzeMode {
        id:analyzeMode
        x:root.width
        anchors.top: mainTitle.bottom
        anchors.bottom: idBottomPannel.bottom
    }
    AnalyzeMenu {
        id:analyzeMenu
        x:root.width
        anchors.top: mainTitle.bottom
        anchors.bottom: idBottomPannel.top
    }
    SaveCfgMenu {
        id:saveCfgMenu
        x:root.width
        anchors.top: mainTitle.bottom
        anchors.bottom: idBottomPannel.top
    }
    SystemMenu {
        id:systemMenu
        x:root.width
        anchors.top: mainTitle.bottom
        anchors.bottom: idBottomPannel.top
    }

    Rectangle{
        id: mask
        anchors.top: mainTitle.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: "black"
        opacity: 0.6
        visible: fileContent.visible
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
        }
    }


    //动态加载
    Item {
        id:fileContent
        anchors.fill: parent
        visible: false
        property var itemPointer: pageLoader.item
        Loader {
            id: pageLoader
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 120
            onLoaded: {
                //注意 Loader内的元素直接设置focus是无效的，必须先把Loader的focus设置为true,
                //Loader内的元素才能设置focus

                //直接在本级向子级传递按键消息,无需再设置子部件focus "Keys.forwardTo: [root, itemPointer]"
                //pageLoader.focus = true
                //pageLoader.item.focus = true
                fileCtrl.state = "SHOW"
            }
        }
        FileBoxCtrl{
            id:fileCtrl
            width: 200
            anchors.top: parent.top
            anchors.topMargin: 4
            visible: fileContent.visible
            state: "HIDE"
            onHideCompleted: {
                fileContent.visible = false
            }
        }
        onVisibleChanged: {
            if(visible)
            {
                pageLoader.source = "UI/FileBox.qml";
                pageLoader.item.parentPointer = fileContent
                pageLoader.item.updatePointer = analyzeMenu
            }
            else
            {
                pageLoader.source = ""
                analyzeMode.focus = true;
            }
        }
        Keys.enabled: true
        Keys.forwardTo: [root, itemPointer] //事件传递从子级开始,和写法顺序无关,也就是事件先传递到itemPointer,再传递到root
        Keys.onPressed:
        {
            switch(event.key)
            {
            case Qt.Key_F2:
                fileCtrl.btnSelect1Click()
                break;
            case Qt.Key_F3:
                fileCtrl.btnSelect2Click()
                break;
            case Qt.Key_F4:
                fileCtrl.btnSelect3Click()
                break;
            case Qt.Key_F5:
                fileCtrl.btnDeleteClick()
                break;
            case Qt.Key_F1://退出键按下后会销毁Loder内的item,
            case Qt.Key_F8:
                fileCtrl.btnReturnClick()
                break;
            }
            event.accepted = true;
        }
    }

    //动态加载
    Item {
        id:messageBox
        anchors.fill: parent
        visible: false
        property string title: ""
        property string note: ""
        property bool isWarning: true
        Loader {
            id: messageLoader
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -60;
            width: 600
            height: 60
        }
        onVisibleChanged: {
            if(visible)
            {
                messageLoader.source = "UI/MessageBox.qml"
                messageLoader.item.parentObject = messageBox
                messageLoader.item.title = messageBox.title
                messageLoader.item.note  = messageBox.note
                messageLoader.item.isWarning  = messageBox.isWarning
                messageLoader.item.visible  = visible
            }
            else
                messageLoader.source = ""
        }
    }

    Item{
        id:uartKey
        anchors.centerIn: parent
        width: 20
        height: 20
        visible: false
        QMLUart{
            id:uart
            Component.onCompleted: {
                uart.openAndSetPort(0,0,3,0,0,0)
            }
            onReceivedataChanged: {
                root.sendKeyCode(receivedata)
            }
        }
        VirtualKey{
            id:virKey
            Component.onCompleted:
            {
            }
        }
    }

    function sendKeyCode(code)
    {

        //左侧边按钮
        if(code === Com.controlPannel["C_ESCAPE"])  //ESC
            virKey.sendVirtualKey(Qt.Key_F1)
        else if(code === Com.controlPannel["C_FN1"]) //主键盘 1+shift
            virKey.sendVirtualKey(Qt.Key_F2)
        else if(code === Com.controlPannel["C_FN2"])  //主键盘2+shift
            virKey.sendVirtualKey(Qt.Key_F3)
        else if(code === Com.controlPannel["C_FN3"])  //主键盘3+shift
            virKey.sendVirtualKey(Qt.Key_F4)
        else if(code === Com.controlPannel["C_FN4"])  //主键盘4+shift
            virKey.sendVirtualKey(Qt.Key_F5)
        else if(code === Com.controlPannel["C_FN5"])  //主键盘5+shift
            virKey.sendVirtualKey(Qt.Key_F6)
        else if(code === Com.controlPannel["C_FN6"])  //主键盘6+shift
            virKey.sendVirtualKey(Qt.Key_F7)
        else if(code === Com.controlPannel["C_RETURN"]) //映射 Return
            virKey.sendVirtualKey(Qt.Key_F8)
        //方向区
        else if(code === Com.controlPannel["C_UP_ARROW"])//↑
            virKey.sendVirtualKey(Qt.Key_Up)
        else if(code === Com.controlPannel["C_DOWN_ARROW"])//↓
            virKey.sendVirtualKey(Qt.Key_Down)
        else if(code === Com.controlPannel["C_LEFT_ARROW"])//←
            virKey.sendVirtualKey(Qt.Key_Left)
        else if(code === Com.controlPannel["C_WRIGHT_ARROW"])//→
            virKey.sendVirtualKey(Qt.Key_Right)
        else if(code === Com.controlPannel["C_POS_ENTER"])//→
            virKey.sendVirtualKey(Qt.Key_Enter) //Enter
        //参数区
        else if(code === Com.controlPannel["C_DIGIT_ZERO"])
            virKey.sendVirtualKey(Qt.Key_0,"0");
        else if(code === Com.controlPannel["C_DIGIT_ONE"])
            virKey.sendVirtualKey(Qt.Key_1,"1");
        else if(code === Com.controlPannel["C_DIGIT_TWO"])
            virKey.sendVirtualKey(Qt.Key_2,"2");
        else if(code === Com.controlPannel["C_DIGIT_THREE"])
            virKey.sendVirtualKey(Qt.Key_3,"3");
        else if(code === Com.controlPannel["C_DIGIT_FOUR"])
            virKey.sendVirtualKey(Qt.Key_4,"4");
        else if(code === Com.controlPannel["C_DIGIT_FIVE"])
            virKey.sendVirtualKey(Qt.Key_5,"5");
        else if(code === Com.controlPannel["C_DIGIT_SIX"])
            virKey.sendVirtualKey(Qt.Key_6,"6");
        else if(code === Com.controlPannel["C_DIGIT_SEVEN"])
            virKey.sendVirtualKey(Qt.Key_7,"7");
        else if(code === Com.controlPannel["C_DIGIT_EIGHT"])
            virKey.sendVirtualKey(Qt.Key_8,"8");
        else if(code === Com.controlPannel["C_DIGIT_NINE"])
            virKey.sendVirtualKey(Qt.Key_9,"9");
        else if(code === Com.controlPannel["C_DIGIT_POINT"])
            virKey.sendVirtualKey(Qt.Key_Period,".");
        else if(code === Com.controlPannel["C_DIGIT_PLUS_MINUS"])//小键盘-
            virKey.sendVirtualKey(Qt.Key_Minus)
        else if(code === Com.controlPannel["C_BK_SP"])//backspace
            virKey.sendVirtualKey(Qt.Key_Backspace)
        else if(code === Com.controlPannel["C_ENTER"])//Enter
            virKey.sendVirtualKey(Qt.Key_Enter)
        //控制区域
        else if(code === Com.controlPannel["C_FREQUENCY_CHANNEL"])//FREQUENCY
            virKey.sendVirtualKey(Qt.Key_F9)
        else if(code === Com.controlPannel["C_MEASURE"])//MEASURE
            virKey.sendVirtualKey(Qt.Key_F10)
        else if(code === Com.controlPannel["C_DET_DEMOD"])//DET_DEMOD
            virKey.sendVirtualKey(Qt.Key_F11)
        else if(code === Com.controlPannel["C_AUTO_COUPLE"])//AUTO_COUPLE
            virKey.sendVirtualKey(Qt.Key_F12)
        else if(code === Com.controlPannel["C_SPAN_X_SCALE"])//SPAN_X_SCALE
            virKey.sendVirtualKey(Qt.Key_F13)
        else if(code === Com.controlPannel["C_TRACE_VIEW"])//TRACE_VIEW
            virKey.sendVirtualKey(Qt.Key_F14)
        else if(code === Com.controlPannel["C_BW_AVG"])//BW_AVG
            virKey.sendVirtualKey(Qt.Key_F15)
        else if(code === Com.controlPannel["C_TRIG"])//TRIG
            virKey.sendVirtualKey(Qt.Key_F16)
        else if(code === Com.controlPannel["C_AMPLITUDE_Y_SCALE"])//AMPLITUDE_Y_SCALE
            virKey.sendVirtualKey(Qt.Key_F17)
        else if(code === Com.controlPannel["C_DISPLAY"])//DISPLAY
            virKey.sendVirtualKey(Qt.Key_F18)
        else if(code === Com.controlPannel["C_SINGLE"])//SINGLE
            virKey.sendVirtualKey(Qt.Key_F19)
        else if(code === Com.controlPannel["C_SWEEP"])//SWEEP
            virKey.sendVirtualKey(Qt.Key_F20)
        //系统区域
        else if(code === Com.controlPannel["C_SYSTEM"])//SYSTEM
            virKey.sendVirtualKey(Qt.Key_F21)
        else if(code === Com.controlPannel["C_PRESET"])//PRESET
            virKey.sendVirtualKey(Qt.Key_F22)
        else if(code === Com.controlPannel["C_MARKER"])//MARKER
            virKey.sendVirtualKey(Qt.Key_F23)
        else if(code === Com.controlPannel["C_PEAK_SEARCH"])//PEAK_SEARCH
            virKey.sendVirtualKey(Qt.Key_F24)
        else if(code === Com.controlPannel["C_MARKER_FCTN"])//MARKER_FCTN
            virKey.sendVirtualKey(Qt.Key_F25)
        else if(code === Com.controlPannel["C_MAKER_ARROW"])//MAKER_ARROW
            virKey.sendVirtualKey(Qt.Key_F26)
        else if(code === Com.controlPannel["C_SOURCE"])//C_SOURCE
            virKey.sendVirtualKey(Qt.Key_F27)

        //滚轮操作
        else if(code === Com.controlPannel["C_WHEEL_CLOCKWISE"])//C_WHEEL_CLOCKWISE
            virKey.sendVirtualKey(Qt.Key_PageDown)
        else if(code === Com.controlPannel["C_WHEEL_ANTICLOCKWISE"])//C_WHEEL_ANTICLOCKWISE
            virKey.sendVirtualKey(Qt.Key_PageUp)
    }
    
    Component.onCompleted: {

    }
}
