import QtQuick 2.0
import QtCharts 2.1
import QtQuick.Controls 2.2

import "../qml/UI"

import "../qml/Inc.js" as Com

Rectangle {
    id: root
    color: "black"
    property int  chIndex:  0
    property int  xAxisMax: 10000     //idx
    property int  xAxisMin: 0         //idx
    property int  yAxisMax: 33000     //
    property int  yAxisMin: -33000    //
    property int  centerFreq: 70    //MHz
    property int  resolution: 10000 //Hz
    property int  bandwidth: 10000  //最大点数,和频谱图的带宽不一样
    property int  xPrecision: 0     //小数精确的位数
    property int  yPrecision: 0
    property int  zoomStep: 100
    property string  zoomXY: "x"
    property bool  openGL: true
    property bool  altPress:true
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

                    if(point.y >= sPoint.y)
                        view.scrollUp(rateY)
                    else
                        view.scrollDown(rateY)

                    if(currentRangeX < bandwidth)
                    {
                        var rateX = currentRangeX/bandwidth
                        if(idaxisX.max < xAxisMax && point.x < sPoint.x) {
                            view.scrollLeft(rateX*(point.x - sPoint.x))
                        }
                        if(idaxisX.min > xAxisMin && point.x > sPoint.x){
                                view.scrollRight(rateX*(sPoint.x - point.x))
                        }
                    }
                }
            }
            onWheel: {
                var isZoomIn = false
                if (wheel.angleDelta.y > 0)
                    isZoomIn = true
                view.wheelZoomXY(view.hovered, isZoomIn, view.hoveredPoint,  zoomXY)
            }
            onPressed: {
                if(mouse.button === Qt.LeftButton){
                    sPoint.x = mouse.x
                    sPoint.y = mouse.y
                }

            }
            onReleased: {
                if(mouse.button === Qt.LeftButton){
                    ePoint.x = mouse.x
                    ePoint.y = mouse.y
                }
            }

        }//!--MouseArea END

        function wheelZoomXY( enable, isZoomIn, point, XY)
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
            if(  isZoomIn ) {
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
            dataSource.setFileOffset("series1", percent);
            //dataSource.updateFreqDodminFromFile(series1, Settings.historyFile1())
            dataSource.updateTimeDomainFromFile(series1, series2, Settings.historyFile1());

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





    //频谱图控制按钮
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
            //workZoomXStep()
            var centerPoint = Qt.point( 0, 0 )
            centerPoint.x = (idaxisX.max-idaxisX.min) / 2 + idaxisX.min
            centerPoint.y = (idaxisY.max-idaxisY.min) / 2 + idaxisY.min
            //console.log("xSpanIn clicked centerPoint:",centerPoint)
            view.wheelZoomXY(true, true, centerPoint,  "x");

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
            //workZoomXStep()
            var centerPoint = Qt.point( 0, 0 )
            centerPoint.x = (idaxisX.max-idaxisX.min) / 2 + idaxisX.min
            centerPoint.y = (idaxisY.max-idaxisY.min) / 2 + idaxisY.min
             //console.log("xSpan clicked centerPoint:",centerPoint)

            view.wheelZoomXY(true, false, centerPoint,  "x");

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
            centerPoint.x = (idaxisX.max-idaxisX.min) / 2 + idaxisX.min
            centerPoint.y = (idaxisY.max-idaxisY.min) / 2 + idaxisY.min
             //console.log("xSpan clicked centerPoint:",centerPoint)
            view.wheelZoomXY(true, true, centerPoint,  "y");

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
            centerPoint.x = (idaxisX.max-idaxisX.min) / 2 + idaxisX.min
            centerPoint.y = (idaxisY.max-idaxisY.min) / 2 + idaxisY.min
             //console.log("xSpan clicked centerPoint:",centerPoint)

            view.wheelZoomXY(true, false, centerPoint,  "y");

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
            var rateY = (yAxisMax-yAxisMin)/(idaxisY.max - idaxisY.min)
            view.scrollDown(rateY*2)
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
            var rateY = (yAxisMax-yAxisMin)/(idaxisY.max - idaxisY.min)
            view.scrollDown(-rateY*2)
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
            var currentRangeX = idaxisX.max - idaxisX.min
            if(currentRangeX < bandwidth)
            {
                var rateX = bandwidth/currentRangeX
                if(idaxisX.max < xAxisMax) {
                    view.scrollRight(rateX*2)
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
            var currentRangeX = idaxisX.max - idaxisX.min
            if(currentRangeX < bandwidth)
            {
                var rateX = bandwidth/currentRangeX
                if(idaxisX.min > xAxisMin){
                    view.scrollLeft(rateX*2)
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
        disabled: true
        width: 22
        height: width
        onClicked:
        {
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
        disabled: true
        width: 22
        height: width
        onClicked:
        {
        }
    }
    UiCheckButton{
        id:opFileSelect
        anchors.bottom: btnZoomReset.top
        anchors.bottomMargin: 2
        anchors.right: root.right
        anchors.rightMargin: 10
        iconFontText:"\uf1de"
        textColor: "#daae00"
        checked: true
        mode:"button"
        tips:"切换操作的文件"
        disabled: true
        property int curFileIdx: 0
        onClicked:
        {
            checked = true
            fileSlider.sliderOpacity = 1
            opFileSelect.textColor = seriesColor1
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
            if(fileSlider.visible)
            {
                var val = fileSlider.value //fileSlider1.value;
                val += 0.001
                if(val > 1)
                    val = 1;
                fileSlider.value = val
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
            if(fileSlider.visible)
            {
                var val =  fileSlider.value //fileSlider1.value;
                val -= 0.001
                if(val < 0)
                    val = 0;
                fileSlider.value = val
            }
        }
    }
    //！--频谱图控制按钮--END



    // Add data dynamically to the series
    Component.onCompleted: {
        //根据分辨率计算横坐标需要精确的位数
        chartCtrl.setLineSeriesPenWidth(series1, 1)
        chartCtrl.setAxisGridLinePenStyle(idaxisX, Qt.DotLine)//DashLine
        chartCtrl.setAxisGridLinePenStyle(idaxisY, Qt.DotLine)
        //updateParams(); //由上层更新初始参数

        series1.visible = true
        series2.visible = true
        dataSource.updateTimeDomainFromFile(series1, series2, Settings.historyFile1());

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



    /**********************************************************
    以下函数为对外操作接口,直接调用即可,可视需求自由修改
    原则:接口函数在本级禁止互相调用， 由上层使用者互相调用
    统一返回值定义:true 调用成功  false:调用无效
    ***********************************************************/
    //选择 X 轴缩放
    function tiSetXSpan(ch, en)
    {
        if(ch !== chIndex)
            return false
        console.log("tiSetXSpan ch:", ch, en)
        xSpanIn.disabled = !en
        xSpanOut.disabled = !en
        return true
    }
    //选择 Y 轴缩放
    function tiSetYSpan(ch, en)
    {
        if(ch !== chIndex)
            return false
        console.log("tiSetYSpan ch:",ch, en)
        ySpanIn.disabled = !en
        ySpanOut.disabled = !en
        return true
    }
    //放大操作
    function tiSetZoomIn(ch)
    {

        if(ch !== chIndex)
            return false
        if(!xSpanIn.disabled)
        {
            xSpanIn.clicked()
            console.log("tiSetZoomIn X ch:",ch)
            return true
        }
        if(!ySpanIn.disabled)
        {
            ySpanIn.clicked()
            console.log("tiSetZoomIn Y ch:",ch)
            return true
        }
        return false
    }
    //缩小操作
    function tiSetZoomOut(ch)
    {
        if(ch !== chIndex)
            return false
        if(!xSpanOut.disabled)
        {
            xSpanOut.clicked()
            console.log("tiSetZoomOut X ch:",ch)
            return true
        }
        if(!ySpanOut.disabled)
        {
            ySpanOut.clicked()
            console.log("tiSetZoomOut Y ch:",ch)
            return true
        }
        return false
    }
    //平移操作
    function tiSetDragMove(ch, direction)
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
        console.log("tiSetDragMove direction:",direction,"ch:",ch)
        btnArray[idx].clicked()
        return true
    }
    //切换选择操作的文件
    function tiSetSwitchFile(ch)
    {
        if(ch !== chIndex)
            return false
        if(opFileSelect.disabled)
            return false
        console.log("tiSetSwitchFile switch ch:",ch)
        opFileSelect.clicked()
        return true
    }
    //设置是否允许切换选择文件
    function tiSetSwitchFileEnable(ch, en)
    {
        if(ch !== chIndex)
            return false
        //非文件模式,直接禁用
        var mode = Settings.analyzeMode()
        if(mode < 2)
            en = false
        console.log("tiSetSwitchFileEnable enable:", en, "ch:", ch)
        //同步当前文件是否高亮
        fileSlider.sliderOpacity = (en?1:0.5)
        opFileSelect.disabled = !en
        return true
    }
    //设置允许(禁止)向前(后)读取文件
    function tiSetActiveFile(ch, en)
    {
        if(ch !== chIndex)
            return false
        if(opFileSelect.disabled)
            en = false
        console.log("tiSetActiveFile disabled:", !en, "ch:",ch)
        opFileNext.disabled = !en
        opFilePrev.disabled = !en
        return true
    }
    //左右平移文件
    function tiSetMoveFile(ch, direction)
    {
        //direction 0:left  1:right
        if(ch !== chIndex)
            return false
        if(opFileNext.disabled || opFilePrev.disabled)
            return false
        console.log("tiSetMoveFile direction:",direction, "ch:",ch)
        if(0 === direction)
            opFilePrev.clicked()
        else
            opFileNext.clicked()
        return true
    }
    function tiSetZoomReset(ch)
    {
        if(ch !== chIndex)
            return false
        btnZoomReset.clicked()
        return true
    }
}
