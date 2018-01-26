import QtQuick 2.0
import QtQuick.Controls 1.4
import "Inc.js" as Com
import "UI"
import "../SliChart"

Item{
    id:root
    property int analyzeMode: 0
    property int  compositeFlag: 0//0:历史瀑布图分析  1:实时频谱分析  2:实时瀑布图分析
    property bool rtSpectrumObjtoShow: true//是否将焦点给rtSpectrumObj
    property var  scopeChildEles: [] //左侧操作元素
    property var rtSpectrumObj: undefined
    property var rtSpectrumObj_channel2: undefined
    property var rtWaterFallObj: undefined
    property var rtWaterFallObj_channel2: undefined
    property var tiDomainWaveObj: undefined
    property var whichTypePageOfEle:undefined//当前操作的是 历史时域波形|历史频谱图对比|历史瀑布图分析|实时瀑布|实时频谱
    property var peakPointBtn:undefined//peak点对应的btn

    property var markBtn:undefined//mark标尺对应的btn

    property var focusPageOfrightControl:idRightPannel

    property int focusChannel:0 //目前操作通道几
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
                theScopeViewEle:root
            }
            RtWaterFall{
                id: waterfallView
                chIndex:0
                fullMode: false
                fullWide: spectrumView.fullWide
                visible: false
                width: parent.width
                height: parent.height * 0.5
                anchors.top: spectrumView.bottom
                anchors.left: parent.left
                theScopeViewEle:root
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
                theScopeViewEle:root
            }
            RtWaterFall{
                id: waterfallView2
                chIndex:1
                fullMode: waterfallView.fullMode
                fullWide: spectrumView2.fullWide
                visible: waterfallView.visible
                width: parent.width
                height: parent.height * 0.5
                anchors.top: spectrumView2.bottom
                anchors.right: parent.right
                theScopeViewEle:root
            }
        }

        TiDomainWave{
            id:timeDomainWave
            fullMode: true
            anchors.fill: parent
            rightControlPannel:idRightPannel
            theScopeViewEle:root
        }
    }
    
    

    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{

        var curFocusindex=0;//当前获得焦点的子元素索引
        var theuiCheckButtonArrayQQuickMouseArea=undefined;
        var checkButtonTipsStr="";//按键悬浮文本
        globalConsoleInfo("#####ScopeView.qml收到按键消息#####"+event.key);

        judgeVisiblePage();

        switch(event.key)
        {

            //case Qt.Key_End://呼出菜单
        case Qt.Key_F13:
            if(idBottomPannel.menuBtn)
            {
                idBottomPannel.menuBtn.clicked();
            }
            console.info("●●●●●●ScopeView.qml触发 呼出菜单  按钮●●●●●●idBottomPannel.menuBtn"+idBottomPannel.menuBtn);
            event.accepted=true;
            break;
            //case Qt.Key_Insert://模式切换
        case Qt.Key_F10:
            if(idBottomPannel.modeSwitch)
            {
                idBottomPannel.modeSwitch.clicked();
            }
            console.info("●●●●●●ScopeView.qml 触发  模式切换  按钮 ●●●●●●idBottomPannel.modeSwitch"+idBottomPannel.modeSwitch);
            event.accepted=true;
            break;
            //case Qt.Key_Delete://参数更新
        case Qt.Key_F19:
            if(idBottomPannel.paramsUpdate)
            {
                idBottomPannel.paramsUpdate.clicked();
            }
            console.info("●●●●●●ScopeView.qml  触发  参数更新   按钮●●●●●●Com.paramsUpdate"+idBottomPannel.paramsUpdate);
            console.info("----视图响应 ◇C_PRESET◇ 完毕----");
            event.accepted=true;
            break;
        case Qt.Key_F1:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!视图收到C_FREQUENCY_CHANNEL信号!!!!!");

            Com.clearTopPage(root);
            analyzeMenu.focus=true;
            analyzeMenu.state="SHOW";

            console.info("----视图响应 ◇分析参数◇ 完毕----");
            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F5:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!视图收到C_SPAN_X_SCALE!!!!!");

            //idScopeView.getPeakAndmarkEle();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                //更新slider和checkButton
                idScopeView.whichTypePageOfEle.getAllsliders();
                idScopeView.whichTypePageOfEle.getAllcheckButtons();
                idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;
                idScopeView.whichTypePageOfEle.zoomXY="x";
                console.info("----视图响应 ◇C_SPAN_X_SCALE◇ 完毕----");
            }
            else
            {
                console.info("#####视图  图谱不存在！无法响应X轴缩放######");
                console.info(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0]);
            }

            console.info("                 ");
            console.info("------------------ ----------- ");
            event.accepted=true;
            break;
        case Qt.Key_F9:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!视图收到C_AMPLITUDE_Y_SCALE!!!!!");

            //idScopeView.getPeakAndmarkEle();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;
                idScopeView.whichTypePageOfEle.zoomXY="y";
                console.info("----视图响应 ◇C_AMPLITUDE_Y_SCALE◇ 完毕----");
            }
            else
            {
                console.info("#####视图 图谱不存在！无法响应Y轴缩放######");
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
            console.info(root+"!!!!!!视图收到C_MARKER!!!!!");
            console.info("                 ");
            console.info("------------------ ----------- ");
            ////////////////////////

            //idScopeView.judgeVisiblePage();//必须调用此函数，whichTypePageOfEle才会有值
            if(idScopeView.peakPointBtn)
            {
                idScopeView.peakPointBtn.checkboxClick();
                idScopeView.whichTypePageOfEle.getAllsliders();
            }
            //////////////////////
            console.info("----视图响应  ◇C_MARKER◇  完毕----");
            event.accepted=true;
            break;
            //case Qt.Key_F3:
        case Qt.Key_F16:
            console.info("-----------------------------");
            console.info("                 ");
            console.info(root+"!!!!!!视图收到C_PEAK_SEARCH!!!!!");


            if((idScopeView.peakPointBtn)&&(!idScopeView.peakPointBtn.checked))
            {
                idScopeView.peakPointBtn.checkboxClick();
                idScopeView.whichTypePageOfEle.getAllsliders();
            }


            if(idScopeView.markBtn)
            {

                idScopeView.markBtn.checkboxClick();
                //焦点给第一个三角滑块
                idScopeView.whichTypePageOfEle.getAllsliders();//必须重新激活三角滑块
                

                if((idScopeView.whichTypePageOfEle.uiSliderIndex>=0)&&(idScopeView.whichTypePageOfEle.uiSliderIndex<idScopeView.whichTypePageOfEle.noCheckbuttonEleArray.length)&&idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[idScopeView.whichTypePageOfEle.uiSliderIndex].visible)
                {
                    idScopeView.whichTypePageOfEle.noCheckbuttonEleArray[idScopeView.whichTypePageOfEle.uiSliderIndex].focus=true;
                }
            }
            console.info("----视图响应  ◇C_PEAK_SEARCH◇   完毕----");
            console.info("                 ");
            console.info("------------------ ----------- ");
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
            console.info("※※※※※ScopeView.qml  功能键呼出菜单※※※※※"+idScopeView.focusPageOfrightControl);
            event.accepted=true;
            break;
        default:
            if(focusPageOfrightControl!==undefined)
            {

                focusPageOfrightControl.focus=true;
                focusPageOfrightControl.state="SHOW";
                console.info("!!!!!!!ScopeView收到未注册的，焦点被重置到!!!!--"+focusPageOfrightControl);
            }

            break;
        }
        event.accepted=true;//阻止事件继续传递
    }
    
    
    //判断页面是否可见
    function judgeVisiblePage()
    {
        //历史时域波形图
        if(tiDomainWaveObj)
        {
            if(tiDomainWaveObj.visible)
            {
                whichTypePageOfEle=tiDomainWaveObj;
                compositeFlag=-1;//历史时域波形图
            }
        }
        if((analyzeMode !== 0)&&(analyzeMode !== 1)) //非实时频谱，非实时瀑布图
        {
            if(rtSpectrumObj&&rtWaterFallObj)
            {
                //历史瀑布图分析
                if(rtSpectrumObj.visible && rtWaterFallObj.visible)
                {

                compositeFlag=0;
                if(rtSpectrumObjtoShow)
                {
                    whichTypePageOfEle=rtSpectrumObj;
                }
                else
                {
                    whichTypePageOfEle=rtWaterFallObj;
                }


            }
            //历史频谱图对比
            if(rtSpectrumObj.visible && (!rtWaterFallObj.visible))
            {
                whichTypePageOfEle=rtSpectrumObj;

                    compositeFlag=-1;
                }
            }
        }
        if(analyzeMode === 0)   //实时频谱
        {
            if(rtSpectrumObj)
            {
                if(!rtSpectrumObj.visible)
                {
                    console.info("==ScopeView2CH.qml 通道2 显示");
                    whichTypePageOfEle=rtSpectrumObj_channel2;

                }
                else if(rtSpectrumObj_channel2.visible&&(!rtSpectrumObj.visible))
                {
                    console.info("==ScopeView2CH.qml 通道2单路 显示");
                    whichTypePageOfEle=rtSpectrumObj_channel2;

                }
                else if(rtSpectrumObj.visible&&rtSpectrumObj_channel2.visible)  //双通道可见
                {
                    if(1===focusChannel) //通道2
                    {
                        console.info("==ScopeView2CH.qml 查看===focusChannel"+focusChannel);
                        whichTypePageOfEle=rtSpectrumObj_channel2;

                    }
                    else
                    {
                        console.info("!!!ScopeView2CH.qml 查看!!!!focusChannel"+focusChannel);
                        whichTypePageOfEle=rtSpectrumObj;

                    }
                }
            }

        }
        if(analyzeMode === 1)   //实时瀑布图
        {
            if(rtSpectrumObj)
            {
                if(!rtSpectrumObj.visible)
                {
                    console.info("==ScopeView2CH.qml 通道2 显示");
                    whichTypePageOfEle=rtSpectrumObj_channel2;

                }
                else if(rtSpectrumObj_channel2.visible&&(!rtSpectrumObj.visible))
                {
                    console.info("==ScopeView2CH.qml 通道2单路 显示");
                    whichTypePageOfEle=rtSpectrumObj_channel2;

                }
                else if(rtSpectrumObj.visible&&rtSpectrumObj_channel2.visible)  //双通道可见
                {
                    if(1===focusChannel) //通道2
                    {
                        console.info("==ScopeView2CH.qml 查看===focusChannel"+focusChannel);
                        whichTypePageOfEle=rtSpectrumObj_channel2;

                    }
                    else
                    {
                        console.info("!!!ScopeView2CH.qml 查看!!!!focusChannel"+focusChannel);
                        whichTypePageOfEle=rtSpectrumObj;

                    }
                }
            }
        }
        if(whichTypePageOfEle)
        {
            if(whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;//enter键默认设置图形焦点
                console.info("---------------图谱"+ whichTypePageOfEle.noCheckbuttonEleArray[0]+"获得焦点------------");

            }
        }
        console.info("▲▼▲▼▲▼▲▼查看操作元素whichTypePageOfEle▲▼▲▼▲▼▲▼=="+whichTypePageOfEle);

    }
    Component.onCompleted: {
        var ymin_ch0 = Settings.reflevelMin(Com.OpGet, 0, 0);
        var ymax_ch0 = Settings.reflevelMax(Com.OpGet, 0, 0);
        var ymin_ch1 = Settings.reflevelMin(Com.OpGet, 0, 1);
        var ymax_ch1 = Settings.reflevelMax(Com.OpGet, 0, 1);
        spectrumView.setAxisYRange(ymin_ch0,  ymax_ch0)
        spectrumView2.setAxisYRange(ymin_ch1, ymax_ch1)
        waterfallView.updateWaterfallPlotRef(ymin_ch0,  ymax_ch0)
        waterfallView2.updateWaterfallPlotRef(ymin_ch1, ymax_ch1)
        changeAnalyzeMode();
        
    }
    function changeLayout(mod)//analyzeMode
    {
        if(0 === mod){
            if(channel1.visible && channel2.visible){
                channel1.width  = waveTable.width
                channel1.height = parseInt(waveTable.height / 2)
                spectrumView.fullWide = true
                spectrumView.yTicks  = 11

                channel2.width  = waveTable.width
                channel2.height = parseInt(waveTable.height / 2)
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
            channel1.width  = channel2.visible ? parseInt(waveTable.width/2) : waveTable.width
            channel1.height = waveTable.height
            spectrumView.fullWide  = !channel2.visible
            spectrumView.yTicks    = spectrumView.fullMode ? 21 : 11

            channel2.width  = channel1.visible ? parseInt(waveTable.width/2) : waveTable.width
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
        changeLayout(analyzeMode);
        //ScopeView重新加载可见子元素
        globalConsoleInfo("◇◇◇◇changeChannelMode调用◇◇◇◇analyzeMode=="+analyzeMode );
        getAllScopeChildEle();
    }
    
    //获取peakbtn元素
    function getPeakAndmarkEle()
    {

        var thecheckButtonTipsStr="";
        if(whichTypePageOfEle)
        {
            for(var cc=0;cc<whichTypePageOfEle.uiCheckButtonArray.length;cc++)
            {
                if(typeof whichTypePageOfEle.uiCheckButtonArray[cc].tips!==undefined)
                {
                    thecheckButtonTipsStr=whichTypePageOfEle.uiCheckButtonArray[cc].tips;
                }

                if(thecheckButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=whichTypePageOfEle.uiCheckButtonArray[cc];
                    console.info("#######peakPointBtn添加完毕########"+peakPointBtn);
                }
                else if(thecheckButtonTipsStr.indexOf("标尺")!==-1)
                {
                    whichTypePageOfEle.getAllsliders();//再次刷新slider
                    markBtn=whichTypePageOfEle.uiCheckButtonArray[cc];
                    console.info("¦¦¦¦¦¦¦¦¦¦¦¦markBtn添加完毕¦¦¦¦¦¦¦¦¦¦"+markBtn);
                }
            }
        }
        else
        {
            console.info("！！！！！！getPeakAndmarkEle失败，whichTypePageOfEle不存在︽︽︽︽︽︽︽");
            judgeVisiblePage();
            for(var cc=0;cc<whichTypePageOfEle.uiCheckButtonArray.length;cc++)
            {
                if(typeof whichTypePageOfEle.uiCheckButtonArray[cc].tips!==undefined)
                {
                    thecheckButtonTipsStr=whichTypePageOfEle.uiCheckButtonArray[cc].tips;
                }

                if(thecheckButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=whichTypePageOfEle.uiCheckButtonArray[cc];
                    console.info("#######peakPointBtn添加完毕########"+peakPointBtn);
                }
                else if(thecheckButtonTipsStr.indexOf("标尺")!==-1)
                {
                    whichTypePageOfEle.getAllsliders();//再次刷新slider
                    markBtn=whichTypePageOfEle.uiCheckButtonArray[cc];
                    console.info("¦¦¦¦¦¦¦¦¦¦¦¦markBtn添加完毕¦¦¦¦¦¦¦¦¦¦"+markBtn);
                }
            }
        }
    }
    function changeAnalyzeMode()
    {
        var preMode = analyzeMode

        analyzeMode = Settings.analyzeMode()

        //console.log("changeAnalyzeMode", analyzeMode)

        captureThread.stopCapture()
        dataSource.stopSample()
        waterfallView.closeWTFRtData()
        waterfallView2.closeWTFRtData()

        spectrumView.fullMode     = spectrumView2.fullMode     = true
        spectrumView.visible      = spectrumView2.visible      = false
        spectrumView.realTimeMode = spectrumView2.realTimeMode = false
        waterfallView.visible     = waterfallView2.visible     = false
        waterfallView.realTimeMode= waterfallView2.realTimeMode= false

        //ch1
        waterfallView.stopRtTimer()
        spectrumView.closePeakMark()

        //ch2
        waterfallView2.stopRtTimer()
        spectrumView2.closePeakMark()

        timeDomainWave.visible    = false

        if(analyzeMode === 0)   //实时频谱
        {
            //ch1
            spectrumView.visible      = true
            spectrumView.realTimeMode = true

            //ch2
            spectrumView2.visible      = true
            spectrumView2.realTimeMode = true

            changeChannelMode(Settings.channelMode())

            spectrumView.updateParams()
            spectrumView2.updateParams()

            dataSource.startSample()
            captureThread.startCapture()
        }
        else if(analyzeMode === 1)   //实时瀑布图
        {
            //ch1
            spectrumView.fullMode     = false
            spectrumView.visible      = true
            spectrumView.realTimeMode = true

            waterfallView.visible     = true
            waterfallView.realTimeMode= true

            //ch2
            spectrumView2.fullMode     = false
            spectrumView2.visible      = true
            spectrumView2.realTimeMode = true

            waterfallView2.visible     = true
            waterfallView2.realTimeMode= true

            changeChannelMode(Settings.channelMode())

            spectrumView.updateParams()
            waterfallView.updateParams()
            spectrumView2.updateParams()
            waterfallView2.updateParams()

            dataSource.startSample()
            //dataSource.openWaterfallRtCapture(waterfallPlot) //deprecate
            captureThread.startCapture()
        }
        else if(analyzeMode === 2)  //历史文件频谱对比分析
        {
            spectrumView.visible = true

            changeChannelMode(Settings.channelMode())
            spectrumView.updateParams()
        }
        else if(analyzeMode === 3)  //历史文件瀑布图分析
        {
            spectrumView.fullMode = false
            spectrumView.visible = true
            waterfallView.visible = true

            changeChannelMode(Settings.channelMode())
            spectrumView.updateParams()
            waterfallView.updateParams()
        }
        else if(analyzeMode === 4)  //历史文件时域波形
        {
            timeDomainWave.visible    = true

            changeChannelMode(Settings.channelMode())
            timeDomainWave.updateParams()
        }
        //ScopeView重新加载可见子元素
        globalConsoleInfo("※※※※※changeAnalyzeMode调用※※※※※analyzeMode=="+analyzeMode );
        getAllScopeChildEle();
    }

    function updateSepctrumAxisY(min, max)
    {
        var ch = Settings.paramsSetCh();
        console.log("updateSepctrumAxisY min",min,"max",max, "ch", ch)
        if(parseFloat(min)<-140)
            min = -140
        if(parseFloat(max)>40)
            max = 40
        if(parseFloat(max) < parseFloat(min))
            return
        if(ch === 0){
            spectrumView.setAxisYRange(min, max)
            waterfallView.updateWaterfallPlotRef(min, max)
            waterfallView.updateParams()
        }else{
            spectrumView2.setAxisYRange(min, max)
            waterfallView2.updateWaterfallPlotRef(min, max)
            waterfallView2.updateParams()
        }
    }
    
    //获取左侧视图 元素
    function getAllScopeChildEle()
    {
        //先清空scopeChildEles
        scopeChildEles.splice(0,scopeChildEles.length);
        scopeChildEles=[];
        //
        if(channel1.visible)   //通道1
        {
            //rtSpectrumObj=Com.getNamedELementOfComponent(channel1,"RtSpectrum");
            //rtWaterFallObj=Com.getNamedELementOfComponent(channel1,"RtWaterFall");
            rtSpectrumObj=spectrumView;
            rtWaterFallObj=waterfallView;
            //实时频谱图-双通道
            if(rtSpectrumObj&&(rtSpectrumObj.visible))
            {
                scopeChildEles.norepeatpush(rtSpectrumObj);
                globalConsoleInfo("♀♀♀♀♀♀scopeView已添加了子元素:通道1频谱图--"+rtSpectrumObj);
            }
            //实时瀑布图-双通道
            if(rtWaterFallObj&&(rtWaterFallObj.visible))
            {
                scopeChildEles.norepeatpush(rtWaterFallObj);
                globalConsoleInfo("♀♀♀♀♀♀scopeView已添加了子元素:通道1瀑布图--"+rtWaterFallObj);
            }
        }

        if(channel2.visible)  //通道2
        {
            //            rtSpectrumObj_channel2=Com.getNamedELementOfComponent(channel2,"RtSpectrum");
            //            rtWaterFallObj_channel2=Com.getNamedELementOfComponent(channel2,"RtWaterFall");
            rtSpectrumObj_channel2=spectrumView2;
            rtWaterFallObj_channel2=waterfallView2;
            //实时频谱图-双通道
            if(rtSpectrumObj_channel2&&(rtSpectrumObj_channel2.visible))
            {

                scopeChildEles.norepeatpush(rtSpectrumObj_channel2);
                globalConsoleInfo("♀♀♀♀♀♀scopeView已添加了子元素:通道2频谱图--"+rtSpectrumObj_channel2);
            }
            //实时瀑布图-双通道
            if(rtWaterFallObj_channel2&&(rtWaterFallObj_channel2.visible))
            {

                scopeChildEles.norepeatpush(rtWaterFallObj_channel2);
                globalConsoleInfo("♀♀♀♀♀♀scopeView已添加了子元素:通道2瀑布图--"+rtWaterFallObj_channel2);
            }
        }

        tiDomainWaveObj=Com.getNamedELementOfComponent(waveTable,"TiDomainWave");
        //历史时域波形
        if(tiDomainWaveObj&&(tiDomainWaveObj.visible))
        {
            scopeChildEles.norepeatpush(tiDomainWaveObj);
            globalConsoleInfo("♀♀♀♀♀♀scopeView已添加了子元素:历史时域波形--"+tiDomainWaveObj);
        }

        getPeakAndmarkEle();
        globalConsoleInfo("●○●○●○●○●○●○●○●○getAllScopeChildEle执行完毕●○●○●○●○●○●○●○●○");
    }

}
