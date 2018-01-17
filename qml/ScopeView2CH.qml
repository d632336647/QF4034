import QtQuick 2.0
import QtQuick.Controls 1.4
import "Inc.js" as Com
import "UI"
import "../SliChart"

Item{
    id:root
    property int analyzeMode: 0
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
                visible: waterfallView.visible
                width: parent.width
                height: parent.height * 0.5
                anchors.top: spectrumView2.bottom
                anchors.right: parent.right
            }
        }

        TiDomainWave{
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
        changeAnalyzeMode()
    }
    function changeLayout(mod)//analyzeMode
    {
        if(0 === mod){
            if(channel1.visible && channel2.visible){
                channel1.width  = waveTable.width
                channel1.height = waveTable.height / 2
                spectrumView.fullWide = true
                spectrumView.yTicks  = 11

                channel2.width  = waveTable.width
                channel2.height = waveTable.height / 2
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
            channel1.width  = channel2.visible ? waveTable.width/2 : waveTable.width
            channel1.height = waveTable.height
            spectrumView.fullWide  = !channel2.visible
            spectrumView.yTicks    = spectrumView.fullMode ? 21 : 11

            channel2.width  = channel1.visible ? waveTable.width/2 : waveTable.width
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
        changeLayout(analyzeMode)
    }
    function changeAnalyzeMode()
    {
        var preMode = analyzeMode

        analyzeMode = Settings.analyzeMode()

        console.log("changeAnalyzeMode", analyzeMode)

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
    }

    function updateSepctrumAxisY(min, max)
    {
        var ch = Settings.paramsSetCh();
        console.log("updateSepctrumAxisY min",min,"max",max, "ch", ch)
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

}
