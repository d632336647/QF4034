import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2

import Slibx.Uart 1.0
import Slibx.VirtualKey 1.0

import "Inc.js" as Com
import "UI"
import "Menu"
import "../SliChart"


Rectangle{
    id:root
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

/*
    //动态加载
    Item {
        id: idScopeView
        anchors.top: mainTitle.bottom
        anchors.right: parent.right//idRightPannel.left
        anchors.bottom: idBottomPannel.top
        anchors.left: parent.left
        visible: true
        Loader {
            id: svLoder
            anchors.fill: parent
            source: "ScopeView2CH.qml" //"../SliChart/ScopeView2CH.qml"
            onSourceChanged: {
                //if(source != "")
                //    svLoder.item
            }
            onLoaded: {
                idScopeView.updateSepctrumAxisY(Settings.reflevelMin(), Settings.reflevelMax())
            }
        }
        function changeAnalyzeMode()
        {
            svLoder.item.changeAnalyzeMode()
        }
        function updateSepctrumAxisY(min, max)
        {
            svLoder.item.updateSepctrumAxisY(min, max)
        }
        function changeChannelMode(mod)
        {
            svLoder.item.changeChannelMode(mod)
        }
    }
*/
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
        //anchors.right: parent.right
        anchors.bottom: idBottomPannel.top
    }
    PreconditionMenu{
        id:preconditionMenu
        x:root.width
        anchors.top: mainTitle.bottom
        //anchors.right: parent.right
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
        //anchors.right: parent.right
        anchors.bottom: idBottomPannel.top
    }
    SaveCfgMenu {
        id:saveCfgMenu
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
        Loader {
            id: pageLoader
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 120
        }
        onVisibleChanged: {
            if(visible)
            {
                pageLoader.source = "UI/PopuBox.qml"
                pageLoader.item.parentObject = fileContent
            }
            else
                pageLoader.source = ""
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

    ContentBox{
        id:uartContent
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 120
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
        }
        Rectangle{
            height: 120
            width: parent.width - 40
            anchors.centerIn: parent
            color: "#363636"
            Text{
                anchors.fill: parent
                id: textreceive
                color: "white"
                font.pixelSize: 12
                font.family: "Calibri"
                wrapMode: Text.Wrap
                text: uart.receivedata
            }
        }

        StateRect{
            id:closeBtn
            anchors.right: uartContent.right
            anchors.rightMargin: 40
            anchors.bottom: uartContent.bottom
            anchors.bottomMargin: 20
            width: 140;
            height: 24
            //textLabel:"关闭"
            btnName: "关闭"
            onClicked:
            {
                uartContent.visible = false
            }
        }
        StateRect{
            anchors.right: closeBtn.left
            anchors.rightMargin: 20
            anchors.bottom: uartContent.bottom
            anchors.bottomMargin: 20
            width: 140;
            height: 24
            //textLabel:"关闭"
            btnName: "清空"
            onClicked:
            {
                uart.receivedata=""
            }
        }
    }
    function sendKeyCode(code)
    {
        console.log(code)
        if(code === "017f")
            virKey.sendVitualKey(Qt.Key_0)
        else if(code === "01bf")
            virKey.sendVitualKey(Qt.Key_1)
        else if(code === "01df")
            virKey.sendVitualKey(Qt.Key_2)
        else if(code === "01ef")
            virKey.sendVitualKey(Qt.Key_3)
        else if(code === "01fb")
            virKey.sendVitualKey(Qt.Key_4)
        else if(code === "01fd")
            virKey.sendVitualKey(Qt.Key_5)
        else if(code === "01fe")
            virKey.sendVitualKey(Qt.Key_6)
        //else if(code === "01bf")
        //    virKey.sendVitualKey(Qt.Key_7)

    }
}
