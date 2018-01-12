import QtQuick 2.0
import QtCharts 2.1
import QtQuick.Controls 2.2

import "../qml/UI"

import "../qml/Inc.js" as Com

Rectangle {
    id: root
    color: "black"
    property int  xAxisMax: 10000      //idx
    property int  xAxisMin: 0      //idx
    property int  yAxisMax: 33000     //dBm
    property int  yAxisMin: -33000      //dBm
    property int  centerFreq: 70    //MHz
    property int  resolution: 10000 //Hz
    property int  bandwidth: 1000
    property int  xPrecision: 0     //小数精确的位数
    property int  yPrecision: 0
    property int  zoomStep: 100
    property string  zoomXY: "x"
    property bool  openGL: true
    property bool  fullMode: true    //全尺寸显示
    property bool  realTimeMode: false   //实时刷新显示
    property color seriesColor1: Com.series_color1
    property color seriesColor2: Com.series_color2
    property color seriesColor3: Com.series_color3
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

    Text {
        id: xTitle
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 44
        anchors.right: parent.right
        anchors.rightMargin: 20
        font.pixelSize: 12
        color:"white"
        font.family: "Calibri"
        text: qsTr("Index")
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
        text: qsTr("Value")
    }

    ChartView {
        id: view
        //title: "Two Series, Common Axes"
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 9

        backgroundColor: "#00FFFFFF"
        animationOptions: ChartView.NoAnimation
        antialiasing: false
        legend{
            visible: false
        }
        property point hoveredPoint: Qt.point( 0, 0 )
        property bool  hovered: false
        ValueAxis {
            id: idaxisX
            min: xAxisMin
            max: xAxisMax
            tickCount: 11
            gridLineColor: "#4C7049"
            labelFormat:"%d"
        }

        ValueAxis {
            id: idaxisY
            min: yAxisMin
            max: yAxisMax
            tickCount: fullMode ? 21 : 11
            labelFormat:"%d";
            gridLineColor: "#4C7049"
        }

        LineSeries {
            id: series1
            axisX: idaxisX
            axisY: idaxisY
            color: seriesColor1
            style:Qt.SolidLine
            useOpenGL: openGL
            onHovered: {
                //console.log("onClicked: " + point.x + ", " + point.y);
            }
        }
        LineSeries {
            id: series2
            axisX: idaxisX
            axisY: idaxisY
            color: seriesColor2
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

                //console.log("hoveredPoint:"+hoveredPoint+" pressed:"+pressed)

                if( hoveredPoint.x >= idaxisX.min && hoveredPoint.x <= idaxisX.max
                        && hoveredPoint.y >= idaxisY.min && hoveredPoint.y <= idaxisY.max)
                {
                    zoomXY = "x"
                    //hoveredPoint.x = hoveredPoint.x.toFixed(xPrecision);
                    view.hovered = true
                    view.hoveredPoint = hoveredPoint                   
                }else {
                    view.hovered = false
                }
                if(hoveredPoint.x < idaxisX.min && hoveredPoint.y >= idaxisY.min && hoveredPoint.y <= idaxisY.max)
                {
                    zoomXY = "y"
                    view.hovered = true
                    hoveredPoint.y = hoveredPoint.y.toFixed(0);
                    view.hoveredPoint = hoveredPoint
                }
                if(pressed)//drag
                {
                    var rateY = (yAxisMax-yAxisMin)/(idaxisY.max - idaxisY.min)
                    var currentRangeX = idaxisX.max - idaxisX.min

                    //console.log("hoveredPoint.y:"+hoveredPoint.y + " sPoint.y:"+sPoint.y+" rateY:"+rateY);
                    //console.log(hoveredPoint.y - sPoint.y);

                    //view.scrollDown(rateY*(hoveredPoint.y - sPoint.y))

                    if(hoveredPoint.y >= sPoint.y)
                        view.scrollDown(rateY)
                    else
                        view.scrollUp(rateY)

                    if(currentRangeX < bandwidth)
                    {
                        var rateX = bandwidth/currentRangeX
                        if(idaxisX.max < xAxisMax && hoveredPoint.x < sPoint.x) {
                            view.scrollLeft(rateX*(hoveredPoint.x - sPoint.x))
                        }
                        if(idaxisX.min > xAxisMin && hoveredPoint.x > sPoint.x){
                            view.scrollRight(rateX*(sPoint.x - hoveredPoint.x))
                        }
                    }
                }
            }
            onWheel: {
                view.wheelZoomXY(view.hovered, wheel, view.hoveredPoint,  zoomXY)
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

                }
            }

        }//!--MouseArea END

        function wheelZoomXY( enable, wheel, point, XY)
        {
            if(!enable)
                return
            var axis, axisMin, axisMax
            if(XY === "x"){
                axis = idaxisX
                axisMin = xAxisMin
                axisMax = xAxisMax
            }else{
                axis = idaxisY
                axisMin = yAxisMin
                axisMax = yAxisMax
            }
            if( wheel.angleDelta.y > 0 ) {
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
        }//!--function wheelZoomXY END

        function zoom_In( hoveredPoint , XY) {
            var axis, axisMin, axisMax, hoveredXY
            if(XY === "x"){
                axis = idaxisX
                axisMin = xAxisMin
                axisMax = xAxisMax
                hoveredXY = hoveredPoint.x
            }else{
                axis = idaxisY
                axisMin = yAxisMin
                axisMax = yAxisMax
                hoveredXY = hoveredPoint.y
            }

            var left  = hoveredXY - axis.min
            var right = axis.max - hoveredXY

            var scale = parseFloat( left / right )

            var step  = zoomStep
            if(XY === "y")
                step  = step * 10

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
            if(tempMax - tempMin > 10){
                axis.min =  tempMin
                axis.max =  tempMax
            }
        }//!--function zoom_In END

        function zoom_Out( hoveredPoint, XY ) {
            var axis, axisMin, axisMax, hoveredXY
            if(XY === "x"){
                axis = idaxisX
                axisMin = xAxisMin
                axisMax = xAxisMax
                hoveredXY = hoveredPoint.x
            }else{
                axis = idaxisY
                axisMin = yAxisMin
                axisMax = yAxisMax
                hoveredXY = hoveredPoint.y
            }
            var left  = hoveredXY - axis.min
            var right = axis.max - hoveredXY

            var scale = parseFloat( left / right )

            var step  = zoomStep
            if(XY === "y")
                step  = step * 10

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


    //ctrl panel
    UiCheckButton{
        id:btnZoomReset
        anchors.bottom: seriesSignal2.top
        anchors.bottomMargin: 2
        anchors.right: xRulerCtrl.right
        iconFontText:"\uf066"
        textColor: "#D3D4D4"
        mode:"button"
        checked: true
        tips:"复位显示时域波形"
        onClicked:
        {
            idaxisX.min = xAxisMin
            idaxisX.max = xAxisMax
            idaxisY.min = yAxisMin
            idaxisY.max = yAxisMax
            checked = true
        }
        //ToolTip.visible: checked
        //ToolTip.text: qsTr("Save the active project")
    }
    UiCheckButton{
        id:seriesSignal2
        anchors.bottom: seriesSignal1.top
        anchors.bottomMargin: 2
        anchors.right: xRulerCtrl.right
        iconFontText:"\uf159"
        textColor: seriesColor2
        checked: true
        tips:"显示/关闭Q值波形"
        onClicked:
        {
            series2.visible = checked
        }
    }
    UiCheckButton{
        id:seriesSignal1
        anchors.bottom: xRulerCtrl.top
        anchors.bottomMargin: 2
        anchors.right: xRulerCtrl.right
        iconFontText:"\uf159"
        textColor: seriesColor1
        checked: true
        tips:"显示/关闭I值波形"
        onClicked:
        {
            series1.visible = checked
        }
    }
    UiCheckButton{
        id:xRulerCtrl
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80
        anchors.right: parent.right
        anchors.rightMargin: 10
        iconFontText:"\uf05b"
        textColor: "#E0B510"
        disabled: true
        tips:"显示/关闭Peak点"
        onClicked:
        {

        }
    }//!--ctrl panel end


    UiMultSlider {
        id: fileSlider
        anchors.top: parent.top
        anchors.topMargin: 32
        anchors.left: parent.left
        anchors.leftMargin: 40
        width: 100
        min:idaxisX.min
        max:idaxisX.max
        visible: series1.visible && !realTimeMode
        handleColor: Com.series_color1
        onValueChanged: {
            var percent = value.toFixed(3);
            dataSource.setFileOffset("series1", percent)
            //dataSource.updateFreqDodminFromFile(series1, Settings.historyFile1())
            dataSource.updateTimeDomainFromFile(series1, series2, Settings.historyFile1())
        }
        onHandleReleased:
        {

        }
        function setMarkRange()
        {
            var lpoint = Qt.point(idaxisX.min, 0);
            var rpoint = Qt.point(idaxisX.max, 0);
            var lmargin = view.mapToPosition(lpoint, series1)
            var rmargin = view.mapToPosition(rpoint, series1)

            fileSlider.anchors.leftMargin = lmargin.x
            fileSlider.width = rmargin.x-lmargin.x

        }
    }



    // Add data dynamically to the series
    Component.onCompleted: {
        //根据分辨率计算横坐标需要精确的位数
        chartCtrl.setLineSeriesPenWidth(series1, 1)
        chartCtrl.setAxisGridLinePenStyle(idaxisX, Qt.DotLine)//DashLine
        chartCtrl.setAxisGridLinePenStyle(idaxisY, Qt.DotLine)
        //updateParams(); //由上层更新初始参数


        series1.visible = true
        series2.visible = true
        dataSource.updateTimeDomainFromFile(series1, series2, Settings.historyFile1())

    }
    onVisibleChanged: {

    }

    onWidthChanged:
    {
        fileSlider.setMarkRange()
    }

    function updateParams()
    {

        series1.visible = true
        series2.visible = true
        seriesSignal1.checked = true
        seriesSignal1.disabled = false
        seriesSignal2.checked = true
        seriesSignal2.disabled = false
        fileSlider.setMarkRange()
        fileSlider.value = dataSource.getFileOffset(0)
        dataSource.updateTimeDomainFromFile(series1, series2, Settings.historyFile1())

    }
}
