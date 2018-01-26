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
        //读取相应slider和checkButton控件
        getAllsliders();
        getAllcheckButtons();

    }

    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{

        var theaxisMinX = idAxisX.min;
        var theaxisMaxX = idAxisX.max;

        var theaxisMinY = idAxisY.min;
        var theaxisMaxY = idAxisY.max;
        var themidX=theaxisMinX+(theaxisMaxX-theaxisMinX)/2;
        var themidY=theaxisMinY+(theaxisMaxY-theaxisMinY)/2;
        var checkButtonTipsStr="";//按键悬浮文本
        var theSubTriangleIndex=0; //三角滑块索引
        var theSubFileSliderIndex=0;//文件滑块索引
        centerPoint=Qt.point( themidX, themidY );
        console.info("□□□□□□□□□RtWaterFall.qml查看centerPoint.x="+centerPoint.x+"===centerPoint.y==="+centerPoint.y);
        switch(event.key)
        {
        case Qt.Key_Escape://焦点切换到 scopeView

            if(theScopeViewEle)
            {
                theScopeViewEle.focus=true;//焦点重置为ScopeView
                console.info("========RtWaterFall.qml收到Key_Escape,焦点交给了:"+theScopeViewEle);
            }
            event.accepted=true;//阻止事件继续传递
            break;
        case Qt.Key_Enter://放大

            if(scrollTypeStr === "axisMain" && realTimeMode === false)//实时模式由频谱图同步缩放
            {

                zoomHorizontalbyBtn(centerPoint.x, centerPoint.y, 0.5);

            }
            event.accepted=true;//阻止事件继续传递
            break;
        case Qt.Key_PageDown://放大

            if(scrollTypeStr === "axisMain" && realTimeMode === false)//实时模式由频谱图同步缩放
            {

                zoomHorizontalbyBtn(centerPoint.x, centerPoint.y, 0.5);

            }
            event.accepted=true;//阻止事件继续传递
            break;
        case Qt.Key_Space://缩小

            if(scrollTypeStr === "axisMain" && realTimeMode === false)//实时模式由频谱图同步缩放
            {

                zoomHorizontalbyBtn(centerPoint.x, centerPoint.y, 2);


            }
            event.accepted=true;//阻止事件继续传递
            break;
        case Qt.Key_PageUp://缩小

            if(scrollTypeStr === "axisMain" && realTimeMode === false)//实时模式由频谱图同步缩放
            {

                zoomHorizontalbyBtn(centerPoint.x, centerPoint.y, 2);


            }
            event.accepted=true;//阻止事件继续传递
            break;
            //Maker-->箭头
            //case Qt.Key_F18:
        case Qt.Key_F12:
            //console.info("♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂RtWaterFall.qml收到Maker-->箭头消息♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂♂");
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
            console.info(root+"!!!!!!RtWaterFall.qml收到C_FREQUENCY_CHANNEL信号!!!!!");

            Com.clearTopPage(root);
            analyzeMenu.focus=true;
            analyzeMenu.state="SHOW";

            console.info("----RtWaterFall.qml响应 ◇分析参数◇ 完毕----");
            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F5:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!RtWaterFall.qml收到C_SPAN_X_SCALE!!!!!");
            //记录上一个焦点转移的页面

            //idScopeView.getPeakAndmarkEle();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                //更新slider和checkButton
                idScopeView.whichTypePageOfEle.getAllsliders();
                idScopeView.whichTypePageOfEle.getAllcheckButtons();
                idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;
                idScopeView.whichTypePageOfEle.zoomXY="x";
                console.info("----RtWaterFall.qml响应 ◇C_SPAN_X_SCALE◇ 完毕----");
            }
            else
            {
                console.info("#####RtWaterFall.qml 图谱不存在！无法响应X轴缩放######");
                console.info(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0]);
            }

            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F9:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!RtWaterFall.qml收到C_AMPLITUDE_Y_SCALE!!!!!");

            //idScopeView.getPeakAndmarkEle();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;
                idScopeView.whichTypePageOfEle.zoomXY="y";
                console.info("----RtWaterFall.qml响应 ◇C_AMPLITUDE_Y_SCALE◇ 完毕----");
            }
            else
            {
                console.info("#####RtWaterFall.qml 图谱不存在！无法响应Y轴缩放######");
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
            console.info(root+"!!!!!!RtWaterFall.qml收到C_MARKER!!!!!");
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
            console.info("----RtWaterFall.qml响应  ◇C_MARKER◇  完毕----");
            event.accepted=true;
            break;
        //case Qt.Key_F3:
            case Qt.Key_F16:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!RtWaterFall.qml 收到C_PEAK_SEARCH!!!!!");


            if((idScopeView.peakPointBtn)&&(!idScopeView.peakPointBtn.checked))
            {
                idScopeView.peakPointBtn.checkboxClick();
                root.getAllsliders();
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
            }
            console.info("----RtWaterFall.qml 响应  ◇C_PEAK_SEARCH◇   完毕----");
            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;

            //case Qt.Key_End://呼出菜单
        //case Qt.Key_F13:
            if(idBottomPannel.menuBtn)
            {
                idBottomPannel.menuBtn.clicked();
            }
            console.info("●●●●●●RtWaterFall.qml 呼出菜单按钮触发●●●●●●idBottomPannel.menuBtn"+idBottomPannel.menuBtn);
            event.accepted=true;
            break;
            //case Qt.Key_Insert://模式切换
        case Qt.Key_F10:
            if(idBottomPannel.modeSwitch)
            {
                idBottomPannel.modeSwitch.clicked();
            }
            console.info("●●●●●●RtWaterFall.qml 模式切换按钮触发●●●●●●idBottomPannel.modeSwitch"+idBottomPannel.modeSwitch);
            event.accepted=true;
            break;
            //case Qt.Key_Delete://参数更新
        case Qt.Key_F19:
            if(idBottomPannel.paramsUpdate)
            {
                idBottomPannel.paramsUpdate.clicked();
            }
            console.info("●●●●●●RtWaterFall.qml 参数更新按钮触发●●●●●●Com.paramsUpdate"+idBottomPannel.paramsUpdate);
            console.info("----RtWaterFall.qml响应 ◇C_PRESET◇ 完毕----");
            event.accepted=true;
            break;
        case Qt.Key_1://数字1
            if(root.noCheckbuttonEleArray[1])
            {
                root.noCheckbuttonEleArray[1].focus=true;//multisider1获得焦点
                console.info("◎◎◎◎◎◎RtWaterFall.qml 文件滑块1 获得焦点◎◎◎◎◎◎")
            }

            event.accepted=true;
            break;
        case Qt.Key_2://数字2
            if(root.noCheckbuttonEleArray[2])
            {
                root.noCheckbuttonEleArray[2].focus=true;//multisider1获得焦点
                console.info("◎◎◎◎◎◎RtWaterFall.qml 文件滑块1 获得焦点◎◎◎◎◎◎")
            }

            event.accepted=true;
            break;
        case Qt.Key_3://数字3
            if(root.noCheckbuttonEleArray[3])
            {
                root.noCheckbuttonEleArray[3].focus=true;//multisider1获得焦点
                console.info("◎◎◎◎◎◎RtWaterFall.qml 文件滑块1 获得焦点◎◎◎◎◎◎")
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
                console.info("RtWaterFall.qml "+checkButtonTipsStr+"触发点击事件");
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
                console.info("RtWaterFall.qml "+checkButtonTipsStr+"触发点击事件");
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
                console.info("RtWaterFall.qml "+checkButtonTipsStr+"触发点击事件");
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
                console.info("RtWaterFall.qml "+checkButtonTipsStr+"触发点击事件");
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
                console.info("RtWaterFall.qml "+checkButtonTipsStr+"触发点击事件");
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
            console.info("※※※※※RtWaterFall.qml  功能键呼出菜单※※※※※"+idScopeView.focusPageOfrightControl);
            event.accepted=true;
            break;
        default:
            console.info("========RtWaterFall.qml收到未注册按键消息#####"+event.key);
            break;
        }

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

        //更新slider和checkButton
        getAllsliders();
        getAllcheckButtons();
    }


    //获取所有非checkButton元素
    function getAllsliders()
    {

        noCheckbuttonEleArray.splice(0,noCheckbuttonEleArray.length);
        noCheckbuttonEleArray=[];

        noCheckbuttonEleArray.norepeatpush(idChartView);//第一个就是图谱
        var UiMultSliderObj=Com.getNamedELementOfComponentArray(root,"UiMultSlider");

        if(Com.isArray(UiMultSliderObj))
        {
            for(var jj=0;jj<UiMultSliderObj.length;jj++)//添加UiMultSliderObj
            {
                
                if(UiMultSliderObj[jj].visible)
                {
                    noCheckbuttonEleArray.norepeatpush(UiMultSliderObj[jj]);
                    console.info("!!!RtWaterFall.qml 数组添加multiSlider-"+jj);
                }
            }
        }
        else if(UiMultSliderObj!==undefined)
        {
            
            if(UiMultSliderObj.visible)
            {
                noCheckbuttonEleArray.norepeatpush(UiMultSliderObj);
                console.info("---RtWaterFall.qml直接 添加multiSlider");
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

                        if(UiSliderObj[kk].children[uu].visible)
                        {
                            noCheckbuttonEleArray.norepeatpush(UiSliderObj[kk].children[uu]);
                        }

                    }
                }


                console.info("-----RtWaterFall.qml 添加 三角滑块 triangleEle "+kk);
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
                console.info("======RtWaterFall.qml 添加triangleEle "+nn);
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
                console.info("------RtWaterFall.qml添加CheckButton元素-"+kk);
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
