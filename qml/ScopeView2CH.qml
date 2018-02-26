import QtQuick 2.0
import QtQuick.Controls 1.4
import "Inc.js" as Com
import "UI"
import "../SliChart"

Item{
    id:root
    property int analyzeMode: 0
    property var pointerSpectrumCh1: spectrumView
    property var pointerSpectrumCh2: spectrumView2
    property var pointerTiDomainWave: timeDomainWave
    property var pointerRightPannel:idRightPannel
    Item{
        id: waveTable
        anchors.fill: parent

        Item{
            id:channel1
            width: channel2.visible ? parent.width/2 : parent.width
            height: parent.height
            anchors.top: parent.top
            anchors.left: parent.left
            RtSpectrum{
                id: spectrumView
                chIndex:0
                fullMode: true
                fullWide: !channel2.visible
                width: parent.width
                height: fullMode ? parent.height : parent.height*0.5
                anchors.top: parent.top
                //anchors.right: fullMode ? parent.right : waterfallView.left
                anchors.left:  parent.left
            }
            RtWaterFall{
                id: waterfallView
                chIndex:0
                fullMode: false
                fullWide: spectrumView.fullWide
                visible: false
                width: parent.width
                height: parent.height * 0.5
                anchors.top: spectrumView.bottom
                anchors.left: parent.left
            }
        }

        Item{
            id:channel2
            width: channel1.visible ? parent.width/2 : parent.width
            height: parent.height
            anchors.top: parent.top
            anchors.right: parent.right
            RtSpectrum{
                id: spectrumView2
                chIndex:1
                fullMode: spectrumView.fullMode
                fullWide: !channel1.visible
                width: parent.width
                height: fullMode ? parent.height : parent.height*0.5
                anchors.top: parent.top
                anchors.right:  parent.right
                visible: spectrumView.visible
            }
            RtWaterFall{
                id: waterfallView2
                chIndex:1
                fullMode: waterfallView.fullMode
                fullWide: spectrumView2.fullWide
                visible: waterfallView.visible
                width: parent.width
                height: parent.height * 0.5
                anchors.top: spectrumView2.bottom
                anchors.right: parent.right
            }
        }

        TiDomainWave {
            id:timeDomainWave
            fullMode: true
            anchors.fill: parent
        }
    }
    
    Component.onCompleted: {
        var ymin_ch0 = Settings.reflevelMin(Com.OpGet, 0, 0);
        var ymax_ch0 = Settings.reflevelMax(Com.OpGet, 0, 0);
        var ymin_ch1 = Settings.reflevelMin(Com.OpGet, 0, 1);
        var ymax_ch1 = Settings.reflevelMax(Com.OpGet, 0, 1);
        spectrumView.setAxisYRange(ymin_ch0,  ymax_ch0)
        spectrumView2.setAxisYRange(ymin_ch1, ymax_ch1)
        waterfallView.updateWaterfallPlotRef(ymin_ch0,  ymax_ch0)
        waterfallView2.updateWaterfallPlotRef(ymin_ch1, ymax_ch1)
        changeAnalyzeMode();
        
    }
    function changeLayout(mod)//analyzeMode
    {
        if(0 === mod){
            if(channel1.visible && channel2.visible){
                channel1.width  = waveTable.width
                channel1.height = parseInt(waveTable.height / 2)
                spectrumView.fullWide = true
                spectrumView.yTicks  = 11

                channel2.width  = waveTable.width
                channel2.height = parseInt(waveTable.height / 2)
                channel2.anchors.top = channel1.bottom
                spectrumView2.fullWide = true
                spectrumView2.yTicks  = 11
            }
            else if(channel1.visible)
            {
                channel1.width  = waveTable.width
                channel1.height = waveTable.height
                spectrumView.fullWide = true
                spectrumView.yTicks  = 21
            }
            else if(channel2.visible)
            {
                channel2.width  = waveTable.width
                channel2.height = waveTable.height
                channel2.anchors.top = waveTable.top
                spectrumView2.fullWide = true
                spectrumView2.yTicks  = 21
            }

        }
        else{
            channel1.width  = channel2.visible ? parseInt(waveTable.width/2) : waveTable.width
            channel1.height = waveTable.height
            spectrumView.fullWide  = !channel2.visible
            spectrumView.yTicks    = spectrumView.fullMode ? 21 : 11

            channel2.width  = channel1.visible ? parseInt(waveTable.width/2) : waveTable.width
            channel2.height = waveTable.height
            channel2.anchors.top = waveTable.top
            spectrumView2.fullWide = !channel1.visible
            spectrumView2.yTicks   = spectrumView2.fullMode ? 21 : 11
        }
    }

    function changeChannelMode(mod)
    {
        var analyzeMode = Settings.analyzeMode()
        if(analyzeMode < 2)
        {
            switch(mod)
            {
            case 0:
                channel1.visible = true
                channel2.visible = true
                break;
            case 1:
                channel1.visible = true
                channel2.visible = false
                break;
            case 2:
                channel1.visible = false
                channel2.visible = true
                break;
            default:
                break;
            }
        }
        else
        {
            channel1.visible = true
            channel2.visible = false
        }
        changeLayout(analyzeMode);
    }
    
    //获取peakbtn元素
    function getPeakAndmarkEle()
    {


    }
    function changeAnalyzeMode()
    {
        var preMode = analyzeMode

        analyzeMode = Settings.analyzeMode()

        //console.log("changeAnalyzeMode", analyzeMode)

        captureThread.stopCapture()
        dataSource.stopSample()
        waterfallView.closeWTFRtData()
        waterfallView2.closeWTFRtData()

        spectrumView.fullMode     = spectrumView2.fullMode     = true
        spectrumView.visible      = spectrumView2.visible      = false
        spectrumView.realTimeMode = spectrumView2.realTimeMode = false
        waterfallView.visible     = waterfallView2.visible     = false
        waterfallView.realTimeMode= waterfallView2.realTimeMode= false

        //ch1
        waterfallView.stopRtTimer()
        spectrumView.closePeakMark()

        //ch2
        waterfallView2.stopRtTimer()
        spectrumView2.closePeakMark()

        timeDomainWave.visible    = false

        if(analyzeMode === 0)   //实时频谱
        {
            //ch1
            spectrumView.visible      = true
            spectrumView.realTimeMode = true

            //ch2
            spectrumView2.visible      = true
            spectrumView2.realTimeMode = true

            changeChannelMode(Settings.channelMode())

            spectrumView.updateParams()
            spectrumView2.updateParams()

            dataSource.startSample()
            captureThread.startCapture()
        }
        else if(analyzeMode === 1)   //实时瀑布图
        {
            //ch1
            spectrumView.fullMode     = false
            spectrumView.visible      = true
            spectrumView.realTimeMode = true

            waterfallView.visible     = true
            waterfallView.realTimeMode= true

            //ch2
            spectrumView2.fullMode     = false
            spectrumView2.visible      = true
            spectrumView2.realTimeMode = true

            waterfallView2.visible     = true
            waterfallView2.realTimeMode= true

            changeChannelMode(Settings.channelMode())

            spectrumView.updateParams()
            waterfallView.updateParams()
            spectrumView2.updateParams()
            waterfallView2.updateParams()

            dataSource.startSample()
            //dataSource.openWaterfallRtCapture(waterfallPlot) //deprecate
            captureThread.startCapture()
        }
        else if(analyzeMode === 2)  //历史文件频谱对比分析
        {
            spectrumView.visible = true

            changeChannelMode(Settings.channelMode())
            spectrumView.updateParams()
        }
        else if(analyzeMode === 3)  //历史文件瀑布图分析
        {
            spectrumView.fullMode = false
            spectrumView.visible = true
            waterfallView.visible = true

            changeChannelMode(Settings.channelMode())
            spectrumView.updateParams()
            waterfallView.updateParams()
        }
        else if(analyzeMode === 4)  //历史文件时域波形
        {
            timeDomainWave.visible    = true

            changeChannelMode(Settings.channelMode())
            timeDomainWave.updateParams()
        }
        //关闭所有控制按钮状态
        svCloseAllOpBtn()
        svSetActiveChannel()
    }

    function updateSepctrumAxisY(min, max)
    {
        var ch = Settings.paramsSetCh();
        //console.log("updateSepctrumAxisY min",min,"max",max, "ch", ch)
        if(parseFloat(min)<-140)
            min = -140
        if(parseFloat(max)>40)
            max = 40
        if(parseFloat(max) < parseFloat(min))
            return
        if(ch === 0){
            spectrumView.setAxisYRange(min, max)
            waterfallView.updateWaterfallPlotRef(min, max)
            waterfallView.updateParams()
        }else{
            spectrumView2.setAxisYRange(min, max)
            waterfallView2.updateWaterfallPlotRef(min, max)
            waterfallView2.updateParams()
        }
    }


    /**********************************************************
    以下函数为对外操作接口,直接调用即可,可视需求自由修改
    原则:接口函数在本级禁止互相调用， 由上层使用者互相调用
    注意:不同的分析模式，函数有不同的表现方式
    统一返回值定义:true 调用成功  false:调用无效, 只要有一路调用成功即返回true
    ***********************************************************/
    function svSetXSpan(en)
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        if(4 == analyzeMode){
            return timeDomainWave.tiSetXSpan(cur_ch, en)
        }
        var rtn1 = spectrumView.setXSpan(cur_ch, en)
        var rtn2 = spectrumView2.setXSpan(cur_ch, en)
        return (rtn1||rtn2)
    }
    function svSetYSpan(en)
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        if(4 == analyzeMode){
            return timeDomainWave.tiSetYSpan(cur_ch, en)
        }
        var rtn1 = spectrumView.setYSpan(cur_ch, en)
        var rtn2 = spectrumView2.setYSpan(cur_ch, en)
        return (rtn1||rtn2)
    }
    function svSetZoomIn()
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        if(4 == analyzeMode){
            return timeDomainWave.tiSetZoomIn(cur_ch)
        }
        var rtn1 = spectrumView.setZoomIn(cur_ch)
        var rtn2 = spectrumView2.setZoomIn(cur_ch)
        return (rtn1||rtn2)
    }
    function svSetZoomOut()
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        if(4 == analyzeMode){
            return timeDomainWave.tiSetZoomOut(cur_ch)
        }
        var rtn1 = spectrumView.setZoomOut(cur_ch)
        var rtn2 = spectrumView2.setZoomOut(cur_ch)
        return (rtn1||rtn2)
    }
    function svSetDragMove(direction)
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        if(4 == analyzeMode){
            return timeDomainWave.tiSetDragMove(cur_ch, direction)
        }
        var rtn1 = spectrumView.setDragMove(cur_ch, direction)
        var rtn2 = spectrumView2.setDragMove(cur_ch, direction)
        return (rtn1||rtn2)
    }
    function svSetShowPeak()
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        var rtn1 = spectrumView.setShowPeak(cur_ch)
        var rtn2 = spectrumView2.setShowPeak(cur_ch)
        return (rtn1||rtn2)
    }
    function svSetShowMark()
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        var rtn1 = spectrumView.setShowMark(cur_ch)
        var rtn2 = spectrumView2.setShowMark(cur_ch)
        return (rtn1||rtn2)
    }
    function svSetClosePeak()
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        var rtn1 = spectrumView.setClosePeak(cur_ch)
        var rtn2 = spectrumView2.setClosePeak(cur_ch)
        return (rtn1||rtn2)
    }
    function svSetCloseMark()
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        var rtn1 = spectrumView.setCloseMark(cur_ch)
        var rtn2 = spectrumView2.setCloseMark(cur_ch)
        return (rtn1||rtn2)
    }
    function svSetMoveMark(direction)
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        var rtn1 = spectrumView.setMoveMark(cur_ch, direction)
        var rtn2 = spectrumView2.setMoveMark(cur_ch, direction)
        return (rtn1||rtn2)
    }
    function svSetSwitchFile()
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        if(4 == analyzeMode){
            return timeDomainWave.tiSetSwitchFile(cur_ch)
        }
        var rtn1 = spectrumView.setSwitchFile(cur_ch)
        var rtn2 = spectrumView2.setSwitchFile(cur_ch)
        return (rtn1||rtn2)
    }
    function svSetSwitchFileEnable(en)
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        if(4 == analyzeMode){
            return timeDomainWave.tiSetSwitchFileEnable(cur_ch, en)
        }
        var rtn1 = spectrumView.setSwitchFileEnable(cur_ch, en)
        var rtn2 = spectrumView2.setSwitchFileEnable(cur_ch, en)
        return (rtn1||rtn2)
    }
    function svSetActiveFile(en)
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        if(4 == analyzeMode){
            return timeDomainWave.tiSetActiveFile(cur_ch, en)
        }
        var rtn1 = spectrumView.setActiveFile(cur_ch, en)
        var rtn2 = spectrumView2.setActiveFile(cur_ch, en)
        return (rtn1||rtn2)
    }
    function svSetMoveFile(direction)
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        if(4 == analyzeMode){
            return timeDomainWave.tiSetMoveFile(cur_ch, direction)
        }
        var rtn1 = spectrumView.setMoveFile(cur_ch, direction)
        var rtn2 = spectrumView2.setMoveFile(cur_ch, direction)
        return (rtn1||rtn2)
    }
    function svSetActiveChannel()
    {
        var cur_ch = Settings.paramsSetCh()
        cur_ch = (analyzeMode > 1) ? 0 : cur_ch
        var rtn1 = spectrumView.setActiveChannel(cur_ch)
        var rtn2 = spectrumView2.setActiveChannel(cur_ch)
        return (rtn1||rtn2)
    }
    function svSetChartReset()
    {
        if(4 == analyzeMode){
            return timeDomainWave.tiSetZoomReset(0)
        }
        var rtn1 = spectrumView.setChartReset(0)
        var rtn2 = spectrumView2.setChartReset(1)
        return (rtn1||rtn2)
    }
    function svSetSingleSweep(isSweep)
    {
        if(analyzeMode > 1){
            return false
        }
        var rtn1 = spectrumView.setSingleSweep(0, isSweep)
        var rtn2 = spectrumView2.setSingleSweep(1, isSweep)
        return (rtn1||rtn2)
    }
    function svCloseAllOpBtn()
    {
        var btnArry = [spectrumView, spectrumView2]
        for(var i = 0; i<2; i++){
            btnArry[i].setXSpan(i, false)
            btnArry[i].setYSpan(i, false)
            btnArry[i].setActiveFile(i, false)
            btnArry[i].setSwitchFileEnable(i, false)
        }
        if(4 == analyzeMode){
            timeDomainWave.tiSetXSpan(0,false)
            timeDomainWave.tiSetYSpan(0,false)
            timeDomainWave.tiSetActiveFile(0, false)
            timeDomainWave.tiSetSwitchFileEnable(0, false)
        }
    }
}
