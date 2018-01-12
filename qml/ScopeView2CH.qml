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

        captureThread.stopCapture()
        dataSource.stopSample()
        dataSource.closeWaterfallRtCapture()

        spectrumView.fullMode     = spectrumView2.fullMode     = true
        spectrumView.visible      = spectrumView2.visible      = false
        spectrumView.realTimeMode = spectrumView2.realTimeMode = false
        waterfallView.visible     = waterfallView2.visible     = false
        waterfallView.realTimeMode= waterfallView2.realTimeMode= false

        //ch1
        waterfallView.stopRtTimer()
        spectrumView.setCaptureSeries()
        spectrumView.closePeakMark()

        //ch2
        waterfallView2.stopRtTimer()
        spectrumView2.setCaptureSeries()
        spectrumView2.closePeakMark()

        timeDomainWave.visible    = false

        if(analyzeMode === 0)   //实时频谱
        {
            //ch1
            spectrumView.visible      = true
            spectrumView.realTimeMode = true
            spectrumView.updateParams()
            dataSource.startSample()

            //ch2
            spectrumView2.visible      = true
            spectrumView2.realTimeMode = true
            spectrumView2.updateParams()
            dataSource.startSample()

        }
        else if(analyzeMode === 1)   //实时瀑布图
        {
            //ch1
            spectrumView.fullMode     = false
            spectrumView.visible      = true
            spectrumView.realTimeMode = true

            waterfallView.visible     = true
            waterfallView.realTimeMode= true

            spectrumView.updateParams()
            waterfallView.updateParams()
            dataSource.startSample()

            //ch2
            spectrumView2.fullMode     = false
            spectrumView2.visible      = true
            spectrumView2.realTimeMode = true

            waterfallView2.visible     = true
            waterfallView2.realTimeMode= true

            spectrumView2.updateParams()
            waterfallView2.updateParams()
            dataSource.startSample()
        }
        else if(analyzeMode === 2)  //历史文件频谱对比分析
        {
            spectrumView.visible = true
            spectrumView.updateParams()
        }
        else if(analyzeMode === 3)  //历史文件瀑布图分析
        {
            spectrumView.fullMode = false
            spectrumView.visible = true
            spectrumView.updateParams()

            waterfallView.visible = true
            waterfallView.updateParams()
        }
        else if(analyzeMode === 4)  //历史文件时域波形
        {
            timeDomainWave.visible    = true
            timeDomainWave.updateParams()
        }
        changeChannelMode(Settings.channelMode())
    }
    function updateSepctrumAxisY(min, max)
    {
        if(parseFloat(min)<-140)
            min = -140
        if(parseFloat(max)>40)
            max = 40
        if(parseFloat(max) < parseFloat(min))
            return
        //console.log("updateSepctrumAxisY",max, min)
        spectrumView.setAxisYRange(min, max)
        waterfallView.updateWaterfallPlotRef(min, max)
        waterfallView.updateParams()
    }
    Component.onCompleted: {
       //由外部初始化
    }
}
