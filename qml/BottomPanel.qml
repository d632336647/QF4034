import QtQuick 2.0
//import QtQuick.Particles 2.0
import "Inc.js" as Com
import "UI"
import "../SliChart"

Rectangle {
    id:root
    implicitWidth: 500
    implicitHeight: 70
    anchors.rightMargin: 4
    anchors.bottomMargin: 2
    anchors.leftMargin: 4
    color: Com.BottomBGColor
    property var captureMode:["即采即停","时长采集","大小采集","分段采集"]
    property var triggerMode:["外部触发","内部触发"]
    property var clkMode:["外时钟","内时钟","外参考"]
    property var saveMode:["本地存储","光纤存储"]
    property var workMode:["本地模式","远程模式"]
    property var stateRectArray :[]//底边按钮数组
    property var popBoxchildArray:[]; //弹出框子元素存储数组

    property var modeSwitch:undefined;//模式切换
    property var paramsUpdate:undefined;//参数更新
    property var menuBtn:undefined;//菜单显示
    Rectangle {
        anchors.fill: parent;
        color: Com.BottomBGColor;

        Grid{
            id: bottoms;
            columns: 6;
            spacing: 4;
            rowSpacing: 8
            StateRect{
                id:idCaptureRate
                textLabel:"采样率:"
                textData:Settings.captureRate()+" Msps"
            }
            StateRect{
                id:idCenterFreq
                textLabel:"中心频率:"
                textData:Settings.centerFreq()+" MHz"
            }
            StateRect{
                id:idBandWidth
                textLabel:"观测带宽:"
                textData:Settings.bandWidth()+" MHz"
            }
            StateRect{
                id:idFreqResolution
                textLabel:"分辨率:"
                textData:Settings.freqResolution()
            }
            StateRect{
                id:idMarkRange
                textLabel:"Mark幅度:"
                textData:Settings.markRange()
            }
            StateRect{
                objectName: "modeSwitch"  //模式切换
                id:idChannel1
                btnName:showMode(Settings.channelMode())
                onClicked: {
                    var mode = Settings.channelMode()
                    if(mode<2)
                        mode += 1
                    else
                        mode = 0;
                    showMode(mode)
                    Settings.channelMode(Com.OpSet, mode)
                    idScopeView.changeChannelMode(mode);
                }
                function showMode(mode)
                {
                    if(0 === mode)
                        btnName = "模式切换 双通道"
                    else if(1 === mode)
                        btnName = "模式切换 通道1"
                    else
                        btnName = "模式切换 通道2"
                    return btnName;
                }
            }
            StateRect{
                id:idClkMode
                textLabel:"时钟模式:"
                textData:clkMode[Settings.clkMode(2)]
            }
            StateRect{
                id:idTriggerMode
                textLabel:"触发模式:"
                textData:triggerMode[Settings.triggerMode()]
            }
            StateRect{
                id:idCaptureMode
                textLabel:"采集模式:"
                textData: captureMode[Settings.captureMode()]
            }
            StateRect{
                id:idSourceMode
                textLabel:"工作模式:"
                textData:workMode[Settings.sourceMode()]
            }
            StateRect{
                id:idSaveMode
                textLabel:"存储模式:"
                textData:saveMode[Settings.saveMode()]
                RoundLight{
                    id: saveAnimated;
                    visible: false
                    anchors.right: parent.right
                    anchors.rightMargin: 2
                    width: parent.height
                    color: "red"//"#56FF00"
                }
            }
            StateRect{
                objectName: "paramUpdate"
                id:idChannel2
                btnName:showName(Settings.paramsSetCh())
                onClicked: {
                    var ch = Settings.paramsSetCh();
                    ch = ch?0:1;
                    Settings.paramsSetCh(Com.OpSet, ch)
                    showName(ch)
                }
                function showName(ch)
                {
                    if(0 === ch)
                        btnName = "参数更新 通道1"
                    else
                        btnName = "参数更新 通道2"
                    return btnName;
                }
            }
        }
        StateRect{
            id:showMenu
            objectName: "menuBtn"
            width: 36
            height: 64
            anchors.right: parent.right
            btnName:"菜单"
            visible: (idRightPannel.state == "HIDE")
            onClicked:{
                idRightPannel.state = "SHOW"
                idRightPannel.focus = true
            }
        }
    }
    function updateParams()
    {
        idCaptureRate.textData = Settings.captureRate()+" Msps"
        idCaptureMode.textData = captureMode[Settings.captureMode()]
        idTriggerMode.textData = triggerMode[Settings.triggerMode()]
        idClkMode.textData     = clkMode[Settings.clkMode(2)]
        idCenterFreq.textData  = Settings.centerFreq()+" MHz"
        idBandWidth.textData   = Settings.bandWidth()+" MHz"
        //idMarkRange.textData = Settings.markRange()+" dBm"
        idMarkRange.textData   = "---- dBm"
        idFreqResolution.textData  = Settings.resolutionSize()+" Hz"//Settings.freqResolution()
        idSourceMode.textData  = workMode[Settings.sourceMode()]
        idSaveMode.textData    = "--------"
    }
    function updateMarkRange(enable, range)
    {
        if(enable)
            idMarkRange.textData   = range +" dBm"
        else
            idMarkRange.textData   = "---- dBm"
    }
    function setSaveState(state)
    {
        saveAnimated.visible = state;
        if(state)
            idSaveMode.textData = saveMode[Settings.saveMode()]
        else
            idSaveMode.textData = "--------"
    }


    //遍历BottomPannel元素
    function getStateRectOfFileList(popObj)
    {
        var atomlist=popObj.children;
        for ( var i in atomlist)
        {

            var tempstr=atomlist[i].toString();
            var eachChild=atomlist[i];
            var index=tempstr.indexOf("_");


            var StateRectindex=tempstr.indexOf("StateRect");

            var QQuickRectangleindex=tempstr.indexOf("Rectangle");

            var QQuickGridindex=tempstr.indexOf("QQuickGrid");
            if((QQuickRectangleindex!==-1)||(QQuickGridindex!==-1))
            {
                globalConsoleInfo("!!!!!递归调用getItemOfPopBox");
                getStateRectOfFileList(atomlist[i]);
            }
            if(StateRectindex!==-1)
            {
                stateRectArray.norepeatpush(atomlist[i]);
            }


        }


        return popBoxchildArray;
    }


    Component.onCompleted:
    {
        globalConsoleInfo("☆☆☆☆BottomPanel.qml加载完毕☆☆☆☆");
        getStateRectOfFileList(root);
        for(var tt=0;tt<stateRectArray.length;tt++)
        {

            if(stateRectArray[tt].objectName==="paramUpdate")
            {
                paramsUpdate=stateRectArray[tt];//参数更新
                globalConsoleInfo("======参数更新按钮已添加=======paramsUpdate=="+paramsUpdate);
            }
            else if(stateRectArray[tt].objectName==="modeSwitch")
            {
                modeSwitch=stateRectArray[tt];//模式切换
                globalConsoleInfo("======模式切换按钮已添加=======modeSwitch=="+modeSwitch);
            }
            else if(stateRectArray[tt].objectName==="menuBtn")
            {
                menuBtn=stateRectArray[tt];//菜单显示
                globalConsoleInfo("======菜单显示按钮已添加=======menuBtn=="+menuBtn);
            }
        }

    }
}
