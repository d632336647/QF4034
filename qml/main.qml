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
        property var keysOwner: pageLoader
        Loader {
            id: pageLoader
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 120
            onLoaded: {
                if( pageLoader.item.popuBoxFileListView)
                    keysOwner=pageLoader.item.popuBoxFileListView;
            }
            property var loaderFileRect: undefined  //文件外边框
            property var loaderFileList: []  //每个列表组成的数组

            //重新设置键盘消息受理者
            function setKeysOwner(newHostOwner)
            {
                if(newHostOwner)
                {
                    fileContent.keysOwner=newHostOwner;
                }
            }
            function showLoaderInfo() //获得文件列表
            {
                var thefileList=pageLoader.item.getFileListBoxElement(pageLoader.item);//整个对话框而不是文件列表

                var thefileListChlidren=thefileList.children;
                var theFileListIndex=0;
                for(var vv=0;vv<thefileListChlidren.length;vv++ )
                {

                    var theEachfileListChlidren=thefileListChlidren[vv];
                    var theEachfileListChlidrenStr=theEachfileListChlidren.toString();

                    if(theEachfileListChlidrenStr.indexOf("ListView")!==-1)
                    {
                        thefileListChlidren[vv].focus=true;
                        theFileListIndex=vv;
                        pageLoader.item.popuBoxFileListView=thefileListChlidren[vv];
                        setKeysOwner(pageLoader.item.popuBoxFileListView);
                        //console.info("######找到文件名列表框ListView,索引是#######"+theFileListIndex);
                        loaderFileList=Com.getEveryItem(thefileListChlidren[vv]);
                        if(loaderFileList.length>0)
                        {
                            console.info("###※○※○※○※○showLoaderInfo调用完毕※○※○※○※○####"+loaderFileList);
                        }
                        break;
                    }

                }


            }

            function getBottomRectArray()
            {
                //文件列表框
                pageLoader.item.getFileListBoxElement(pageLoader.item);

                //文件列表框和下面的按钮
                pageLoader.item.getAllAtomChildrenOfPopBox(pageLoader.item);

                //下面的按钮
                pageLoader.item.getStateRectOfFileList(pageLoader.item);

                //                console.info("pageLoader.item.popBoxchildArray=="+pageLoader.item.popBoxchildArray);
                //                console.info("pageLoader.item.filelistchildArray=="+pageLoader.item.filelistchildArray);
                //                console.info("pageLoader.item.stateRectArray=="+pageLoader.item.stateRectArray);
            }

        }
        onVisibleChanged: {
            if(visible)
            {
                pageLoader.source = "UI/PopuBox.qml";
                //loader赋值
                pageLoader.source.myLoader=pageLoader;


                pageLoader.item.parentObject = fileContent
                fileContent.focus=true;
            }
            else
                pageLoader.source = ""
        }
        Keys.enabled: true
        Keys.forwardTo: [keysOwner]
        Keys.onPressed:{

            //loader赋值
            pageLoader.source.myLoader=pageLoader;

            var theTargetItem=pageLoader.item.stateRectArray;
            switch(event.key)
            {

            case Qt.Key_1:
                if(theTargetItem[0])
                {
                    theTargetItem[0].clicked();
                    console.info("-----theTargetItem[0].btnName----"+theTargetItem[0].btnName);
                }
                pageLoader.focus=true;
                break;
            case Qt.Key_2:
                if(theTargetItem[1])
                {
                    theTargetItem[1].clicked();
                    console.info("-----theTargetItem[1].btnName----"+theTargetItem[1].btnName);
                }
                pageLoader.focus=true;
                break;
            case Qt.Key_3:
                if(theTargetItem[2])
                {
                    theTargetItem[2].clicked();
                    console.info("-----theTargetItem[2].btnName----"+theTargetItem[2].btnName);
                }
                pageLoader.focus=true;
                break;
            case Qt.Key_4:
                if(theTargetItem[3])
                {
                    theTargetItem[3].clicked();
                    console.info("-----theTargetItem[3].btnName----"+theTargetItem[3].btnName);
                }
                pageLoader.focus=true;
                break;
            case Qt.Key_5:
                if(theTargetItem[4])
                {
                    theTargetItem[4].clicked();
                    console.info("-----theTargetItem[4].btnName----"+theTargetItem[4].btnName);
                }
                pageLoader.focus=true;
                break;
            case Qt.Key_Escape:
                if(pageLoader.item.closeBtn)
                {
                    pageLoader.item.closeBtn.clicked();
                    console.info("-----文件选择对话框收到ESC----");
                }

                break;
            default:
                console.info("□□□□□□□□□keysOwner====="+keysOwner+"收到按键消息□□□□□□□□□□□"+event.key);

            }
            event.accepted=true;//如果不吃掉，Mainbox.qml会收到未注册消息#
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
    
    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{

        switch(event.key)
        {
        case Qt.Key_Left:
            globalConsoleInfo("#####Mainbox.qml收到Qt.Key_Left按键消息#####");
            idScopeView.focus=true;
            idScopeView.focusPageOfrightControl=idRightPannel;
            event.accepted=true;
            break;
        case Qt.Key_PageUp://逆时针
            globalConsoleInfo("#####Mainbox.qml收到滚轮逆时针按键消息#####");
            idScopeView.focus=true;
            idScopeView.focusPageOfrightControl=idRightPannel;
            event.accepted=true;
            break;
        case Qt.Key_Right:
            globalConsoleInfo("#####Mainbox.qml收到Key_Right按键消息#####");
            idRightPannel.focus=true;
            idRightPannel.state="SHOW";
            event.accepted=true;
            break;
        case Qt.Key_PageDown://顺时针
            globalConsoleInfo("#####Mainbox.qml收到滚轮顺时针按键消息#####");
            idRightPannel.focus=true;
            idRightPannel.state="SHOW";
            event.accepted=true;
            break;
        default:
            globalConsoleInfo("#####Mainbox.qml收到未注册消息#####"+event.key);
            break;
        }


    }
function sendKeyCode(code)
    {
        //globalConsoleInfo("转发单片机收到的按键码"+code);

        //左侧边按钮
        if(code === Com.controlPannel["C_ESCAPE"])  //ESC
            virKey.sendVitualKey(Qt.Key_Escape)
        else if(code === Com.controlPannel["C_FN1"]) //主键盘 1+shift
            virKey.sendVitualKey(Qt.Key_Exclam)
        else if(code === Com.controlPannel["C_FN2"])  //主键盘2+shift
            virKey.sendVitualKey(Qt.Key_At)
        else if(code === Com.controlPannel["C_FN3"])  //主键盘3+shift
            virKey.sendVitualKey(Qt.Key_NumberSign)
        else if(code === Com.controlPannel["C_FN4"])  //主键盘4+shift
            virKey.sendVitualKey(Qt.Key_Dollar)
        else if(code === Com.controlPannel["C_FN5"])  //主键盘5+shift
            virKey.sendVitualKey(Qt.Key_Percent)
        else if(code === Com.controlPannel["C_FN6"])  //主键盘6+shift
            virKey.sendVitualKey(Qt.Key_AsciiCircum)
        else if(code === Com.controlPannel["C_RETURN"]) //映射 Return
            virKey.sendVitualKey(Qt.Key_Space)
        //方向区
        else if(code === Com.controlPannel["C_UP_ARROW"])//↑
            virKey.sendVitualKey(Qt.Key_Up)
        else if(code === Com.controlPannel["C_DOWN_ARROW"])//↓
            virKey.sendVitualKey(Qt.Key_Down)
        else if(code === Com.controlPannel["C_LEFT_ARROW"])//←
            virKey.sendVitualKey(Qt.Key_Left)
        else if(code === Com.controlPannel["C_WRIGHT_ARROW"])//→
            virKey.sendVitualKey(Qt.Key_Right)
        else if(code === Com.controlPannel["C_POS_ENTER"])//→
            virKey.sendVitualKey(Qt.Key_Enter) //Enter
        //参数区
        else if(code === Com.controlPannel["C_DIGIT_ZERO"])
        {
            virKey.sendVitualKey(Qt.Key_0,"0");
            globalConsoleInfo("mainbox.qml发送的键值:"+code);
        }
        else if(code === Com.controlPannel["C_DIGIT_ONE"])
        {
            virKey.sendVitualKey(Qt.Key_1,"1");
            globalConsoleInfo("mainbox.qml发送的键值:"+code);
        }
        else if(code === Com.controlPannel["C_DIGIT_TWO"])
        {
            virKey.sendVitualKey(Qt.Key_2,"2");
            globalConsoleInfo("mainbox.qml发送的键值:"+code);
        }
        else if(code === Com.controlPannel["C_DIGIT_THREE"])
            virKey.sendVitualKey(Qt.Key_3,"3");
        else if(code === Com.controlPannel["C_DIGIT_FOUR"])
            virKey.sendVitualKey(Qt.Key_4,"4");
        else if(code === Com.controlPannel["C_DIGIT_FIVE"])
            virKey.sendVitualKey(Qt.Key_5,"5");
        else if(code === Com.controlPannel["C_DIGIT_SIX"])
            virKey.sendVitualKey(Qt.Key_6,"6");
        else if(code === Com.controlPannel["C_DIGIT_SEVEN"])
            virKey.sendVitualKey(Qt.Key_7,"7");
        else if(code === Com.controlPannel["C_DIGIT_EIGHT"])
            virKey.sendVitualKey(Qt.Key_8,"8");
        else if(code === Com.controlPannel["C_DIGIT_NINE"])
            virKey.sendVitualKey(Qt.Key_9,"9");
        else if(code === Com.controlPannel["C_DIGIT_POINT"])
            virKey.sendVitualKey(Qt.Key_Period,".");
        else if(code === Com.controlPannel["C_DIGIT_PLUS_MINUS"])//小键盘-
            virKey.sendVitualKey(Qt.Key_Minus)
        else if(code === Com.controlPannel["C_BK_SP"])//backspace
            virKey.sendVitualKey(Qt.Key_Backspace)
        else if(code === Com.controlPannel["C_ENTER"])//Enter
            virKey.sendVitualKey(Qt.Key_Enter)
        //控制区域
        else if(code === Com.controlPannel["C_FREQUENCY_CHANNEL"])//FREQUENCY
            virKey.sendVitualKey(Qt.Key_F1)
        else if(code === Com.controlPannel["C_MEASURE"])//MEASURE
            virKey.sendVitualKey(Qt.Key_F2)
        else if(code === Com.controlPannel["C_DET_DEMOD"])//DET_DEMOD
            virKey.sendVitualKey(Qt.Key_F3)
        else if(code === Com.controlPannel["C_AUTO_COUPLE"])//AUTO_COUPLE
            virKey.sendVitualKey(Qt.Key_F4)
        else if(code === Com.controlPannel["C_SPAN_X_SCALE"])//SPAN_X_SCALE
            virKey.sendVitualKey(Qt.Key_F5)
        else if(code === Com.controlPannel["C_TRACE_VIEW"])//TRACE_VIEW
            virKey.sendVitualKey(Qt.Key_F6)
        else if(code === Com.controlPannel["C_BW_AVG"])//BW_AVG
            virKey.sendVitualKey(Qt.Key_F7)
        else if(code === Com.controlPannel["C_TRIG"])//TRIG
            virKey.sendVitualKey(Qt.Key_F8)
        else if(code === Com.controlPannel["C_AMPLITUDE_Y_SCALE"])//AMPLITUDE_Y_SCALE
            virKey.sendVitualKey(Qt.Key_F9)
        else if(code === Com.controlPannel["C_DISPLAY"])//DISPLAY
            virKey.sendVitualKey(Qt.Key_F10)
        else if(code === Com.controlPannel["C_SINGLE"])//SINGLE
            virKey.sendVitualKey(Qt.Key_F11)
        else if(code === Com.controlPannel["C_SWEEP"])//SWEEP
            virKey.sendVitualKey(Qt.Key_F12)
        //系统区域
        else if(code === Com.controlPannel["C_SYSTEM"])//SYSTEM
            virKey.sendVitualKey(Qt.Key_F13)
        else if(code === Com.controlPannel["C_PRESET"])//PRESET
            virKey.sendVitualKey(Qt.Key_F14)
        else if(code === Com.controlPannel["C_MARKER"])//MARKER
            virKey.sendVitualKey(Qt.Key_F15)
        else if(code === Com.controlPannel["C_PEAK_SEARCH"])//PEAK_SEARCH
            virKey.sendVitualKey(Qt.Key_F16)
        else if(code === Com.controlPannel["C_MARKER_FCTN"])//MARKER_FCTN
            virKey.sendVitualKey(Qt.Key_F17)
        else if(code === Com.controlPannel["C_MAKER_ARROW"])//MAKER_ARROW
            virKey.sendVitualKey(Qt.Key_F18)
        else if(code === Com.controlPannel["C_SOURCE"])//C_SOURCE
            virKey.sendVitualKey(Qt.Key_F19)

        //滚轮操作
        else if(code === Com.controlPannel["C_WHEEL_CLOCKWISE"])//C_WHEEL_CLOCKWISE
            virKey.sendVitualKey(Qt.Key_PageDown)
        else if(code === Com.controlPannel["C_WHEEL_ANTICLOCKWISE"])//C_WHEEL_ANTICLOCKWISE
            virKey.sendVitualKey(Qt.Key_PageUp)
    }
    
    function getSubItem()
    {
        var list=root.children;
        globalConsoleInfo("count:"+list.length);
        for ( var i in list) {
            globalConsoleInfo("list[ " +i + " ] id = " + list[i].attr("id"));
            globalConsoleInfo("list[ " +i + " ] type = " + list[i].type);

        }

    }

    //全局打印函数
    function globalConsoleInfo(infostr)
    {
        var debugInfoFlag=false;
        if(debugInfoFlag)
            console.info(infostr);

    }

    Component.onCompleted: {
        globalConsoleInfo("                                    ");
        globalConsoleInfo("                                    ");
        globalConsoleInfo("☆☆☆☆mainbox.qml加载完毕☆☆☆☆");
        globalConsoleInfo("                                    ");
        globalConsoleInfo("                                    ");
        //传递获得焦点的页面元素
        idScopeView.focusPageOfrightControl=idRightPannel;

        Com.GlobalTotalchildArray=Com.resetGlobalItemOfElement(root);

    }
}
