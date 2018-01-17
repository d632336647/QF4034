import QtQuick 2.0
//import QtQuick.Particles 2.0
import "Inc.js" as Com
import "UI"
import "../SliChart"

Rectangle {
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
}
