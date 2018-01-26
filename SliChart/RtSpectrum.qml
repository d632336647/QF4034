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
    property var  theScopeViewEle: undefined
    property bool  altPress:true
    property color seriesColor1: Com.series_color1
    property color seriesColor2: Com.series_color2
    property color seriesColor3: Com.series_color3

    property point centerPoint: Qt.point( 0, 0 )
    property var  noCheckbuttonEleArray:[] //存储非checkbutton元素
    property var  uiCheckButtonArray:[];//UiCheckButton按钮数组
    property int  uiSliderIndex:-1 //第一个UiSliderIndex出现的索引号

    property real  fftCount1: 30000

    visible: false

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
    Canvas{
        id: chName
        visible: realTimeMode
        anchors.top: parent.top
        anchors.topMargin: 5
        anchors.left: parent.left
        anchors.leftMargin: 5
        width: 60
        height: 16
        contextType: "2d";
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
            anchors.fill: parent
            font.pixelSize: 12
            color:"white"
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
        }

        ValueAxis {
            id: axisY
            min: yAxisMin
            max: yAxisMax
            tickCount: yTicks
            labelFormat:"%.2f";
            gridLineColor: "#4C7049"
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
                view.wheelZoomXY(view.hovered, wheel, view.hoveredPoint,  zoomXY);
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

        function wheelZoomXY( enable, wheel, point, XY)
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
            if( wheel.angleDelta.y > 0 ) {
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

        //按键控制放大缩小
        function wheelZoomXY_ByBtn( enable, point,isZoomIn, XY)//flag表示放大还是缩小的布尔值
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
            if( isZoomIn) {
                if( axis.max - axis.min <= 1 ) {
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

            markSlider.setMarkRange();
            updateCharts();

        }//!--function wheelZoomXY_ByBtn END

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

            fftCount1= (series1.count > 500)? series1.count: 500;

            markSlider.horizonStepValue=((axisX.max-axisX.min)*(axisX.max-axisX.min))/fftCount1;
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



            fftCount1= (series1.count > 40000)? series1.count: 40000;

            markSlider.horizonStepValue=(axisX.max-axisX.min)/fftCount1;

        }//!--function zoom_Out END
    }//!-- ChartView end


    //ctrl panel
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
        anchors.bottomMargin: 80
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
    }//!--ctrl panel end


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
        exScopeViewEle:root.theScopeViewEle
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
        exScopeViewEle:root.theScopeViewEle
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
        exScopeViewEle:root.theScopeViewEle
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
        exScopeViewEle:root.theScopeViewEle
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

            markSlider.handle1Value=percent1;
        }
        onPercent2Changed: {
            var move_point = Qt.point(percent2*range+min, axisY.max/2);
            root.movePeakPosition(rtPeak2, move_point,  1, series2);
            markSlider.handle2Value=percent2;
        }
        onPercent3Changed: {
            var move_point = Qt.point(percent3*range+min, axisY.max/2);
            root.movePeakPosition(rtPeak3, move_point,  2, series3);
            markSlider.handle3Value=percent3;
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
                    markSlider.handle1Value=(fftData.peakPoint0.x-axisX.min)/(axisX.max-axisX.min);

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
                    markSlider.handle2Value=(fftData.peakPoint1.x-axisX.min)/(axisX.max-axisX.min);
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
                    markSlider.handle3Value=(fftData.peakPoint2.x-axisX.min)/(axisX.max-axisX.min);
                }
            }
        }
    }




    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{


        var rateY_btn = (yAxisMax-yAxisMin)/(axisY.max - axisY.min);
        var currentRangeX_btn = axisX.max - axisX.min;
        var rateX_btn = bandwidth/currentRangeX_btn;
        var theaxisMinX = xAxisMin;
        var theaxisMaxX = xAxisMax;

        var theaxisMinY = yAxisMin;
        var theaxisMaxY = yAxisMax;
        var themidX=theaxisMinX+(theaxisMaxX-theaxisMinX)/2;
        var themidY=theaxisMinY+(theaxisMaxY-theaxisMinY)/2;
        var checkButtonTipsStr="";//按键悬浮文本
        var theSubTriangleIndex=0; //三角滑块索引
        var theSubFileSliderIndex=0;//文件滑块索引
        centerPoint=Qt.point( themidX, themidY );


        var moveStepDis=(axisX.max-axisX.min)*2/fftCount1;
        if(moveStepDis<0.3)
            moveStepDis=0.3;


        switch(event.key)
        {
        case Qt.Key_Up:
            view.scrollDown(rateY_btn);
            markSlider.setMarkRange()
            updateCharts()

            event.accepted=true;//阻止事件继续传递
            break;
        case Qt.Key_Down:
            view.scrollUp(rateY_btn);
            markSlider.setMarkRange();
            updateCharts();
            //console.info("========RtSpectrum.qml收到↓");
            event.accepted=true;//阻止事件继续传递
            break;
        case Qt.Key_Left:

            if((axisX.max < xAxisMax)&&(axisX.min > xAxisMin))
            {

                console.info("fftCount1-------"+fftCount1);
                console.info("axisX.max-axisX.min==="+(axisX.max-axisX.min));
                console.info("xAxisMax-xAxisMin==="+(xAxisMax-xAxisMin));
                view.scrollLeft(rateX_btn*moveStepDis)
            }

            markSlider.setMarkRange();
            updateCharts();
            event.accepted=true;//阻止事件继续传递

            break;
        case Qt.Key_Right:

            if(axisX.min<0)//防止出现负数
            {
                axisX.min=0;
            }
            if((axisX.max <= xAxisMax)&&(axisX.min >= xAxisMin))
            {
                console.info("fftCount1-------"+fftCount1);
                console.info("axisX.max-axisX.min==="+(axisX.max-axisX.min));
                console.info("xAxisMax-xAxisMin==="+(xAxisMax-xAxisMin));
                view.scrollRight(rateX_btn*moveStepDis);
            }
            markSlider.setMarkRange();
            updateCharts();
            event.accepted=true;//阻止事件继续传递
            //console.info("========RtSpectrum.qml收到→");
            break;

        case Qt.Key_Enter://放大
            view.wheelZoomXY_ByBtn(true, centerPoint, true,  zoomXY);
            event.accepted=true;//阻止事件继续传递

            break;
        case Qt.Key_PageDown://放大
            view.wheelZoomXY_ByBtn(true, centerPoint, true,  zoomXY);
            event.accepted=true;//阻止事件继续传递

            break;
        case Qt.Key_Space://缩小
            view.wheelZoomXY_ByBtn(true, centerPoint, false,  zoomXY);
            event.accepted=true;//阻止事件继续传递
            //console.info("========RtSpectrum.qml收到Key_Space");
            break;
        case Qt.Key_PageUp://缩小
            view.wheelZoomXY_ByBtn(true, centerPoint, false,  zoomXY);
            event.accepted=true;//阻止事件继续传递
            //console.info("========RtSpectrum.qml收到滚轮缩小");
            break;
        case Qt.Key_Escape://焦点切换到 scopeView

            if(theScopeViewEle)
            {

                theScopeViewEle.focus=true;//焦点重置为ScopeView

                console.info("========RtSpectrum.qml收到Key_Escape,焦点交给了:"+theScopeViewEle);
            }
            event.accepted=true;//阻止事件继续传递
            break;
            //Maker-->箭头
            //case Qt.Key_F18:
        case Qt.Key_F12:
            //console.info("※◇※◇※※◇※◇※※◇※◇※RtSpectrum.qml收到Maker-->箭头消息※◇※◇※※◇※◇※※◇※◇※");
            theSubTriangleIndex=getTriangleEleIndex();

            theSubFileSliderIndex=(++theSubTriangleIndex)%(noCheckbuttonEleArray.length);
            if(theSubFileSliderIndex<uiSliderIndex)
            {
                theSubFileSliderIndex=uiSliderIndex+theSubFileSliderIndex;
            }
            if(noCheckbuttonEleArray[theSubFileSliderIndex])
            {
                noCheckbuttonEleArray[theSubFileSliderIndex].focus=true;
            }
            event.accepted=true;//阻止事件继续传递
            break;
        case Qt.Key_F1:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!RtSpectrum.qml收到C_FREQUENCY_CHANNEL信号!!!!!");
            Com.clearTopPage(root);
            analyzeMenu.focus=true;
            analyzeMenu.state="SHOW";

            console.info("----RtSpectrum.qml响应 ◇分析参数◇ 完毕----");
            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F5:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!RtSpectrum.qml收到C_SPAN_X_SCALE!!!!!");

            //idScopeView.getPeakAndmarkEle();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                //更新slider和checkButton
                idScopeView.whichTypePageOfEle.getAllsliders();
                idScopeView.whichTypePageOfEle.getAllcheckButtons();
                idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;
                idScopeView.whichTypePageOfEle.zoomXY="x";
                console.info("----RtSpectrum.qml响应 ◇C_SPAN_X_SCALE◇ 完毕----");
            }
            else
            {
                console.info("----RtSpectrum.qml 图谱不存在！无法响应X轴缩放----");
                console.info(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0]);
            }

            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F9:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!RtSpectrum.qml收到C_AMPLITUDE_Y_SCALE!!!!!");


            if(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;
                idScopeView.whichTypePageOfEle.zoomXY="y";
                console.info("----RtSpectrum.qml响应 ◇C_AMPLITUDE_Y_SCALE◇ 完毕----");
            }
            else
            {
                console.info("#####RtSpectrum.qml 图谱不存在！无法响应Y轴缩放######");
                console.info(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0]);
            }
            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;

        case Qt.Key_F15:
            //case Qt.Key_F2:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!RtSpectrum.qml收到C_MARKER!!!!!");
            console.info("                 ");
            console.info("------------------ ----------- ");
            ////////////////////////

            //idScopeView.judgeVisiblePage();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.peakPointBtn)
            {
                idScopeView.peakPointBtn.checkboxClick();
                root.getAllsliders();//先checkboxClick()再getAllsliders
                //绝对值转换为相对值
                markSlider.handle1Value=(fftData.peakPoint0.x-axisX.min)/(axisX.max-axisX.min);
                //console.info("Key_F2触发※※※※※fftData.peakPoint0.x※※※※※"+fftData.peakPoint0.x);
                markSlider.handle2Value=(fftData.peakPoint1.x-axisX.min)/(axisX.max-axisX.min);
                markSlider.handle3Value=(fftData.peakPoint2.x-axisX.min)/(axisX.max-axisX.min);
                console.info("----RtSpectrum.qml响应  ◇C_MARKER◇  完毕----");
            }
            //////////////////////

            event.accepted=true;
            break;
            //case Qt.Key_F3:
        case Qt.Key_F16:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!RtSpectrum.qml收到C_PEAK_SEARCH!!!!!");


            if((idScopeView.peakPointBtn)&&(!idScopeView.peakPointBtn.checked))
            {
                idScopeView.peakPointBtn.checkboxClick();
                root.getAllsliders();//先checkboxClick()再getAllsliders
                //绝对值转换为相对值
                markSlider.handle1Value=(fftData.peakPoint0.x-axisX.min)/(axisX.max-axisX.min);
                console.info("Key_F3触发○○○○○○○○○fftData.peakPoint0.x○○○○○○○○○"+fftData.peakPoint0.x);
                markSlider.handle2Value=(fftData.peakPoint1.x-axisX.min)/(axisX.max-axisX.min);
                markSlider.handle3Value=(fftData.peakPoint2.x-axisX.min)/(axisX.max-axisX.min);
            }
            if(idScopeView.markBtn)
            {

                idScopeView.markBtn.checkboxClick();
                //焦点给第一个三角滑块
                root.getAllsliders();//必须重新激活三角滑块
                if((root.uiSliderIndex>=0)&&(root.uiSliderIndex<root.noCheckbuttonEleArray.length)&&root.noCheckbuttonEleArray[root.uiSliderIndex].visible)
                {
                    root.noCheckbuttonEleArray[root.uiSliderIndex].focus=true;
                }

                //绝对值转换为相对值
                markSlider.handle1Value=(fftData.peakPoint0.x-axisX.min)/(axisX.max-axisX.min);
                console.info("●●●●●●●●●●fftData.peakPoint0.x●●●●●●●●●●"+fftData.peakPoint0.x);
                markSlider.handle2Value=(fftData.peakPoint1.x-axisX.min)/(axisX.max-axisX.min);
                markSlider.handle3Value=(fftData.peakPoint2.x-axisX.min)/(axisX.max-axisX.min);
            }
            console.info("----RtSpectrum.qml响应  ◇C_PEAK_SEARCH◇   完毕----");

            console.info("------------------ ----------- ");
            event.accepted=true;
            break;

            //case Qt.Key_End://呼出菜单
        case Qt.Key_F13:
            if(idBottomPannel.menuBtn)
            {
                idBottomPannel.menuBtn.clicked();
            }
            console.info("●●●●●●RtSpectrum.qml 呼出菜单按钮触发●●●●●●idBottomPannel.menuBtn"+idBottomPannel.menuBtn);
            event.accepted=true;
            break;
            //case Qt.Key_Insert://模式切换
        case Qt.Key_F10:
            if(idBottomPannel.modeSwitch)
            {
                idBottomPannel.modeSwitch.clicked();
            }
            console.info("●●●●●●RtSpectrum.qml 模式切换按钮触发●●●●●●idBottomPannel.modeSwitch"+idBottomPannel.modeSwitch);
            event.accepted=true;
            break;
            //        case Qt.Key_Delete://参数更新
        case Qt.Key_F19:
            if(idBottomPannel.paramsUpdate)
            {
                idBottomPannel.paramsUpdate.clicked();
            }
            console.info("●●●●●●RtSpectrum.qml  参数更新按钮触发●●●●●●Com.paramsUpdate"+idBottomPannel.paramsUpdate);
            console.info("----RtSpectrum.qml 响应 ◇C_PRESET◇ 完毕----");
            event.accepted=true;
            break;
        case Qt.Key_1://数字1
            if(root.noCheckbuttonEleArray[1])
            {
                root.noCheckbuttonEleArray[1].focus=true;//multisider1获得焦点
                console.info("√√√√√√√√√RtSpectrum.qml 文件滑块1 获得焦点√√√√√√√√√")
            }

            event.accepted=true;
            break;
        case Qt.Key_2://数字2
            if(root.noCheckbuttonEleArray[2])
            {
                root.noCheckbuttonEleArray[2].focus=true;//multisider1获得焦点
                console.info("√√√√√√√√√RtSpectrum.qml 文件滑块1 获得焦点√√√√√√√√√")
            }

            event.accepted=true;
            break;
        case Qt.Key_3://数字3
            if(root.noCheckbuttonEleArray[3])
            {
                root.noCheckbuttonEleArray[3].focus=true;//multisider1获得焦点
                console.info("√√√√√√√√√RtSpectrum.qml 文件滑块1 获得焦点√√√√√√√√√")
            }

            event.accepted=true;
            break;
        case Qt.Key_4://数字4

            if(root.uiCheckButtonArray[0]&&(!root.uiCheckButtonArray[0].disabled))
            {
                if(typeof root.uiCheckButtonArray[0].tips!==undefined)
                {
                    checkButtonTipsStr=root.uiCheckButtonArray[0].tips;
                }
                if(checkButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=root.uiCheckButtonArray[0];
                    break;
                }
                else if(checkButtonTipsStr.indexOf("标尺")!==-1)
                {

                    markBtn=root.uiCheckButtonArray[0];
                    break;

                }

                //先触发点击checkbutton然后调用getAllsliders
                root.uiCheckButtonArray[0].checkboxClick();
                root.getAllsliders();//再次刷新slider


                console.info("RtSpectrum.qml "+checkButtonTipsStr+"触发点击事件");
            }
            event.accepted=true;
            break;
        case Qt.Key_5://数字5

            if(root.uiCheckButtonArray[1]&&(!root.uiCheckButtonArray[1].disabled))
            {
                if(typeof root.uiCheckButtonArray[1].tips!==undefined)
                {
                    checkButtonTipsStr=root.uiCheckButtonArray[1].tips;
                }
                if(checkButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=root.uiCheckButtonArray[1];
                    break;
                }
                else if(checkButtonTipsStr.indexOf("标尺")!==-1)
                {

                    markBtn=root.uiCheckButtonArray[1];
                    break;

                }

                //先触发点击checkbutton然后调用getAllsliders
                root.uiCheckButtonArray[1].checkboxClick();
                root.getAllsliders();//再次刷新slider

                console.info("RtSpectrum.qml "+checkButtonTipsStr+"触发点击事件");
            }
            event.accepted=true;
            break;
        case Qt.Key_6://数字6

            if(root.uiCheckButtonArray[2]&&(!root.uiCheckButtonArray[2].disabled))
            {
                if(typeof root.uiCheckButtonArray[2].tips!==undefined)
                {
                    checkButtonTipsStr=root.uiCheckButtonArray[2].tips;
                }
                if(checkButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=root.uiCheckButtonArray[2];
                    break;
                }
                else if(checkButtonTipsStr.indexOf("标尺")!==-1)
                {

                    markBtn=root.uiCheckButtonArray[2];
                    break;

                }
                //先触发点击checkbutton然后调用getAllsliders
                root.uiCheckButtonArray[2].checkboxClick();
                root.getAllsliders();//再次刷新slider
                console.info("RtSpectrum.qml "+checkButtonTipsStr+"触发点击事件");
            }
            event.accepted=true;
            break;
        case Qt.Key_7://数字7

            if(root.uiCheckButtonArray[3]&&(!root.uiCheckButtonArray[3].disabled))
            {
                if(typeof root.uiCheckButtonArray[3].tips!==undefined)
                {
                    checkButtonTipsStr=root.uiCheckButtonArray[3].tips;
                }
                if(checkButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=root.uiCheckButtonArray[3];
                    break;
                }
                else if(checkButtonTipsStr.indexOf("标尺")!==-1)
                {

                    markBtn=root.uiCheckButtonArray[3];
                    break;

                }
                //先触发点击checkbutton然后调用getAllsliders
                root.uiCheckButtonArray[3].checkboxClick();
                root.getAllsliders();//再次刷新slider
                console.info("RtSpectrum.qml "+checkButtonTipsStr+"触发点击事件");
            }
            event.accepted=true;
            break;
        case Qt.Key_8://数字8

            if(root.uiCheckButtonArray[4]&&(!root.uiCheckButtonArray[4].disabled))
            {
                if(typeof root.uiCheckButtonArray[4].tips!==undefined)
                {
                    checkButtonTipsStr=root.uiCheckButtonArray[4].tips;
                }
                if(checkButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=root.uiCheckButtonArray[4];
                    break;
                }
                else if(checkButtonTipsStr.indexOf("标尺")!==-1)
                {

                    markBtn=root.uiCheckButtonArray[4];
                    break;

                }
                //先触发点击checkbutton然后调用getAllsliders
                root.uiCheckButtonArray[4].checkboxClick();
                root.getAllsliders();//再次刷新slider

                console.info("RtSpectrum.qml "+checkButtonTipsStr+"触发点击事件");
            }
            event.accepted=true;
            break;
        case Qt.Key_Exclam://功能键1

        case Qt.Key_At://功能键2

        case Qt.Key_NumberSign://功能键3

        case Qt.Key_Dollar://功能键4

        case Qt.Key_Percent://功能键5

        case Qt.Key_AsciiCircum://功能键6

        case Qt.Key_Space://功能键 return
            idScopeView.focusPageOfrightControl.focus=true;
            idScopeView.focusPageOfrightControl.state="SHOW";
            console.info("※※※※※RtSpectrum.qml  功能键呼出菜单※※※※※"+idScopeView.focusPageOfrightControl);
            event.accepted=true;
            break;
        default:
            globalConsoleInfo("========RtSpectrum.qml收到按键消息#####"+event.key);
            break;
        }

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
    // Add data dynamically to the series
    Component.onCompleted: {
        //根据分辨率计算横坐标需要精确的位数
        chartCtrl.setLineSeriesPenWidth(series1, 1)
        chartCtrl.setAxisGridLinePenStyle(axisX, Qt.DotLine)//DashLine
        chartCtrl.setAxisGridLinePenStyle(axisY, Qt.DotLine)

        //axisY.min = Settings.reflevelMin()
        //axisY.max = Settings.reflevelMax()
	
	        //读取相应slider和checkButton控件
        getAllsliders();
        getAllcheckButtons();
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

    //设置操作焦点是X轴
    function setSpanXScale()
    {
        zoomXY = "x"
    }

    //设置操作焦点是Y轴
    function setSpanYScale()
    {
        zoomXY = "y"
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

        //dataSource.setForceRefresh()//deprecate
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
        //更新slider和checkButton
        getAllsliders();
        getAllcheckButtons();
    }

    //获取所有非checkButton元素
    function getAllsliders()
    {

        noCheckbuttonEleArray.splice(0,noCheckbuttonEleArray.length);
        noCheckbuttonEleArray=[];
        noCheckbuttonEleArray.norepeatpush(view);//第一个就是图谱
        var UiMultSliderObj=Com.getNamedELementOfComponentArray(root,"UiMultSlider");
        if(Com.isArray(UiMultSliderObj))
        {
            for(var jj=0;jj<UiMultSliderObj.length;jj++)//添加UiMultSliderObj
            {

                if(UiMultSliderObj[jj].visible)
                {
                    noCheckbuttonEleArray.norepeatpush(UiMultSliderObj[jj]);
                    globalConsoleInfo("!!!RtSpectrum.qml数组 添加multiSlider--"+jj);
                }
            }
        }
        else if(UiMultSliderObj!==undefined)
        {

            if(UiMultSliderObj.visible)
            {
                noCheckbuttonEleArray.norepeatpush(UiMultSliderObj);
                globalConsoleInfo("####RtSpectrum.qml 直接添加multiSlider--");
            }
        }

        uiSliderIndex=noCheckbuttonEleArray.length;//获得UiSlider索引号
        var UiSliderObj=Com.getNamedELementOfComponentArray(root,"UiSlider");//添加UiSlider


        if(Com.isArray(UiSliderObj))
        {
            for(var kk=0;kk<UiSliderObj.length;kk++)
            {



                for(var uu=0;uu<UiSliderObj[kk].children.length;uu++)
                {

                    if(UiSliderObj[kk].children[uu].objectName==="triangleEle")
                    {

                        if(UiSliderObj[kk].children[uu].visible)//只添加可视的三角滑块
                        {
                            noCheckbuttonEleArray.norepeatpush(UiSliderObj[kk].children[uu]);
                        }

                    }
                }


                globalConsoleInfo("-----RtSpectrum.qml 添加三角滑块 triangleEle "+kk);
            }
        }
        else if(UiSliderObj!==undefined)
        {



            for(var nn=0;nn<UiSliderObj.children.length;nn++)
            {

                if(UiSliderObj.children[nn].objectName==="triangleEle")
                {

                    if(UiSliderObj.children[nn].visible)
                    {
                        noCheckbuttonEleArray.norepeatpush(UiSliderObj.children[nn]);
                    }

                }
                globalConsoleInfo("======RtSpectrum.qml 添加triangleEle "+nn);
            }



        }



    }



    //获取所有checkButton元素
    function getAllcheckButtons()
    {
        //先清空
        uiCheckButtonArray.splice(0,uiCheckButtonArray.length);
        uiCheckButtonArray=[];
        for(var kk=0;kk<root.children.length;kk++)
        {

            var UiCheckButton_Str=root.children[kk].toString();
            if((UiCheckButton_Str.indexOf("UiCheckButton")!==-1)&&(root.children[kk].visible))
            {
                uiCheckButtonArray.norepeatpush(root.children[kk]);//UiCheckButton_QMLTYPE_15元素添加
            }
        }



    }


    //获取当前获得焦点的三角滑块索引
    function getTriangleEleIndex()
    {
        var focusTriangleIndex=0;
        for(var kk=uiSliderIndex;kk<noCheckbuttonEleArray.length;kk++)
        {

            if(noCheckbuttonEleArray[kk].focus)
            {
                focusTriangleIndex=kk;
                break;
            }
        }
        return focusTriangleIndex;

    }


    //获取当前文件拖动滑块索引
    function getFileMultiSilderIndex()
    {
        var focusFlieSliderIndex=0;
        for(var kk=0;kk<uiSliderIndex;kk++)
        {

            if(noCheckbuttonEleArray[kk].focus)
            {
                focusFlieSliderIndex=kk;
                break;
            }
        }
        return focusFlieSliderIndex;

    }
}
