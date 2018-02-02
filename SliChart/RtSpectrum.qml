import QtQuick 2.0
import QtCharts 2.1
import QtQuick.Controls 2.2

import "../qml/UI"

import "../qml/Inc.js" as Com
import SpectrumData 1.0

Rectangle {
    id: root
    color: "black"
    property int   chIndex:  0       //通道索引
    property real  xAxisMax: 95      //MHz
    property real  xAxisMin: 45      //MHz
    property real  yAxisMax: 10      //dBm
    property real  yAxisMin: -100    //dBm
    property real  centerFreq: 70    //MHz
    property int   resolution: 10000 //Hz
    property real  bandwidth: 50     //MHz
    property int   xPrecision: 0     //小数精确的位数
    property int   yPrecision: 0
    property real  zoomXStep: 1.0
    property real  zoomYStep: 1.0
    property string  zoomXY: "x"
    property bool  openGL: true
    property bool  fullMode: true    //全高显示,纵向
    property bool  fullWide: false   //全宽显示,横向
    property int   yTicks:  fullMode ? 21 : 11
    property bool  realTimeMode: false   //实时刷新显示
    property color seriesColor1: Com.series_color1
    property color seriesColor2: Com.series_color2
    property color seriesColor3: Com.series_color3
    visible: false
    UiCornerLine{
        id:cornerLine
        anchors.top: parent.top
        anchors.topMargin: 4
        anchors.right: parent.right
        anchors.rightMargin: 4
        anchors.left: parent.left
        anchors.leftMargin: 4
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 4
        onShowHeadLineChanged:
        {
            if(showHeadLine)
                chName.textColor = "white"
            else
                chName.textColor = "#C0C0C0"
        }
    }
    Canvas{
        id: chName
        visible: realTimeMode
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        width: 60
        height: 18
        contextType: "2d";
        property color textColor: "#C0C0C0"
        onPaint: {
            context.lineWidth = 1;
            context.strokeStyle = "#00000000";
            context.fillStyle = "#343536";
            context.beginPath();
            context.moveTo(0, 0);
            context.lineTo(width , 0);
            context.lineTo(0.6*width , height);
            context.lineTo(0 , height);
            context.closePath();
            context.fill();
            context.stroke();
        }
        Text {
            anchors.top: parent.top
            anchors.topMargin: 2
            anchors.left: parent.left
            anchors.leftMargin: 2
            font.pixelSize: 12
            color: chName.textColor
            font.family: "幼圆"
            text: "通道"+(chIndex+1)
        }

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
        text: qsTr("dBm")
    }
    Text{
        id:refLevel
        anchors.top: parent.top
        anchors.topMargin: 14
        anchors.left: parent.left
        anchors.leftMargin: 80
        width: 120
        font.family: "Calibri"
        font.pixelSize: 12
        color:"white"
        text: " REF: "+axisY.max.toFixed(2)+" dBm"
    }
    //chart view
    ChartView {
        id: view
        //title: "Two Series, Common Axes"
        anchors.fill: parent
        backgroundColor: "#00FFFFFF"
        animationOptions: ChartView.NoAnimation
        //theme: ChartView.ChartThemeDark
        antialiasing: false
        legend{
            visible: false
        }
        property point hoveredPoint: Qt.point( 0, 0 )
        property bool  hovered: false
        ValueAxis {
            id: axisX
            min: xAxisMin
            max: xAxisMax
            tickCount: fullWide ? 11 : 6
            gridLineColor: "#4C7049"
            labelFormat:"%.4f";
            //titleText: "<a style='color:red'>MHz</a>";
            //titleText: "MHz";
            //titleFont.pixelSize: 12;
            labelsColor: "#C0C0C0"

        }
        ValueAxis {
            id: axisY
            min: yAxisMin
            max: yAxisMax
            tickCount: yTicks
            labelFormat:"%.2f";
            gridLineColor: "#4C7049"
            labelsColor: "#C0C0C0"
        }
        LineSeries {
            id: series1
            objectName: "series1"
            axisX: axisX
            axisY: axisY
            color: seriesColor1
            style:Qt.SolidLine
            useOpenGL: openGL
            onHovered: {
                //console.log("onClicked: " + point.x + ", " + point.y);
            }

        }
        LineSeries {
            id: series2
            objectName: "series2"
            axisX: axisX
            axisY: axisY
            color: seriesColor2
            style:Qt.SolidLine
            useOpenGL: openGL
            onHovered: {
                //console.log("onClicked: " + point.x + ", " + point.y);
            }
        }
        LineSeries {
            id: series3
            objectName: "series3"
            axisX: axisX
            axisY: axisY
            color: seriesColor3
            style:Qt.SolidLine
            useOpenGL: openGL
            onHovered: {
                //console.log("onClicked: " + point.x + ", " + point.y);
            }
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: pressed ? Qt.SizeAllCursor: Qt.ArrowCursor
            acceptedButtons: Qt.LeftButton | Qt.RightButton;
            property point sPoint: Qt.point( 0, 0 )
            property point ePoint: Qt.point( 0, 0 )
            onPositionChanged: {
                var point = Qt.point( 0, 0 )
                point.x = mouse.x
                point.y = mouse.y
                var hoveredPoint = Qt.point( 0, 0 )

                hoveredPoint = view.mapToValue( point, series1 )

                if( hoveredPoint.x >= axisX.min && hoveredPoint.x <= axisX.max
                        && hoveredPoint.y >= axisY.min && hoveredPoint.y <= axisY.max)
                {
                    zoomXY = "x"
                    hoveredPoint.x = hoveredPoint.x.toFixed(xPrecision);
                    view.hovered = true
                    view.hoveredPoint = hoveredPoint
                }else {
                    view.hovered = false
                }
                if(hoveredPoint.x < axisX.min && hoveredPoint.y >= axisY.min && hoveredPoint.y <= axisY.max)
                {
                    zoomXY = "y"
                    view.hovered = true
                    view.hoveredPoint = hoveredPoint
                }
                if(pressed)//drag
                {
                    var rateY = (yAxisMax-yAxisMin)/(axisY.max - axisY.min)
                    var currentRangeX = axisX.max - axisX.min

                    view.scrollDown(rateY*(hoveredPoint.y - sPoint.y))

                    if(currentRangeX < bandwidth)
                    {
                        var rateX = bandwidth/currentRangeX
                        if(axisX.max < xAxisMax && hoveredPoint.x < sPoint.x) {
                            view.scrollLeft(rateX*(hoveredPoint.x - sPoint.x))
                        }
                        if(axisX.min > xAxisMin && hoveredPoint.x > sPoint.x){
                            view.scrollRight(rateX*(sPoint.x - hoveredPoint.x))
                        }
                    }
                }
            }
            onWheel: {
                //var resolution = (bandwidth * 1000000)/fftpoints
                var minStep = resolution/10000
                if(axisX.max - axisX.min > 3)
                    zoomXStep = 1
                else if(axisX.max - axisX.min > 1)
                    zoomXStep = 0.3
                else if(axisX.max - axisX.min > 0.1)
                    zoomXStep = 0.03
                else
                    zoomXStep = minStep
                if(zoomXStep < minStep)
                    zoomXStep = minStep;

                //console.log("resolution/10000:"+(resolution/10000))
                var isZoomIn = false;
                if( wheel.angleDelta.y > 0 )
                    isZoomIn = true;
                view.wheelZoomXY(view.hovered, isZoomIn, view.hoveredPoint,  zoomXY);
                markSlider.setMarkRange();
                updateCharts();
            }
            onPressed: {
                if(mouse.button === Qt.LeftButton){
                    sPoint.x = mouse.x
                    sPoint.y = mouse.y
                    sPoint = view.mapToValue(sPoint);
                }

            }
            onReleased: {
                if(mouse.button === Qt.LeftButton){
                    ePoint.x = mouse.x
                    ePoint.y = mouse.y
                    markSlider.setMarkRange();
                    updateCharts();
                }
            }

        }//!--MouseArea END

        function wheelZoomXY( enable, isin, point, XY)
        {
            if(!enable)
                return
            var axis, axisMin, axisMax
            if(XY === "x"){
                axis = axisX
                axisMin = xAxisMin
                axisMax = xAxisMax
            }else{
                axis = axisY
                axisMin = yAxisMin
                axisMax = yAxisMax
            }
            if( isin ) {
                if( axis.max - axis.min <= zoomXStep ) {
                    return
                }
                view.zoom_In( point , XY)
            } else {
                view.zoom_Out( point , XY)
                if( axis.min <= axisMin ) {
                    axis.min = axisMin
                }
                if( axis.max >= axisMax ) {
                    axis.max = axisMax
                }
            }
        }//!--function wheelZoomXY END

        function zoom_In( hoveredPoint , XY) {
            var axis, axisMin, axisMax, hoveredXY
            if(XY === "x"){
                axis = axisX
                axisMin = xAxisMin
                axisMax = xAxisMax
                hoveredXY = hoveredPoint.x
            }else{
                axis = axisY
                axisMin = yAxisMin
                axisMax = yAxisMax
                hoveredXY = hoveredPoint.y
            }

            var left  = hoveredXY - axis.min
            var right = axis.max - hoveredXY

            var scale = parseFloat( left / right )

            var step  = (XY === "x") ? zoomXStep : zoomYStep

            var tempMin = axis.min;
            var tempMax = axis.max;


            if(scale >=1 ){
                tempMin  = axis.min + step
                tempMax  = axis.max - step/scale
            }
            else {
                tempMin  = axis.min + step*scale
                tempMax  = axis.max - step
            }

            if(tempMax - tempMin > step){
                axis.min =  tempMin
                axis.max =  tempMax
            }
        }//!--function zoom_In END

        function zoom_Out( hoveredPoint, XY ) {
            var axis, axisMin, axisMax, hoveredXY
            if(XY === "x"){
                axis = axisX
                axisMin = xAxisMin
                axisMax = xAxisMax
                hoveredXY = hoveredPoint.x
            }else{
                axis = axisY
                axisMin = yAxisMin
                axisMax = yAxisMax
                hoveredXY = hoveredPoint.y
            }
            var left  = hoveredXY - axis.min
            var right = axis.max - hoveredXY

            var scale = parseFloat( left / right )

            var step  = (XY === "x") ? zoomXStep : zoomYStep

            var tempMin = axis.min;
            var tempMax = axis.max;
            if(scale >=1 ){
                tempMin  = axis.min - step
                tempMax  = axis.max + step/scale
            }
            else{
                tempMin  = axis.min - step*scale
                tempMax  = axis.max + step
            }
            axis.max =  (tempMax > axisMax) ? axisMax : tempMax
            axis.min =  (tempMin < axisMin) ? axisMin : tempMin
        }//!--function zoom_Out END
    }//!-- ChartView end


    //----右侧控制按钮-----
    UiCheckButton{
        id:stopCapture
        anchors.bottom: btnZoomReset.top
        anchors.bottomMargin: 2
        anchors.right: peakCtrl.right
        iconFontText: checked ? "\uf127" : "\uf0c1"
        textColor: checked ? "#C74646" : "#D3D4D4"
        disabled: !realTimeMode
        tips:"暂停/启动实时采集"
        onClicked:
        {
            if(checked)
            {
                captureThread.stopCapture()
            }
            else
            {
                captureThread.startCapture()
            }
        }
    }
    UiCheckButton{
        id:btnZoomReset
        anchors.bottom: seriesSignal3.top
        anchors.bottomMargin: 2
        anchors.right: peakCtrl.right
        iconFontText:"\uf066"
        textColor: "#D3D4D4"
        mode:"button"
        checked: true
        tips:"复位显示频谱图"
        onClicked:
        {
            axisX.min = xAxisMin
            axisX.max = xAxisMax
            axisY.min = yAxisMin = Settings.reflevelMin(Com.OpGet, 0, chIndex)
            axisY.max = yAxisMax = Settings.reflevelMax(Com.OpGet, 0, chIndex)
            markSlider.setMarkRange()
            updateCharts()
            checked = true
        }
    }
    UiCheckButton{
        id:seriesSignal3
        anchors.bottom: seriesSignal2.top
        anchors.bottomMargin: 2
        anchors.right: peakCtrl.right
        iconFontText:"\uf159"
        textColor: seriesColor3
        disabled: true
        tips:"显示/隐藏波形3"
        onClicked:
        {
            series3.visible = checked
            rtPeak3.visible = (checked && peakCtrl.checked)
            markSlider.visible3 = (checked && peakCtrl.visible)

        }
    }
    UiCheckButton{
        id:seriesSignal2
        anchors.bottom: seriesSignal1.top
        anchors.bottomMargin: 2
        anchors.right: peakCtrl.right
        iconFontText:"\uf159"
        textColor: seriesColor2
        disabled: true
        tips:"显示/隐藏波形2"
        onClicked:
        {
            series2.visible = checked
            rtPeak2.visible = (checked && peakCtrl.checked)
            markSlider.visible2 = (checked && peakCtrl.visible)
        }
    }
    UiCheckButton{
        id:seriesSignal1
        anchors.bottom: peakCtrl.top
        anchors.bottomMargin: 2
        anchors.right: peakCtrl.right
        iconFontText:"\uf159"
        textColor: seriesColor1
        checked: true
        tips:"显示/隐藏波形1"
        onClicked:
        {
            //console.log("seriesSignal1.checked",seriesSignal1.checked)
            series1.visible = checked
            rtPeak1.visible = (checked && peakCtrl.checked)
            markSlider.visible1 = (checked && peakCtrl.visible)
        }
    }
    UiCheckButton{
        id:peakCtrl
        anchors.bottom: movePeak.top
        anchors.bottomMargin: 2
        anchors.right: movePeak.right
        iconFontText:"\uf05b"
        textColor: "#54FA00"
        tips:"显示/关闭Peak点"
        onClicked:
        {

            rtPeak1.visible = (checked && series1.visible)
            rtPeak2.visible = (checked && series2.visible)
            rtPeak3.visible = (checked && series3.visible)
            if(!checked)
            {
                movePeak.checked   = checked
                markSlider.visible = checked
            }
        }
    }
    UiCheckButton{
        id:movePeak
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        anchors.right: parent.right
        anchors.rightMargin: 10
        iconFontText:"\uf07e"
        textColor: "#54FA00"
        disabled: !peakCtrl.checked
        tips:"显示/关闭Mark标尺"
        onClicked:
        {
            if(visible)
                markSlider.setMarkRange()
            markSlider.visible  = checked
            markSlider.visible1 = (checked && seriesSignal1.checked)
            markSlider.visible2 = (checked && seriesSignal2.checked)
            markSlider.visible3 = (checked && seriesSignal3.checked)
        }
    }//!----右侧控制按钮--- END


    //---文件进度条拖动控制--
    UiMultSlider {
        id: fileSlider1
        anchors.top: parent.top
        anchors.topMargin: 32
        anchors.left: parent.left
        anchors.leftMargin: 40
        width: 100
        min:axisX.min
        max:axisX.max
        visible: series1.visible && !realTimeMode
        handleColor: Com.series_color1
        onValueChanged: {
            var percent = value.toFixed(3);
            dataSource.setFileOffset("series1", percent)
            dataSource.updateFreqDodminFromFile(series1, Settings.historyFile1())
            fftData.refreshSeriesPoints(root.chIndex, 0);

            if(Settings.analyzeMode() === 3)//刷新瀑布图
                waterfallView.updateFile(Settings.historyFile1())

            //rtPeak1.updatePeak()//数据更新,peak点会emit信号自动刷新
        }
        onHandleReleased:
        {

        }
    }
    UiMultSlider {
        id: fileSlider2
        anchors.top: fileSlider1.bottom
        anchors.left: fileSlider1.left
        width: fileSlider1.width
        min:axisX.min
        max:axisX.max
        visible: series2.visible && !realTimeMode
        handleColor:Com.series_color2
        onValueChanged: {
            var percent = value.toFixed(3);
            dataSource.setFileOffset("series2", percent)
            dataSource.updateFreqDodminFromFile(series2, Settings.historyFile2())
            fftData.refreshSeriesPoints(root.chIndex, 1);
        }
    }
    UiMultSlider {
        id: fileSlider3
        anchors.top: fileSlider2.bottom
        anchors.left: fileSlider2.left
        width: fileSlider2.width
        min:axisX.min
        max:axisX.max
        visible: series3.visible && !realTimeMode
        handleColor:Com.series_color3
        onValueChanged: {
            var percent = value.toFixed(3);
            dataSource.setFileOffset("series3", percent)
            dataSource.updateFreqDodminFromFile(series3, Settings.historyFile3())
            fftData.refreshSeriesPoints(root.chIndex, 2);
        }
    }
    //!---文件进度条拖动控制-- END

    //---PeakMark点控制显示--
    UiSlider {
        id: markSlider
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        anchors.left: parent.left
        anchors.leftMargin: 40
        width: 100
        min:axisX.min
        max:axisX.max
        visible: false
        /**********************************************************
        参数说明     功能 重新标定滑动条的长度和范围
        ***********************************************************/
        function setMarkRange()
        {
            var lpoint = Qt.point(axisX.min, 0);
            var rpoint = Qt.point(axisX.max, 0);
            var lmargin = view.mapToPosition(lpoint, series1)
            var rmargin = view.mapToPosition(rpoint, series1)
            markSlider.anchors.leftMargin  = lmargin.x;
            markSlider.width = rmargin.x-lmargin.x;

            fileSlider1.anchors.leftMargin = lmargin.x
            fileSlider1.width = rmargin.x-lmargin.x
            //console.log("setMarkRange percent1", percent1)

        }
        onVisibleChanged:
        {
        }
        onPercent1Changed: {
            //console.log("onValue1Changed percent:", percent1, range, percent1*range+min)
            var move_point = Qt.point(percent1*range+min, axisY.max/2);
            root.movePeakPosition(rtPeak1, move_point,  0, series1);

            //markSlider.handle1Value=percent1;
        }
        onPercent2Changed: {
            var move_point = Qt.point(percent2*range+min, axisY.max/2);
            root.movePeakPosition(rtPeak2, move_point,  1, series2);
            //markSlider.handle2Value=percent2;
        }
        onPercent3Changed: {
            var move_point = Qt.point(percent3*range+min, axisY.max/2);
            root.movePeakPosition(rtPeak3, move_point,  2, series3);
            //markSlider.handle3Value=percent3;
        }
    }
    PeakText{
        id: peakShow
        width: 190
        height: 20
        anchors.top: parent.top
        anchors.topMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 50
        textColor: Com.series_color1
        visible: rtPeak1.visible
    }
    PeakText{
        id: peakShow2
        width: 190
        height: 20
        anchors.top: peakShow.top
        anchors.right: peakShow.left
        anchors.rightMargin: 4
        textColor: Com.series_color2
        visible: rtPeak2.visible
    }
    PeakText{
        id: peakShow3
        width: 190
        height: 20
        anchors.top: peakShow2.top
        anchors.right: peakShow2.left
        anchors.rightMargin: 4
        textColor: Com.series_color3
        visible: rtPeak3.visible
    }
    PeakRect{
        id:rtPeak1
        onVisibleChanged: {
            if(visible){
                //dataSource.refreshPeakPoint(0)
                fftData.refreshPeakPoint(root.chIndex, 0)
                if( (!realTimeMode) || (!captureThread.isRunning()) )
                {
                    fftData.refreshSeriesPoints(root.chIndex, 0);
                    root.updatePeak(rtPeak1, fftData.peakPoint0, 0, series1);
                    //绝对值转换为相对值
                    //markSlider.handle1Value=(fftData.peakPoint0.x-axisX.min)/(axisX.max-axisX.min);

                }
            }
            else
                idBottomPannel.updateMarkRange(false, 0);
        }
    }
    PeakRect{
        id:rtPeak2
        onVisibleChanged: {
            if(visible){
                //dataSource.refreshPeakPoint(1)
                fftData.refreshPeakPoint(root.chIndex, 1)
                if( (!realTimeMode) || (!captureThread.isRunning()) ){
                    fftData.refreshSeriesPoints(root.chIndex, 1);
                    root.updatePeak(rtPeak2, fftData.peakPoint1, 1, series2);
                    //绝对值转换为相对值
                    //markSlider.handle2Value=(fftData.peakPoint1.x-axisX.min)/(axisX.max-axisX.min);
                }
            }
        }
    }
    PeakRect{
        id:rtPeak3
        onVisibleChanged: {
            if(visible){
                //dataSource.refreshPeakPoint(2)
                fftData.refreshPeakPoint(root.chIndex, 2)
                if( (!realTimeMode) || (!captureThread.isRunning()) ){
                    fftData.refreshSeriesPoints(root.chIndex, 2);
                    root.updatePeak(rtPeak3, fftData.peakPoint2, 2, series3);
                    //绝对值转换为相对值
                    //markSlider.handle3Value=(fftData.peakPoint2.x-axisX.min)/(axisX.max-axisX.min);
                }
            }
        }
    }
    //!---PeakMark点控制显示-- END


    //*************频谱图控制按钮*************
    UiCheckButton{
        id:xSpanIn
        anchors.top: root.top
        anchors.topMargin: 26
        anchors.left: root.left
        anchors.leftMargin: 8
        iconFontText:"\uf065"
        textColor: "white"
        checked: true
        mode:"button"
        tips:"横坐标放大"
        iconRotation: 45
        disabled: true
        width: 22
        height: width
        onClicked:
        {
            checked = true
            if(workZoomXStep())
            {

                var centerPoint = Qt.point( 0, 0 )
                centerPoint.x = (axisX.max-axisX.min) / 2 + axisX.min
                centerPoint.y = (axisY.max-axisY.min) / 2 + axisY.min
                 //console.log("xSpanIn clicked centerPoint:",centerPoint)

                view.wheelZoomXY(true, true, centerPoint,  "x");
                markSlider.setMarkRange();
                updateCharts();
            }
        }
    }
    UiCheckButton{
        id:xSpanOut
        anchors.top: xSpanIn.bottom
        anchors.topMargin: 2
        anchors.left: xSpanIn.left
        iconFontText:"\uf066"
        textColor: "white"
        checked: true
        mode:"button"
        tips:"横坐标缩小"
        iconRotation: 45
        disabled: true
        width: 22
        height: width
        onClicked:
        {
            checked = true
            workZoomXStep()

            var centerPoint = Qt.point( 0, 0 )
            centerPoint.x = (axisX.max-axisX.min) / 2 + axisX.min
            centerPoint.y = (axisY.max-axisY.min) / 2 + axisY.min
             //console.log("xSpan clicked centerPoint:",centerPoint)

            view.wheelZoomXY(true, false, centerPoint,  "x");
            markSlider.setMarkRange();
            updateCharts();

        }
    }
    UiCheckButton{
        id:ySpanIn
        anchors.top: xSpanOut.bottom
        anchors.topMargin: 2
        anchors.left: xSpanOut.left
        iconFontText:"\uf065"
        textColor: "white"
        checked: true
        mode:"button"
        tips:"纵坐标放大"
        iconRotation: -45
        disabled: true
        width: 22
        height: width
        onClicked:
        {
            checked = true

            var centerPoint = Qt.point( 0, 0 )
            centerPoint.x = (axisX.max-axisX.min) / 2 + axisX.min
            centerPoint.y = (axisY.max-axisY.min) / 2 + axisY.min
             //console.log("xSpan clicked centerPoint:",centerPoint)

            view.wheelZoomXY(true, true, centerPoint,  "y");
            markSlider.setMarkRange();
            updateCharts();

        }
    }
    UiCheckButton{
        id:ySpanOut
        anchors.top: ySpanIn.bottom
        anchors.topMargin: 2
        anchors.left: ySpanIn.left
        iconFontText:"\uf066"
        textColor: "white"
        checked: true
        mode:"button"
        tips:"纵坐标缩小"
        iconRotation: -45
        disabled: true
        width: 22
        height: width
        onClicked:
        {
            checked = true

            var centerPoint = Qt.point( 0, 0 )
            centerPoint.x = (axisX.max-axisX.min) / 2 + axisX.min
            centerPoint.y = (axisY.max-axisY.min) / 2 + axisY.min
             //console.log("xSpan clicked centerPoint:",centerPoint)

            view.wheelZoomXY(true, false, centerPoint,  "y");
            markSlider.setMarkRange();
            updateCharts();

        }
    }
    UiCheckButton{
        id:specUP
        anchors.top: ySpanOut.bottom
        anchors.topMargin: 2
        anchors.left: ySpanOut.left
        iconFontText:"\uf077"
        textColor: "white"
        checked: true
        mode:"button"
        tips:"上移频谱图"
        disabled: (xSpanIn.disabled && ySpanIn.disabled)
        width: 22
        height: width
        onClicked:
        {
            checked = true
            var rateY = (yAxisMax-yAxisMin)/(axisY.max - axisY.min)
            view.scrollDown(rateY*2)
            //markSlider.setMarkRange();
            updateCharts();
        }
    }
    UiCheckButton{
        id:specDown
        anchors.top: specUP.bottom
        anchors.topMargin: 2
        anchors.left: specUP.left
        iconFontText:"\uf078"
        textColor: "white"
        checked: true
        mode:"button"
        tips:"下移频谱图"
        disabled: specUP.disabled
        width: 22
        height: width
        onClicked:
        {
            checked = true
            var rateY = (yAxisMax-yAxisMin)/(axisY.max - axisY.min)
            view.scrollDown(-rateY*2)
            updateCharts();
        }
    }
    UiCheckButton{
        id:specLeft
        anchors.top: specDown.bottom
        anchors.topMargin: 2
        anchors.left: specDown.left
        iconFontText:"\uf053"
        textColor: "white"
        checked: true
        mode:"button"
        tips:"左移频谱图"
        disabled: specUP.disabled
        width: 22
        height: width
        onClicked:
        {
            checked = true
            var currentRangeX = axisX.max - axisX.min
            if(currentRangeX < bandwidth)
            {
                var rateX = bandwidth/currentRangeX
                if(axisX.max < xAxisMax) {
                    view.scrollRight(rateX*2)
                    markSlider.setMarkRange();
                    updateCharts();
                }
            }

        }
    }
    UiCheckButton{
        id:specRight
        anchors.top: specLeft.bottom
        anchors.topMargin: 2
        anchors.left: specLeft.left
        iconFontText:"\uf054"
        textColor: "white"
        checked: true
        mode:"button"
        tips:"右移频谱图"
        disabled: specUP.disabled
        width: 22
        height: width
        onClicked:
        {
            checked = true
            var currentRangeX = axisX.max - axisX.min
            if(currentRangeX < bandwidth)
            {
                var rateX = bandwidth/currentRangeX
                if(axisX.min > xAxisMin){
                    view.scrollLeft(rateX*2)
                    markSlider.setMarkRange();
                    updateCharts();
                }
            }
        }
    }
    UiCheckButton{
        id:opPeakLeft
        anchors.top: specRight.bottom
        anchors.topMargin: 2
        anchors.left: specRight.left
        iconFontText:"\uf060"
        textColor: opFileSelect.textColor
        checked: true
        mode:"button"
        tips:"左移Mark点"
        disabled: !markSlider.visible
        width: 22
        height: width
        onClicked:
        {
            checked = true
            var idx = opFileSelect.curFileIdx
            var p   = opFileSelect.peakHandle[idx]
            p -= 0.005
            if(p < 0)
                p = 0
            markSlider.setX(idx, p)
        }
    }
    UiCheckButton{
        id:opPeakRight
        anchors.top: opPeakLeft.bottom
        anchors.topMargin: 2
        anchors.left: opPeakLeft.left
        iconFontText:"\uf061"
        textColor: opFileSelect.textColor
        checked: true
        mode:"button"
        tips:"右移Mark点"
        disabled: !markSlider.visible
        width: 22
        height: width
        onClicked:
        {
            checked = true
            var idx = opFileSelect.curFileIdx
            var p   = opFileSelect.peakHandle[idx]
            p += 0.005
            if(p > 1)
                p = 1
            markSlider.setX( idx, p)
        }
    }
    UiCheckButton{
        id:opFileSelect
        anchors.bottom: stopCapture.top
        anchors.bottomMargin: 2
        anchors.right: root.right
        anchors.rightMargin: 10
        iconFontText:"\uf1de"
        textColor: "#daae00"
        checked: true
        mode:"button"
        tips:"切换操作的文件"
        disabled: true
        property var fileHandle: [fileSlider1, fileSlider2, fileSlider3]
        property var peakHandle: [markSlider.percent1, markSlider.percent2, markSlider.percent3]
        property int curFileIdx: 0
        onClicked:
        {

            checked = true
            var idx = curFileIdx;
            if(idx<2)
                idx++
            else
                idx=0
            curFileIdx = idx
            for(var i=0; i<3; i++)
                fileHandle[i].sliderOpacity = 0.5
            fileHandle[idx].sliderOpacity = 1

            var arrayColor =  [seriesColor1, seriesColor2, seriesColor3]
            opFileSelect.textColor = arrayColor[idx]

        }
    }
    UiCheckButton{
        id:opFileNext
        anchors.top: opPeakRight.bottom
        anchors.topMargin: 2
        anchors.left: opPeakRight.left
        iconFontText:"\uf124"
        textColor: opFileSelect.textColor
        checked: true
        mode:"button"
        tips:"读取下一部分文件"
        disabled: true
        iconRotation: 45
        width: 22
        height: width
        onClicked:
        {
            checked = true
            var idx =  opFileSelect.curFileIdx
            if(opFileSelect.fileHandle[idx].visible)
            {
                var val =  opFileSelect.fileHandle[idx].value //fileSlider1.value;
                val += 0.001
                if(val > 1)
                    val = 1;
                opFileSelect.fileHandle[idx].value = val
            }
        }
    }
    UiCheckButton{
        id:opFilePrev
        anchors.top: opFileNext.bottom
        anchors.topMargin: 2
        anchors.left: opFileNext.left
        iconFontText:"\uf124"
        textColor: opFileSelect.textColor
        checked: true
        mode:"button"
        tips:"读取前一部分文件"
        disabled: true
        iconRotation: -135
        width: 22
        height: width
        onClicked:
        {
            checked = true
            var idx =  opFileSelect.curFileIdx
            if(opFileSelect.fileHandle[idx].visible)
            {
                var val =  opFileSelect.fileHandle[idx].value //fileSlider1.value;
                val -= 0.001
                if(val < 0)
                    val = 0;
                opFileSelect.fileHandle[idx].value = val
            }
        }
    }
    //！--*************频谱图控制按钮*************--END


    /**********************************************************
    参数说明     功能 计算横坐标缩放的步进， 根据fft点数和带宽来计算
    ***********************************************************/
    function workZoomXStep()
    {
        var bdw = Settings.baseBandwidth(Com.OpGet, 0, chIndex)
        var fft = Settings.fftPoints(Com.OpGet, 0, chIndex)
        var res = (bdw * 1000000) / fft;

        var cur_bdw = (axisX.max - axisX.min)
        var cur_fft = (cur_bdw * 1000000) / res

        //console.log("res:", res, "cur_fft:", cur_fft);

        if( cur_fft < 100) //100, 设定最小显示100个FFT点
            return false

        zoomXStep = cur_bdw * 0.05
        return true
    }

    /**********************************************************
    参数说明     功能 刷新曲线的顶点
    id_peak   : PeakRect的ID，
    peak_point: dataSource计算出来的顶点
    series_idx: LineSeries的索引， 一共有3条曲线， 从0开始， 0，1，2, 注意索引值都是从0开始， 命名值都是从1开始
    series    : LineSeries的ID
    ***********************************************************/
    function updatePeak(id_peak, peak_point, series_idx, series)
    {
        //console.log("updatePeak  series_idx:",series_idx, "visible:",visible)
        if(!series.visible)
            return
        if(!id_peak.visible && !peakCtrl.checked)
            return

        //console.log("peak_point.x:",peak_point.x, "axisX.min:",axisX.min, "axisX.max:",axisX.max)
        if(peak_point.x<axisX.min || peak_point.x>axisX.max)
        {
            //console.log("peak_point.x:",peak_point.x, "axisX.min:",axisX.min, "axisX.max:",axisX.max)
            id_peak.visible = false
            markSlider.setVisible(series_idx, false)
            return
        }
        else
        {
            if(movePeak.checked)
                markSlider.setVisible(series_idx, true)
            if(peakCtrl.checked)
                id_peak.visible = true
        }


        if(peakCtrl.checked)
            id_peak.visible = true

        var point = view.mapToPosition( peak_point, series)

        id_peak.x = point.x - id_peak.width/2
        id_peak.y = point.y - id_peak.height

        if(id_peak === rtPeak1)
        {
            peakShow.xstring  = peak_point.x.toFixed(xPrecision)
            peakShow.ystring = peak_point.y.toFixed(3)
            idBottomPannel.updateMarkRange(true, peakShow.ystring);
        }
        else if(id_peak === rtPeak2)
        {
            peakShow2.xstring  = peak_point.x.toFixed(xPrecision)
            peakShow2.ystring = peak_point.y.toFixed(3)
        }
        else if(id_peak === rtPeak3)
        {
            peakShow3.xstring  = peak_point.x.toFixed(xPrecision)
            peakShow3.ystring = peak_point.y.toFixed(3)
        }
        //更新slider
        var percent = (peak_point.x-axisX.min)/(axisX.max-axisX.min)

        markSlider.setX(series_idx, percent)
    }

    /**********************************************************
    参数说明     功能 移动更新显示PeakRect坐标
    id_peak   : PeakRect的ID，
    point     : 由silder计算出来的X坐标点(纵坐标固定)，根据此X点计算出在series中的Y点， 然后更新PeakRect显示的位置
    series_idx: LineSeries的索引， 一共有3条曲线， 从0开始， 0，1，2, 注意索引值都是从0开始， 命名值都是从1开始
    series    : LineSeries的ID
    ***********************************************************/
    function movePeakPosition(id_peak, point, series_idx, series)
    {
        //console.log("movePeakPosition series_idx:", series_idx, visible, movePeak.checked)
        if(!series.visible || !movePeak.checked)
            return

        //get the idx value
        var idx = fftData.getPointIndexByX(point.x, series)

        //console.log("point.x:"+point.x+" idx:"+idx)

        if( (!realTimeMode) || (!captureThread.isRunning()) ){
            var seriesPoint  = series.at(idx)

            var cur_point    = view.mapToPosition( seriesPoint, series)

            //console.log("cur_point:"+cur_point)

            id_peak.x = cur_point.x - id_peak.width/2
            id_peak.y = cur_point.y - id_peak.height

            if(id_peak === rtPeak1)
            {
                peakShow.xstring  = seriesPoint.x.toFixed(xPrecision)
                peakShow.ystring = seriesPoint.y.toFixed(3)

                idBottomPannel.updateMarkRange(true, peakShow.ystring);
            }
            else if(id_peak === rtPeak2)
            {
                peakShow2.xstring  = seriesPoint.x.toFixed(xPrecision)
                peakShow2.ystring = seriesPoint.y.toFixed(3)
            }
            else if(id_peak === rtPeak3)
            {
                peakShow3.xstring  = seriesPoint.x.toFixed(xPrecision)
                peakShow3.ystring = seriesPoint.y.toFixed(3)
            }
        }
        //dataSource.setCurrentPeakX(series_idx, point.x)//deprecate
        fftData.setCurrentPeakX(root.chIndex, series_idx, point.x)
    }
    function updatePeakShow()
    {
        rtPeak1.visible = (peakCtrl.checked && series1.visible)
        rtPeak2.visible = (peakCtrl.checked && series2.visible)
        rtPeak3.visible = (peakCtrl.checked && series3.visible)
        markSlider.visible1 = rtPeak1.visible
        markSlider.visible2 = rtPeak2.visible
        markSlider.visible3 = rtPeak3.visible
        movePeak.checked = peakCtrl.checked
    }
    function closePeakMark()
    {
        peakCtrl.checked = false
        rtPeak1.visible = false
        rtPeak2.visible = false
        rtPeak3.visible = false
        movePeak.checked   = false
        markSlider.visible = false
    }
    onVisibleChanged: {

    }
    onWidthChanged:
    {
        markSlider.setMarkRange()
        root.closePeakMark()
    }
    SpectrumData{
        id:fftData
        channelIdx: chIndex
        source: dataSource
        seriesHandle0: series1
        seriesHandle1: series2
        seriesHandle2: series3
        onPeakPointChanged:{
            if(rtPeak1.visible){
                if(0 == idx)
                    root.updatePeak(rtPeak1, fftData.peakPoint0, 0, series1)
                else if(1 == idx)
                    root.updatePeak(rtPeak2, fftData.peakPoint1, 1, series2)
                else if(2 == idx)
                    root.updatePeak(rtPeak3, fftData.peakPoint2, 2, series3)
            }
        }
    }
    Component.onCompleted: {
        chartCtrl.setLineSeriesPenWidth(series1, 1)
        chartCtrl.setAxisGridLinePenStyle(axisX, Qt.DotLine)//DashLine
        chartCtrl.setAxisGridLinePenStyle(axisY, Qt.DotLine)
        //axisY.min = Settings.reflevelMin()
        //axisY.max = Settings.reflevelMax()
    }

    function updateCharts()
    {
        if(0 === chIndex)
            waterfallView.updateAxisXRtShow(axisX.min, axisX.max, xAxisMin, xAxisMax)
        else
            waterfallView2.updateAxisXRtShow(axisX.min, axisX.max, xAxisMin, xAxisMax)
        fftData.updateCurMinMax(root.chIndex, axisX.min, axisX.max);

        //如果是文件模式或者暂停,此处刷新peak点,实时模式无需在此刷新
        if( (!realTimeMode) || (!captureThread.isRunning()) )
        {
            fftData.refreshSeriesPoints(root.chIndex, 0)
            fftData.refreshSeriesPoints(root.chIndex, 1)
            fftData.refreshSeriesPoints(root.chIndex, 2)
        }
    }
    function setAxisYRange(min, max)
    {
        axisY.min = yAxisMin = min
        axisY.max = yAxisMax = max
    }
    function setAxisXPrecision()
    {
        if(resolution>=100000){
            axisX.labelFormat = "%.2f"
            xPrecision = 1;
        }
        else if(resolution>=10000){
            axisX.labelFormat = "%.3f"
            xPrecision = 2;
        }
        else if(resolution>=1000){
            axisX.labelFormat = "%.4f"
            xPrecision = 3;
        }
        else if(resolution>=100){
            axisX.labelFormat = "%.5f"
            xPrecision = 4;
        }
        else if(resolution>=30){
            axisX.labelFormat = "%.6f"
            xPrecision = 5;
        }

    }
    function updateParams()
    {

        captureThread.stopCapture()
        //dataSource.clearFilter(); //not use

        centerFreq = Settings.centerFreq(Com.OpGet, 0, chIndex)
        bandwidth  = Settings.bandWidth(Com.OpGet, 0, chIndex)
        var fftpoints = Settings.fftPoints(Com.OpGet, 0, chIndex)

        resolution = (bandwidth * 1000000)/fftpoints
        setAxisXPrecision()

        axisX.min = xAxisMin = centerFreq - bandwidth/2
        axisX.max = xAxisMax = centerFreq + bandwidth/2

        markSlider.setMarkRange()

        series1.visible = false
        series2.visible = false
        series3.visible = false
        seriesSignal2.checked = false
        seriesSignal2.disabled = true
        seriesSignal3.checked = false
        seriesSignal3.disabled = true

        fftData.setForceRefresh(root.chIndex)
        if(realTimeMode){
            series1.visible = true
            fftData.updateCurMinMax(root.chIndex, axisX.min, axisX.max)
            stopCapture.checked = false
        }else{

            if(Settings.historyFile1().length>0)
            {
                fileSlider1.value = dataSource.getFileOffset(0)
                dataSource.updateFreqDodminFromFile(series1, Settings.historyFile1())
                seriesSignal1.checked = true
                seriesSignal1.disabled = false
                series1.visible = true
            }
            if(Settings.historyFile2().length>0 && (realTimeMode == false) && fullMode)
            {
                dataSource.updateFreqDodminFromFile(series2, Settings.historyFile2())
                seriesSignal2.checked = true
                seriesSignal2.disabled = false
                series2.visible = true
            }
            if(Settings.historyFile3().length>0 && (realTimeMode == false) && fullMode)
            {
                dataSource.updateFreqDodminFromFile(series3, Settings.historyFile3())
                seriesSignal3.checked = true
                seriesSignal3.disabled = false
                series3.visible = true
            }
        }
        updateCharts()
        updatePeakShow()
    }




    /**********************************************************
    以下函数为对外操作接口,直接调用即可,可视需求自由修改
    原则:接口函数在本级禁止互相调用,由上层使用者互相调用
    统一返回值定义:true 调用成功  false:调用无效
    ***********************************************************/
    //选择 X 轴缩放
    function setXSpan(ch, en)
    {
        if(ch !== chIndex)
            return false
        console.log("setXSpan ch:",ch, en)
        xSpanIn.disabled = !en
        xSpanOut.disabled = !en
        return true
    }
    //选择 Y 轴缩放
    function setYSpan(ch, en)
    {
        if(ch !== chIndex)
            return false
        console.log("setYSpan ch:",ch, en)
        ySpanIn.disabled = !en
        ySpanOut.disabled = !en
        return true
    }
    //放大操作
    function setZoomIn(ch)
    {

        if(ch !== chIndex)
            return false
        if(!xSpanIn.disabled)
        {
            xSpanIn.clicked()
            console.log("setZoomIn X ch:",ch)
            return true
        }
        if(!ySpanIn.disabled)
        {
            ySpanIn.clicked()
            console.log("setZoomIn Y ch:",ch)
            return true
        }
        return false
    }
    //缩小操作
    function setZoomOut(ch)
    {
        if(ch !== chIndex)
            return false
        if(!xSpanOut.disabled)
        {
            xSpanOut.clicked()
            console.log("setZoomOut X ch:",ch)
            return true
        }
        if(!ySpanOut.disabled)
        {
            ySpanOut.clicked()
            console.log("setZoomOut Y ch:",ch)
            return true
        }
        return false
    }
    //平移操作
    function setDragMove(ch, direction)
    {
        //direction 0:up  1:down 2:left 3:right
        var idx = parseInt(direction)
        if(ch !== chIndex)
            return false
        if(idx < 0 || idx > 3)
            return false
        var btnArray = [specUP, specDown, specLeft, specRight]
        if(btnArray[idx].disabled)
            return false
        console.log("setDragMove direction:",direction,"ch:",ch)
        btnArray[idx].clicked()
        return true
    }
    //复位频谱图缩放和位置
    function setChartReset(ch)
    {
        if(ch !== chIndex)
            return false
        btnZoomReset.clicked()
    }
    //显示Peak点
    function setShowPeak(ch)
    {
        if(ch !== chIndex)
            return false
        console.log("setShowPeak ch:",ch)
        peakCtrl.checked = !peakCtrl.checked
        peakCtrl.clicked()
        return true
    }
    //关闭Peak点
    function setClosePeak(ch)
    {
        if(ch !== chIndex)
            return false
        console.log("setClosePeak ch:",ch)
        if(peakCtrl.checked){
            peakCtrl.checked = !peakCtrl.checked
            peakCtrl.clicked()
        }
        return true
    }
    //设置操作Mark点
    function setShowMark(ch)
    {
        if(ch !== chIndex)
            return false
        if(!peakCtrl.checked)
            return false
        console.log("setShowMark ch:",ch)
        movePeak.checked = !movePeak.checked
        movePeak.clicked()
        return true
    }
    //关闭Mark平移操作
    function setCloseMark(ch)
    {
        if(ch !== chIndex)
            return false
        if(!peakCtrl.checked)
            return false
        if(!movePeak.checked)
            return false
        console.log("setCloseMark ch:",ch)
        movePeak.checked = !movePeak.checked
        movePeak.clicked()
        return true
    }
    //左右平移Mark点
    function setMoveMark(ch, direction)
    {
        //direction 0:left  1:right
        if(ch !== chIndex)
            return false
        if(!peakCtrl.checked)
            return false
        if(opPeakLeft.disabled || opPeakRight.disabled)
            return false
        console.log("setMoveMark direction:",direction, "ch:",ch)
        if(0 === direction)
            opPeakLeft.clicked()
        else
            opPeakRight.clicked()
        return true
    }
    //切换选择操作的文件
    function setSwitchFile(ch)
    {
        if(ch !== chIndex)
            return false
        if(opFileSelect.disabled)
            return false
        console.log("setSwitchFile switch ch:",ch)
        opFileSelect.clicked()
        return true
    }
    //设置是否允许切换选择文件
    function setSwitchFileEnable(ch, en)
    {
        if(ch !== chIndex)
            return false
        //非文件模式,直接禁用
        var mode = Settings.analyzeMode()
        if(mode < 2)
            en = false
        console.log("setSwitchFile enable:", en, "ch:", ch)
        //同步当前文件是否高亮
        var idx = opFileSelect.curFileIdx
        opFileSelect.fileHandle[idx].sliderOpacity = (en?1:0.5)
        opFileSelect.disabled = !en
        return true
    }
    //设置允许(禁止)向前(后)读取文件
    function setActiveFile(ch, en)
    {
        if(ch !== chIndex)
            return false
        if(opFileSelect.disabled)
            en = false
        console.log("setActiveFile disabled:", !en, "ch:",ch)
        opFileNext.disabled = !en
        opFilePrev.disabled = !en
        return true
    }
    //左右平移文件
    function setMoveFile(ch, direction)
    {
        //direction 0:left  1:right
        if(ch !== chIndex)
            return false
        if(opFileNext.disabled || opFilePrev.disabled)
            return false
        console.log("setMoveFile direction:",direction, "ch:",ch)
        if(0 === direction)
            opFilePrev.clicked()
        else
            opFileNext.clicked()
        return true
    }
    //设置本通道样式(选中和未选中时的样式)
    function setActiveChannel(ch)
    {
        if(!realTimeMode)
        {
            cornerLine.showHeadLine = false
            return false
        }
        console.log("setActiveChannel ch:",ch)
        if(ch === chIndex)
            cornerLine.showHeadLine = true
        else
            cornerLine.showHeadLine = false
        return true
    }

}
