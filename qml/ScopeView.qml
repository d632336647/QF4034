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
        RtSpectrum{
            id: spectrumView
            fullMode: true
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: fullMode ? parent.bottom : waterfallView.top
            anchors.bottomMargin: 0
            anchors.left: parent.left
        }
        RtWaterFall{
            id: waterfallView
            fullMode: false
            visible: false
            height: parent.height/2
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.left: parent.left
        }
        TiDomainWave{
            id:timeDomainWave
            fullMode: true
            anchors.fill: parent
        }

    }
    function changeAnalyzeMode()
    {
        var preMode = analyzeMode
        analyzeMode = Settings.analyzeMode()
        captureThread.stopCapture()
        dataSource.stopSample()
        dataSource.closeWaterfallRtCapture()

        spectrumView.fullMode     = true
        spectrumView.visible      = false
        spectrumView.realTimeMode = false
        waterfallView.visible     = false
        waterfallView.realTimeMode= false

        timeDomainWave.visible    = false


        waterfallView.stopRtTimer()
        spectrumView.setCaptureSeries()

        //if(preMode !=  analyzeMode)
        spectrumView.closePeakMark()
        if(analyzeMode === 0)   //实时频谱
        {

            spectrumView.visible      = true
            spectrumView.realTimeMode = true
            spectrumView.updateParams()
            dataSource.startSample()
        }
        else if(analyzeMode === 1)   //实时瀑布图
        {
            spectrumView.fullMode     = false
            spectrumView.visible      = true
            spectrumView.realTimeMode = true

            waterfallView.visible     = true
            waterfallView.realTimeMode= true

            spectrumView.updateParams()
            waterfallView.updateParams()
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
        else
        {

        }
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
