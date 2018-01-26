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
    property bool  altPress:true
    property bool  fullMode: true    //全尺寸显示
    property bool  realTimeMode: false   //实时刷新显示
    property color seriesColor1: Com.series_color1
    property color seriesColor2: Com.series_color2
    property color seriesColor3: Com.series_color3
    property point centerPoint: Qt.point( 0, 0 )
    property var  rightControlPannel:undefined
    property var  theScopeViewEle: undefined
    property var  noCheckbuttonEleArray:[] //存储非checkbutton元素
    property var  uiCheckButtonArray:[];//UiCheckButton按钮数组
    property int  uiSliderIndex:-1 //第一个UiSliderIndex出现的索引号

    property real  fftCount1: 40000
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



        //按键控制放大缩小
        function wheelZoomXY_ByBtn( enable, point,isZoomIn, XY)//flag表示放大还是缩小的布尔值
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

            fftCount1= (series1.count > 500)? series1.count: 500;

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


        fftCount1= (series1.count > 500)? series1.count: 500;
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
        exScopeViewEle:root.theScopeViewEle
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

        //读取相应slider和checkButton控件
        getAllsliders();
        getAllcheckButtons();
    }
    onVisibleChanged: {

    }

    onWidthChanged:
    {
        fileSlider.setMarkRange()
    }
    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{


        var rateY_btn = (yAxisMax-yAxisMin)/(idaxisY.max - idaxisY.min);
        var currentRangeX_btn = idaxisX.max - idaxisX.min;
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


        var moveStepDis=(idaxisX.max-idaxisX.min)*2/fftCount1;
        if(moveStepDis<0.3)
            moveStepDis=0.3;



        switch(event.key)
        {
        case Qt.Key_Up:
            view.scrollDown(rateY_btn);
            fileSlider.setMarkRange()
            event.accepted=true;//阻止事件继续传递

            break;
        case Qt.Key_Down:
            view.scrollUp(rateY_btn);
            fileSlider.setMarkRange()
            event.accepted=true;//阻止事件继续传递

            break;
        case Qt.Key_Left:

            if((idaxisX.max < xAxisMax)&&(idaxisX.min > xAxisMin))
            {
                view.scrollLeft(rateX_btn*0.3)
            }

            fileSlider.setMarkRange()
            event.accepted=true;//阻止事件继续传递
            //console.info("#####TiDomainWave.qml收到←");
            break;
        case Qt.Key_Right:
            globalConsoleInfo("#####TiDomainWave.qml收到Qt.Key_Right");
            if(idaxisX.min<0)//防止出现负数
            {
                idaxisX.min=0;
            }
            if((idaxisX.max <= xAxisMax)&&(idaxisX.min >= xAxisMin))
            {
                view.scrollRight(rateX_btn*0.3);
            }

            fileSlider.setMarkRange()
            event.accepted=true;//阻止事件继续传递
            //console.info("#####TiDomainWave.qml收到→");
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

            break;
        case Qt.Key_PageUp://缩小
            view.wheelZoomXY_ByBtn(true, centerPoint, false,  zoomXY);
            event.accepted=true;//阻止事件继续传递

            break;
        case Qt.Key_Escape://焦点切换到 scopeView
            if(theScopeViewEle)
            {
                theScopeViewEle.focus=true;//焦点重置为ScopeView
                globalConsoleInfo("#####TiDomainWave.qml收到Key_Escape,焦点交给了:"+theScopeViewEle);
            }
            event.accepted=true;//阻止事件继续传递
            break;
            //Maker-->箭头
            //case Qt.Key_F18:
        case Qt.Key_F12:
            //console.info("#############RtWaterFall.qml收到Maker-->箭头消息#############");
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
            console.info(root+"!!!!!!TiDomainWave.qml收到C_FREQUENCY_CHANNEL信号!!!!!");

            Com.clearTopPage(root);
            analyzeMenu.focus=true;
            analyzeMenu.state="SHOW";

            console.info("----TiDomainWave.qml响应 ◇分析参数◇ 完毕----");
            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F5:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!TiDomainWave.qml收到C_SPAN_X_SCALE!!!!!");
            //记录上一个焦点转移的页面

            //idScopeView.getPeakAndmarkEle();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                //更新slider和checkButton
                idScopeView.whichTypePageOfEle.getAllsliders();
                idScopeView.whichTypePageOfEle.getAllcheckButtons();
                idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;
                idScopeView.whichTypePageOfEle.zoomXY="x";
                console.info("----TiDomainWave.qml响应 ◇C_SPAN_X_SCALE◇ 完毕----");
            }
            else
            {
                console.info("#####TiDomainWave.qml 图谱不存在！无法响应X轴缩放######");
                console.info(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0]);
            }

            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F9:
            console.info("-----------------------------");
            console.info("                 ");


            //idScopeView.getPeakAndmarkEle();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;
                idScopeView.whichTypePageOfEle.zoomXY="y";
                console.info("----TiDomainWave.qml响应 ◇C_AMPLITUDE_Y_SCALE◇ 完毕----");
            }
            else
            {
                console.info("#####TiDomainWave.qml 图谱不存在！无法响应Y轴缩放######");
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
            console.info(root+"!!!!!!TiDomainWave.qml收到C_MARKER!!!!!");
            console.info("                 ");
            console.info("------------------ ----------- ");
            ////////////////////////

            //idScopeView.judgeVisiblePage();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.peakPointBtn)
            {
                idScopeView.peakPointBtn.checkboxClick();
                root.getAllsliders();
            }
            //////////////////////
            console.info("----TiDomainWave.qml响应  ◇C_MARKER◇  完毕----");
            event.accepted=true;
            break;
        //case Qt.Key_F3:
            case Qt.Key_F16:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!TiDomainWave.qml收到C_PEAK_SEARCH!!!!!");


            if((idScopeView.peakPointBtn)&&(!idScopeView.peakPointBtn.checked))
            {
                idScopeView.peakPointBtn.checkboxClick();
                root.getAllsliders();
            }


            if(idScopeView.markBtn)
            {

                idScopeView.markBtn.checkboxClick();
                //焦点给第一个三角滑块
                idScopeView.whichTypePageOfEle.getAllsliders();//必须重新激活三角滑块



                if((root.uiSliderIndex>=0)&&(root.uiSliderIndex<root.noCheckbuttonEleArray.length)&&root.noCheckbuttonEleArray[root.uiSliderIndex].visible)
                {
                    root.noCheckbuttonEleArray[root.uiSliderIndex].focus=true;
                }
            }
            console.info("----TiDomainWave.qml响应  ◇C_PEAK_SEARCH◇   完毕----");
            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;

            //case Qt.Key_End://呼出菜单
        case Qt.Key_F13:
            if(idBottomPannel.menuBtn)
            {
                idBottomPannel.menuBtn.clicked();
            }
            console.info("●●●●●●TiDomainWave.qml 呼出菜单按钮触发●●●●●●idBottomPannel.menuBtn"+idBottomPannel.menuBtn);
            event.accepted=true;
            break;
            //case Qt.Key_Insert://模式切换
        case Qt.Key_F10:
            if(idBottomPannel.modeSwitch)
            {
                idBottomPannel.modeSwitch.clicked();
            }
            console.info("●●●●●●TiDomainWave.qml 模式切换按钮触发●●●●●●idBottomPannel.modeSwitch"+idBottomPannel.modeSwitch);
            event.accepted=true;
            break;
            //case Qt.Key_Delete://参数更新
        case Qt.Key_F19:
            if(idBottomPannel.paramsUpdate)
            {
                idBottomPannel.paramsUpdate.clicked();
            }
            console.info("●●●●●● TiDomainWave.qml参数更新按钮触发●●●●●●Com.paramsUpdate"+idBottomPannel.paramsUpdate);
            console.info("----TiDomainWave.qml响应 ◇C_PRESET◇ 完毕----");
            event.accepted=true;
            break;
        case Qt.Key_1://数字1
            if(root.noCheckbuttonEleArray[1])
            {
                root.noCheckbuttonEleArray[1].focus=true;//multisider1获得焦点
                console.info("卍卍卍卍卍TiDomainWave.qml文件滑块1 获得焦点卍卍卍卍卍")
            }

            event.accepted=true;
            break;
        case Qt.Key_2://数字2
            if(root.noCheckbuttonEleArray[2])
            {
                root.noCheckbuttonEleArray[2].focus=true;//multisider1获得焦点
                console.info("卍卍卍卍卍TiDomainWave.qml文件滑块1 获得焦点卍卍卍卍卍")
            }

            event.accepted=true;
            break;
        case Qt.Key_3://数字3
            if(root.noCheckbuttonEleArray[3])
            {
                root.noCheckbuttonEleArray[3].focus=true;//multisider1获得焦点
                console.info("卍卍卍卍卍TiDomainWave.qml文件滑块1 获得焦点卍卍卍卍卍")
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
                root.uiCheckButtonArray[0].checkboxClick();
                root.getAllsliders();//再次刷新slider
                //刷新sliders
                console.info("TiDomainWave.qml "+checkButtonTipsStr+"触发点击事件");
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
                root.uiCheckButtonArray[1].checkboxClick();
                root.getAllsliders();//再次刷新slider
                console.info("TiDomainWave.qml "+checkButtonTipsStr+"触发点击事件");
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
                root.uiCheckButtonArray[2].checkboxClick();
                root.getAllsliders();//再次刷新slider
                console.info("TiDomainWave.qml "+checkButtonTipsStr+"触发点击事件");
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
                root.uiCheckButtonArray[3].checkboxClick();
                root.getAllsliders();//再次刷新slider
                console.info("TiDomainWave.qml "+checkButtonTipsStr+"触发点击事件");
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

                root.uiCheckButtonArray[4].checkboxClick();
                root.getAllsliders();//再次刷新slider
                console.info("TiDomainWave.qml "+checkButtonTipsStr+"触发点击事件");
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
            console.info("※※※※※TiDomainWave.qml  功能键呼出菜单※※※※※"+idScopeView.focusPageOfrightControl);
            event.accepted=true;
            break;
        default:
            globalConsoleInfo("#####TiDomainWave.qml收到按键消息#####"+event.key);
            break;
        }

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

        //更新slider和checkButton
        getAllsliders();
        getAllcheckButtons();
    }
    //设置操作焦点是X轴
    function setSpanXScale()
    {
        zoomXY = "x";
    }

    //设置操作焦点是Y轴
    function setSpanYScale()
    {
        zoomXY = "y";
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
                }
            }
        }
        else if(UiMultSliderObj!==undefined)
        {
            
            if(UiMultSliderObj.visible)
            {
                noCheckbuttonEleArray.norepeatpush(UiMultSliderObj);
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
                    //globalConsoleInfo("########slider元素#######"+uu+"====="+UiSliderObj[kk].children[uu]);
                    if(UiSliderObj[kk].children[uu].objectName==="triangleEle")
                    {

                        if(UiSliderObj[kk].children[uu].visible)
                        {
                            noCheckbuttonEleArray.norepeatpush(UiSliderObj[kk].children[uu]);
                        }

                    }
                }


                globalConsoleInfo("-----TiDomainWave.qml 添加三角滑块 triangleEle "+kk);
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
                globalConsoleInfo("======TiDomainWave.qml 添加triangleEle "+nn);
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
