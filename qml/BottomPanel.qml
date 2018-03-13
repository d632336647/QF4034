import QtQuick 2.0
//import QtQuick.Particles 2.0
import "Inc.js" as Com
import "Lib.js" as Lib
import "UI"
import "../SliChart"

Rectangle {
    id:root
    implicitWidth: 500
    implicitHeight: 70
    anchors.rightMargin: 4
    anchors.bottomMargin: 2
    anchors.leftMargin: 4
    color: Com.bottomBGColor
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
        color: Com.bottomBGColor;

        Grid{
            id: bottoms;
            columns: Com.columnsval
            spacing: 3;
            rowSpacing: 0
            /**********************显示栏实现表**********************/
            StateRect{
                id:idCaptureRate
                textLabel:"采样率:"
                textData:Settings.captureRate()+" Msps"
            }
            StateRect{
                visible: Com.channel1Visible
                id:idCenterFreq
                textLabel:"中心频率:"
                textData:Settings.centerFreq()+" MHz"
            }
            StateRect{
                visible: Com.channel1Visible
                id:idBandWidth
                textLabel:"观测带宽:"
                textData:Settings.bandWidth()+" MHz"
            }
            StateRect{
                visible: Com.channel1Visible
                id:idFreqResolution
                textLabel:"FFT点数:"
                //textData:Settings.freqResolution()
                textData:Settings.fftPoints()
            }
            StateRect{
                visible: Com.channel1Visible
                id:idExtractFactor
                textLabel:"抽取因子:"
                textData:Settings.extractFactor()
            }
            StateRect{
                visible: Com.channel1Visible
                id:idDDCFreq
                textLabel:"DDC频率:"
                textData:Settings.ddcFreq()
            }
            StateRect{
                visible: Com.channel1Visible
                id:idClkMode
                textLabel:"时钟模式:"
                textData:clkMode[Settings.clkMode(2)]
            }
            StateRect{
                visible: Com.channel1Visible
                id:idTriggerMode
                textLabel:"触发模式:"
                textData:triggerMode[Settings.triggerMode()]
            }
            StateRect{
                visible: Com.channel1Visible
                id:idCaptureMode
                textLabel:"采集模式:"
                textData: captureMode[Settings.captureMode()]
            }
            StateRect{
                visible: Com.channel2Visible
                id:idSourceMode
                textLabel:"工作模式:"
                textData:workMode[Settings.sourceMode()]
            }
            StateRect{
                visible: Com.channel2Visible
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
                visible: Com.channel2Visible
                id:idbak1
                textLabel:"---备用---"
                //textData:Settings.xxx
            }
            StateRect{
                visible: Com.channel2Visible
                id:idbak2
                textLabel:"---备用---"
                //textData:Settings.xxx
            }
            StateRect{
                visible: Com.channel2Visible
                id:idbak3
                textLabel:"---备用---"
                //textData:Settings.xxx
            }
            StateRect{
                visible: Com.channel2Visible
                id:idbak4
                textLabel:"---备用---"
                //textData:Settings.xxx
            }
            StateRect{
                visible: Com.channel2Visible
                id:idbak5
                textLabel:"---备用---"
                //textData:Settings.xxx
            }
            StateRect{
                visible: Com.channel2Visible
                id:idbak6
                textLabel:"---备用---"
                //textData:Settings.xxx
            }StateRect{
                visible: Com.channel2Visible
                id:idbak7
                textLabel:"---备用---"
                //textData:Settings.xxx
            }

            /*****************END--显示栏实现表**********************/
            StateRect{
                objectName: "modeSwitch"  //模式切换
                id:idChannel1
                visible: false
                btnName:showMode(Settings.channelMode())
                onClicked: {
                    var mode = Settings.channelMode()
                    if(mode<2)
                    {
                        Settings.paramsSetCh(Com.OpSet, mode)
                        mode += 1
                    }
                    else
                    {
                        mode = 0;
                        Settings.paramsSetCh(Com.OpSet, 0)
                    }
                    showMode(mode)
                    Settings.channelMode(Com.OpSet, mode)
                    idScopeView.changeChannelMode(mode);
                    idScopeView.svSetActiveChannel()
                    updateParams()      //更新
                    //console.log("idCaptureRate:"+idCaptureRate.visible.toString()+"columnsval:"+Com.columnsval+" channel1Visible:"+Com.channel1Visible+" channel2Visible:"+Com.channel2Visible)
                }
                function showMode(mode)
                {
                    if(0 === mode)
                    {
                        btnName = "模式切换 双通道"
                        //dhy  切换模式同时切换通道 切回双 默认1
                        var ch = 0
                        Settings.paramsSetCh(Com.OpSet, ch);
                        idChannel2.showName(ch)
                        Com.columnsval =6
                        Com.channel1Visible =true;
                        Com.channel2Visible =true;
                        idCaptureRate.visible = true;
                        updateColumnsval()
                    }
                    else if(1 === mode)
                    {
                        btnName = "模式切换 通道1"
                        //dhy  切换模式同时切换通道
                        var ch = 0
                        Settings.paramsSetCh(Com.OpSet, ch);
                        idChannel2.showName(ch)
                        Com.columnsval =3
                        Com.channel1Visible =true;
                        Com.channel2Visible =false;
                        idCaptureRate.visible = true;
                        updateColumnsval()
                    }
                    else
                    {
                        btnName = "模式切换 通道2"
                        //dhy  切换模式同时切换通道
                        var ch = 1
                        Settings.paramsSetCh(Com.OpSet, ch);
                        idChannel2.showName(ch)
                        Com.columnsval =3;
                        Com.channel1Visible =false;
                        Com.channel2Visible =true;
                        idCaptureRate.visible = false;
                        updateColumnsval()
                    }
                    return btnName;
                }

            }
            StateRect{
                objectName: "paramUpdate"
                visible: false
                id:idChannel2
                btnName:showName(Settings.paramsSetCh())
                onClicked: {
                    if(Settings.channelMode() === 0)    //dhy 增加判断是否为双通道
                    {
                        var ch = Settings.paramsSetCh();
                        ch = ch?0:1;
                        Settings.paramsSetCh(Com.OpSet, ch);
                        idScopeView.svSetActiveChannel()
                        showName(ch);
                        updateParams();
                    }
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
            visible: false
            objectName: "menuBtn"
            width: 36
            height: 64
            anchors.right: parent.right
            btnName:"菜单"
            onClicked:{
                idRightPannel.focus=true;
                if(idRightPannel.state==="SHOW")
                {
                    idRightPannel.state="HIDE";
                }else{
                    idRightPannel.state="SHOW";
                }
            }
        }
    }
    //dhy 备份
//    function updateParams()
//    {
//        idCaptureRate.textData = Settings.captureRate()+" Msps"
//        idCaptureMode.textData = captureMode[Settings.captureMode()]
//        idTriggerMode.textData = triggerMode[Settings.triggerMode()]
//        idClkMode.textData     = clkMode[Settings.clkMode(2)]
//        idCenterFreq.textData  = Settings.centerFreq()+" MHz"
//        idBandWidth.textData   = Settings.bandWidth()+" MHz"
//        //idExtractFactor.textData = Settings.markRange()+" dBm"
//        idExtractFactor.textData   = "---- dBm"
//        idFreqResolution.textData  = Settings.resolutionSize()+" Hz"//Settings.freqResolution()
//        idSourceMode.textData  = workMode[Settings.sourceMode()]
//        idSaveMode.textData    = "--------"
//    }

    function updateParams()
    {
        if(Settings.channelMode() === 0)             //双通道
        {
            if(Settings.paramsSetCh() === 0)         //双通道 下 备用区分通道1
            {
                idCaptureRate.textData = Settings.captureRate()+"/"+Settings.captureRate()+" Msps"
                idCenterFreq.textData  = Settings.centerFreq(Com.OpGet, 0, 0)+"/"+Settings.centerFreq(Com.OpGet, 0, 1)+" MHz"
                idBandWidth.textData   = Settings.bandWidth(Com.OpGet, 0, 0)+"/"+Settings.bandWidth(Com.OpGet, 0, 1)+" MHz"
                idFreqResolution.textData  = Settings.fftPoints(Com.OpGet, 0, 0)+"/"+Settings.fftPoints(Com.OpGet, 0, 1)+" Hz"
                idExtractFactor.textData   = Settings.extractFactor(Com.OpGet, 0)+"/"+Settings.extractFactor(Com.OpGet, 0)
                idDDCFreq.textData = Settings.ddcFreq(Com.OpGet, 0)+"/"+Settings.ddcFreq(Com.OpGet, 0)+" MHz"
                //idCaptureRate.textData = "<h2><font color =red>1</font></h2>"+" Msps"
            }
            else                                      //双通道 下 备用区分通道2
            {
                idCaptureRate.textData = "2"+" Msps"
                idCenterFreq.textData  = Settings.centerFreq(Com.OpGet, 0, 0)+"/"+Settings.centerFreq(Com.OpGet, 0, 1)+" MHz"
                idBandWidth.textData   = Settings.bandWidth(Com.OpGet, 0, 0)+"/"+Settings.bandWidth(Com.OpGet, 0, 1)+" MHz"
                idFreqResolution.textData  = Settings.fftPoints(Com.OpGet, 0, 0)+"/"+Settings.fftPoints(Com.OpGet, 0, 1)+" Hz"
                idExtractFactor.textData   = Settings.extractFactor(Com.OpGet, 0)+"/"+Settings.extractFactor(Com.OpGet, 0)
                idDDCFreq.textData = Settings.ddcFreq(Com.OpGet, 0)+"/"+Settings.ddcFreq(Com.OpGet, 0)+" MHz"
            }
        }
        else if(Settings.channelMode() === 1)        //通道1
        {
            idCaptureRate.textData = Settings.captureRate()+" Msps"
            idCenterFreq.textData  = Settings.centerFreq(Com.OpGet, 0, 0)+" MHz"
            idBandWidth.textData   = Settings.bandWidth(Com.OpGet, 0, 0)+" MHz"
            idFreqResolution.textData  = Settings.fftPoints(Com.OpGet, 0, 0)+" Hz"
            idExtractFactor.textData   = Settings.extractFactor(Com.OpGet, 0)
            idDDCFreq.textData = Settings.ddcFreq(Com.OpGet, 0)+" MHz"
        }
        else                                         //通道2
        {
            idCaptureRate.textData = Settings.captureRate()+" Msps"
            idCenterFreq.textData  = Settings.centerFreq(Com.OpGet, 0, 1)+" MHz"
            idBandWidth.textData   = Settings.bandWidth(Com.OpGet, 0, 1)+" MHz"
            idFreqResolution.textData  = Settings.fftPoints(Com.OpGet, 0, 1)+" Hz"
            idExtractFactor.textData   = Settings.extractFactor(Com.OpGet, 0)
            idDDCFreq.textData = Settings.ddcFreq(Com.OpGet, 0)+" MHz"
        }
        idCaptureMode.textData = captureMode[Settings.captureMode()]/*+"/"+captureMode[Settings.captureMode()]*/
        idTriggerMode.textData = triggerMode[Settings.triggerMode()]/*+"/"+triggerMode[Settings.triggerMode()]*/
        idClkMode.textData     = clkMode[Settings.clkMode(2)]/*+"/"+clkMode[Settings.clkMode(2)]*/
        idSourceMode.textData  = workMode[Settings.sourceMode()]/*+"/"+workMode[Settings.sourceMode()]*/
        idSaveMode.textData    = "--------"
    }

//    function updateMarkRange(enable, range)
//    {
//        if(enable)
//          idExtractFactorge.textData   = range +" dBm"
//        else
//          idExtractFactorge.textData   = "---- dBm"
//    }
    function chanegParamSetCh()
    {
        idChannel2.clicked()
    }
    function chanegSignalCh()
    {
        idChannel1.clicked()
    }
    function setSaveState(state)
    {
        saveAnimated.visible = state;
        if(state)
            idSaveMode.textData = saveMode[Settings.saveMode()]
        else
            idSaveMode.textData = "--------"
    }
    Component.onCompleted:
    {

    }
    function updateColumnsval()
    {
        //修改显示列数
        bottoms.columns =  Com.columnsval
        //接下来是对应通道修改每个显示框的 显示状态以及宽度
        var showitemvhannel1 = [
                        idCaptureRate,idCenterFreq,idBandWidth,
                        idFreqResolution,idExtractFactor,idDDCFreq,
                        idClkMode,idTriggerMode,idCaptureMode
                       ]
        var showitemvhannel2 = [
                        idSourceMode,idSaveMode,idbak1,idbak2,idbak3,
                        idbak4,idbak5,idbak6,idbak7
                       ]
        Lib.updateBottomShow(showitemvhannel1,showitemvhannel2,Com.columnsval,Com.channel1Visible,Com.channel2Visible);
    }
}
