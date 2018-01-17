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
    property bool fullMode: true    //全尺寸显示
    property bool realTimeMode: false   //实时刷新显示
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
            min: -12.5;
            max: 12.5;
            tickCount: Settings.channelMode() ? 11 : 6;
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
        MouseArea{
            property var mouseXLast
            property var mouseYLast
            property string scrollType_axisX: "axisX"
            property string scrollType_axisY: "axisY"
            property string scrollType_axisMain: "axisMain"
            property string scrollType_null: "null"
            property string scrollType

            anchors.fill: parent
            hoverEnabled: true
            enabled: true;//hoverEnable
            acceptedButtons: Qt.LeftButton
            onPressed: {
            }
            onPositionChanged: {
                var dataPoint = idChartView.mapToValue(Qt.point(mouseX, mouseY));
                if(dataPoint.x > idAxisX.min && dataPoint.x < idAxisX.max && dataPoint.y < idAxisY.min)
                    scrollType = scrollType_axisX;
                else if(dataPoint.x < idAxisX.min && dataPoint.y > idAxisY.min && dataPoint.y < idAxisY.max)
                    scrollType = scrollType_axisY;
                else if(dataPoint.x > idAxisX.min && dataPoint.x < idAxisX.max && dataPoint.y > idAxisY.min && dataPoint.y < idAxisY.max)
                    scrollType = scrollType_axisMain;
                else
                    scrollType = scrollType_null;
                mouseXLast = mouseX;
                mouseYLast = mouseY;
            }
            onWheel: {
                if(scrollType === scrollType_axisMain && realTimeMode === false)//实时模式由频谱图同步缩放
                {
                    if(wheel.angleDelta.y > 0)
                        zoomHorizontal(mouseX, mouseY, 0.5);
                    else
                        zoomHorizontal(mouseX, mouseY, 2);
                }
            }
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
        disabled: realTimeMode
        onClicked:
        {
            idAxisX.min = xAxisMin
            idAxisX.max = xAxisMax
            idAxisY.min = yAxisMin
            idAxisY.max = yAxisMax

            bottomLeft.x = idAxisX.min;
            topRight.x = idAxisX.max;
            bottomLeft.y = idAxisY.min
            topRight.y = idAxisY.max;

            checked = true
            waterfallPlot.zoomReset()
        }
    }
    //!--ctrl panel end
    WaterfallPlot{
        id: waterfallPlot
        anchors.fill: parent
        referMin: 80
        minHPixel: 10
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

    property point bottomLeft
    property point topRight
    property var maxBandwidth
    property var minBandwidth
    property var curBandwidth
    property var curRatio
    property point curDataPoint
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

        if(realTimeMode){
            idAxisX.min = cur_min
            idAxisX.max = cur_max
            waterfallPlot.setAxisXData(cur_min, cur_max, min, max)
        }
    }
    function updateCurData(mouseX, mouseY, scale)
    {
        var xyPoint = Qt.point(mouseX, mouseY);
        curDataPoint = idChartView.mapToValue(xyPoint);

        var band = idAxisX.max - idAxisX.min;
        curRatio = (curDataPoint.x - idAxisX.min) / band;
        curBandwidth = band * scale;
    }
    function zoomAxis(scale)
    {
        var band=parseInt((idAxisX.max - idAxisX.min) * 1000000);
        if(minBandwidth >= band)
        {
            if(minBandwidth > band)
                idAxisX.max = idAxisX.min + minBandwidth / 1000000.0;
            if(scale < 1)
                return;
        }

        if(idAxisX.min >= bottomLeft.x)
            idAxisX.min = curDataPoint.x - curBandwidth * curRatio;
        if(idAxisX.max <= topRight.x)
            idAxisX.max = idAxisX.min + curBandwidth;
        if(idAxisX.min < bottomLeft.x || idAxisX.max > topRight.x)
        {
            idAxisX.min = bottomLeft.x;
            idAxisX.max = topRight.x;
        }
        updateWaterfallPlotMargin();
    }
    function zoomHorizontal(mouseX, mouseY, scale){
        updateCurData(mouseX, mouseY, scale);
        zoomAxis(scale);
        var min=(idAxisX.min - bottomLeft.x) * 1000000.0 / maxBandwidth;
        var max=(idAxisX.max - bottomLeft.x) * 1000000.0 / maxBandwidth;
        var cur=(curDataPoint.x - bottomLeft.x) * 1000000.0 / maxBandwidth;
//        console.log(idAxisX.max, idAxisX.min, idAxisX.max - idAxisX.min, minBandwidth)
        waterfallPlot.zoomHorizontal(min, max, cur);
    }
    function updateWaterfallPlotMargin()
    {
        var xyPoint_min = idChartView.mapToPosition(Qt.point(idAxisX.min, idAxisY.min));
        var xyPoint_max = idChartView.mapToPosition(Qt.point(idAxisX.max, idAxisY.max));

        waterfallPlot.anchors.topMargin = xyPoint_max.y;
        waterfallPlot.anchors.rightMargin = root.width - xyPoint_max.x;
        waterfallPlot.anchors.bottomMargin = root.height - xyPoint_min.y;
        waterfallPlot.anchors.leftMargin = xyPoint_min.x;
    }
    function updateFile(file)
    {
        if(!visible)
            return;

        updateAxisX(idAxisX, centerFreq, bandwidth);
        minBandwidth =  (idAxisX.tickCount - 1) * resolution / 1.0;
        maxBandwidth = bandwidth * 1000000;



        dataSource.updateWaterfallPlotFromFile(root.chIndex, file);
        idAxisY.max = waterfallPlot.lineCount;
        //console.log("WaterfallPlot ch",root.chIndex,"updateFile lineCount:",idAxisY.max)

        bottomLeft.x = idAxisX.min;
        topRight.x   = idAxisX.max;
        bottomLeft.y = idAxisY.min
        topRight.y   = idAxisY.max;

        xAxisMin = idAxisX.min;
        xAxisMax = idAxisX.max;
        yAxisMin = idAxisY.min
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
        updateAxisX(idAxisX, centerFreq, bandwidth);
        minBandwidth =  (idAxisX.tickCount - 1) * resolution / 1.0;
        maxBandwidth = bandwidth * 1000000;

        //Rt mode = 50
        var max = 50
        if(max > 0)
            idAxisY.max = 50;

        bottomLeft.x = idAxisX.min;
        topRight.x   = idAxisX.max;
        bottomLeft.y = idAxisY.min
        topRight.y   = idAxisY.max;

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
        centerFreq = Settings.centerFreq()
        bandwidth  = Settings.bandWidth()
        resolution = Settings.resolutionSize()
        setAxisXPrecision()
        stopRtTimer()
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
