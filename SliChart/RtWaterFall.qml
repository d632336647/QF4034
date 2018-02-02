import QtQuick 2.0
import QtCharts 2.1
import QtQuick.Controls 1.4
import WaterfallPlot 1.0
import "../qml/UI"

import "../qml/Inc.js" as Com

Rectangle {
    id: root
    color: "black"
    anchors.right:parent.right
    property int  chIndex:  0       //通道索引
    property int  xAxisMax: 95      //MHz
    property int  xAxisMin: 45      //MHz
    property int  yAxisMax: 170     //dBm
    property int  yAxisMin: 70      //dBm
    property int  centerFreq: 70    //MHz
    property int  resolution: 10000 //Hz
    property int  bandwidth: 50     //MHz
    property int  xPrecision: 0     //小数精确的位数
    property int  yPrecision: 0
    property int  zoomStep: 1
    property string  zoomXY: "x"
    property bool openGL: true
    property bool fullMode: true    //全高显示
    property bool fullWide: false   //全宽显示
    property bool realTimeMode: false   //实时刷新显示
    property point centerPoint: Qt.point( 0, 0 )
    property string scrollTypeStr: ""
    property var  theScopeViewEle: undefined
    property var  noCheckbuttonEleArray:[] //存储非checkbutton元素
    property var  uiCheckButtonArray:[];//UiCheckButton按钮数组
    property int  uiSliderIndex:-1 //第一个UiSliderIndex出现的索引号
    property real  theMouseX: 0
    property real  theMouseY: 0
    UiCornerLine{
        anchors.top: parent.top
        anchors.topMargin: 4
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
    }

    Text {
        id: xTitle
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 44
        anchors.right: parent.right
        anchors.rightMargin: 20
        font.pixelSize: 12
        color:"white"
        font.family: "Calibri"
        text: qsTr("MHz")
    }
    Text {
        id: yTitle
        anchors.top: parent.top
        anchors.topMargin: 14
        anchors.left: parent.left
        anchors.leftMargin: 50
        font.pixelSize: 12
        color:"white"
        font.family: "Calibri"
        text: qsTr("0.1s")
    }

    ChartView {
        id: idChartView
        animationOptions: ChartView.NoAnimation
        backgroundColor: "#00000000"
        margins{left:fullMode?8:26}
        anchors.fill: parent
        legend{
            visible: false
        }

        ValueAxis {
            id: idAxisX;
            min: 45;
            max: 85;
            tickCount: fullWide ? 11 : 6;
            gridVisible: false
        }
        ValueAxis {
            id: idAxisY;
            min: 0;
            max: 100;
            tickCount: 11;
            labelFormat: fullMode?"%d":"%05d"
            gridVisible: false
            //alignment:Qt.AlignTop
            onMaxChanged: {
                //console.log("idAxisY.max", idAxisY.max)
                virAxisY.max = idAxisY.max
            }
        }
        UiVirAxisY{
            id:virAxisY
            anchors.top:parent.top
            anchors.topMargin: 30
            anchors.left: parent.left
            anchors.leftMargin: 8
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 44
            width: 58
            color: root.color
            //color: "red"
            //visible: false

        }

        LineSeries {
            id: lineSeries1
            axisX: idAxisX
            axisY: idAxisY
        }
    }//!-- ChartView end
    Timer{
        id:rtWfTimer
        interval: 1000;
        running: false
        repeat: true
        property var callback: undefined
        onTriggered: {
            if(callback != undefined)
                callback()
        }
    }

    //ctrl panel
    UiCheckButton{
        id:btnZoomReset
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80
        anchors.right: parent.right
        anchors.rightMargin: 10
        iconFontText:"\uf066"
        textColor: "#D3D4D4"
        mode:"button"
        checked: true
        tips:"复位显示瀑布图"
        disabled: true
        onClicked:
        {
            idAxisX.min = xAxisMin
            idAxisX.max = xAxisMax
            idAxisY.min = yAxisMin
            idAxisY.max = yAxisMax

            checked = true

        }
    }
    //!--ctrl panel end
    WaterfallPlot{
        id: waterfallPlot
        anchors.fill: parent
        referMin: 80
        channelIdx: chIndex
        source: dataSource
        onLineCountChanged: {
            //console.log("WaterfallPlot lineCount:",lineCount)
            //idAxisX.max = lineCount
        }
    }
    // Add data dynamically to the series
    Component.onCompleted: {


    }

    function setAxisXPrecision()
    {
        if(resolution>=100000){
            idAxisX.labelFormat = "%.1f"
            xPrecision = 1;
        }
        else if(resolution>=10000){
            idAxisX.labelFormat = "%.2f"
            xPrecision = 2;
        }
        else if(resolution>=1000){
            idAxisX.labelFormat = "%.3f"
            xPrecision = 3;
        }
        else if(resolution>=100){
            idAxisX.labelFormat = "%.4f"
            xPrecision = 4;
        }
        else if(resolution>=50){
            idAxisX.labelFormat = "%.5f"
            xPrecision = 5;
        }
    }
    function updateWaterfallPlotRef(min, max)
    {
        waterfallPlot.updateRefLebel(min, max)
    }
    function closeWTFRtData()
    {
        waterfallPlot.closeWaterfallRtCapture();
    }
    function openWTFRtData()
    {
        waterfallPlot.openWaterfallRtCapture()
    }
    function updateAxisX(axisX, centerFreq, bandwidth)
    {
        axisX.min = centerFreq - bandwidth/2;
        axisX.max = centerFreq + bandwidth/2;
        waterfallPlot.setAxisXData(axisX.min, axisX.max, axisX.min, axisX.max)
    }
    function updateAxisXRtShow(cur_min, cur_max, min, max)
    {
        //文件模式也使用同步放大缩小
        idAxisX.min = cur_min
        idAxisX.max = cur_max
        waterfallPlot.setAxisXData(cur_min, cur_max, min, max)

    }
    function updateWaterfallPlotMargin()
    {

        //var xyPoint_min = idChartView.mapToPosition(Qt.point(idAxisX.min, idAxisY.min));
        //var xyPoint_max = idChartView.mapToPosition(Qt.point(idAxisX.max, idAxisY.max));

        waterfallPlot.anchors.topMargin = 36
        waterfallPlot.anchors.rightMargin = 48
        waterfallPlot.anchors.bottomMargin = 50
        waterfallPlot.anchors.leftMargin = 74
    }
    function updateFile(file)
    {
        if(!visible)
            return;

        dataSource.updateWaterfallPlotFromFile(root.chIndex, file);
        idAxisY.max = waterfallPlot.lineCount;
        //console.log("WaterfallPlot ch",root.chIndex,"updateFile lineCount:",idAxisY.max)

        xAxisMin = idAxisX.min;
        xAxisMax = idAxisX.max;
        yAxisMin = idAxisY.min;
        yAxisMax = idAxisY.max;

        updateWaterfallPlotMargin();

        //waterfallPlot.zoomReset()

    }
    function updatData()
    {
        if(!visible)
            return;

        //dataSource.openWaterfallRtCapture(waterfallPlot)//deprecate
        waterfallPlot.openWaterfallRtCapture();

        //Rt mode = 50
        var max = 50
        if(max > 0)
            idAxisY.max = 50;

        xAxisMin = idAxisX.min;
        xAxisMax = idAxisX.max;
        yAxisMin = idAxisY.min
        yAxisMax = idAxisY.max;

        updateWaterfallPlotMargin();

        //waterfallPlot.zoomReset()

    }
    function startRtTimer()//较为安全的定时器临界处理方法,勿直接使用stop/start
    {
        if(!rtWfTimer.running){
            console.log("waterfall ch",chIndex,"start timer")
            rtWfTimer.callback = waterfallPlot.safeUpdate
            rtWfTimer.start()
        }
    }
    function stopRtTimer()
    {
        if(rtWfTimer.running){
            console.log("waterfall ch",chIndex,"stop  timer")
            rtWfTimer.callback = undefined
            rtWfTimer.stop()
        }
    }

    function updateParams()
    {
        console.log("RtWaterFall ch",chIndex,"updateParams")
        centerFreq = Settings.centerFreq(Com.OpGet, 0, chIndex)
        bandwidth  = Settings.bandWidth(Com.OpGet, 0, chIndex)
        var fftpoints = Settings.fftPoints(Com.OpGet, 0, chIndex);
        resolution = (bandwidth * 1000000)/fftpoints //Settings.resolutionSize()
        setAxisXPrecision()
        stopRtTimer()
        updateAxisX(idAxisX, centerFreq, bandwidth);
        waterfallPlot.setFileMode()

        if(realTimeMode){
            waterfallPlot.setRtMode()
            updatData()
            startRtTimer()
        }else{
            if(Settings.historyFile1().length>0)
                updateFile(Settings.historyFile1())
        }
    }
}
