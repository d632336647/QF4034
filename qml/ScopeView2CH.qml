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
    property var focusPageOfrightControl:undefined
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

        case Qt.Key_Alt:
            root.getAllScopeChildEle();
            //            for(var hh=0;hh<root.scopeChildEles.length;hh++)
            //            {
            //                globalConsoleInfo("■■■■SSSSSS查看scopeView子元素■■■■:"+hh+"---"+root.scopeChildEles[hh]);
            //            }
            whichTypePageOfEle=Com.setNextFocus(root.scopeChildEles,Com.getFocusIndex(root.scopeChildEles));

            break;
        case Qt.Key_Enter://
            if(whichTypePageOfEle.noCheckbuttonEleArray[0])
            {
                whichTypePageOfEle.noCheckbuttonEleArray[0].focus=true;//enter键默认设置图形焦点
                globalConsoleInfo("---------------图谱获得焦点------------");

            }
            break;
        case Qt.Key_Exclam://功能键1
            if(whichTypePageOfEle.noCheckbuttonEleArray[1])
            {
                whichTypePageOfEle.noCheckbuttonEleArray[1].focus=true;//multisider1获得焦点
                globalConsoleInfo("!!!!!"+whichTypePageOfEle.noCheckbuttonEleArray[1]+"获得焦点")
            }

            break;
        case Qt.Key_At://功能键2
            if(whichTypePageOfEle.noCheckbuttonEleArray[2])
            {
                whichTypePageOfEle.noCheckbuttonEleArray[2].focus=true;//multisider2获得焦点
                globalConsoleInfo("!!!!!"+whichTypePageOfEle.noCheckbuttonEleArray[2]+"获得焦点")
            }
            break;
        case Qt.Key_NumberSign://功能键3
            if(whichTypePageOfEle.noCheckbuttonEleArray[3])
            {
                whichTypePageOfEle.noCheckbuttonEleArray[3].focus=true;//multisider2获得焦点
                globalConsoleInfo("!!!!!"+whichTypePageOfEle.noCheckbuttonEleArray[3]+"获得焦点")
            }
            break;

        case Qt.Key_Dollar://功能键4
            if(whichTypePageOfEle.noCheckbuttonEleArray[4])
            {
                whichTypePageOfEle.noCheckbuttonEleArray[4].focus=true;//multisider2获得焦点
                globalConsoleInfo("!!!!!"+whichTypePageOfEle.noCheckbuttonEleArray[4]+"获得焦点")
            }
            break;

        case Qt.Key_Percent://功能键5
            if(whichTypePageOfEle.noCheckbuttonEleArray[5])
            {
                whichTypePageOfEle.noCheckbuttonEleArray[5].focus=true;//multisider2获得焦点
                globalConsoleInfo("!!!!!"+whichTypePageOfEle.noCheckbuttonEleArray[5]+"获得焦点")
            }
            break;

        case Qt.Key_AsciiCircum://功能键6
            if(whichTypePageOfEle.noCheckbuttonEleArray[6])
            {
                whichTypePageOfEle.noCheckbuttonEleArray[6].focus=true;//multisider2获得焦点
                globalConsoleInfo("!!!!!"+whichTypePageOfEle.noCheckbuttonEleArray[6]+"获得焦点")
            }
            break;

        case Qt.Key_1://数字1
            if(whichTypePageOfEle.uiCheckButtonArray[0]&&(!whichTypePageOfEle.uiCheckButtonArray[0].disabled))
            {
                whichTypePageOfEle.uiCheckButtonArray[0].checkboxClick();


                if(typeof whichTypePageOfEle.uiCheckButtonArray[0].tips!==undefined)
                {
                    checkButtonTipsStr=whichTypePageOfEle.uiCheckButtonArray[0].tips;
                }
                if(checkButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=whichTypePageOfEle.uiCheckButtonArray[0];
                }
                else if(checkButtonTipsStr.indexOf("标尺")!==-1)
                {
                    whichTypePageOfEle.getAllsliders();//再次刷新slider
                    markBtn=whichTypePageOfEle.uiCheckButtonArray[0];

                    //焦点给第一个三角滑块
                    whichTypePageOfEle.noCheckbuttonEleArray[whichTypePageOfEle.uiSliderIndex].focus=true;

                    globalConsoleInfo("1#########找到标尺元素###########");
                }


                globalConsoleInfo("!!!!!"+whichTypePageOfEle.uiCheckButtonArray[0]+"触发点击事件");
            }
            break;
        case Qt.Key_2://数字2
            if(whichTypePageOfEle.uiCheckButtonArray[1]&&(!whichTypePageOfEle.uiCheckButtonArray[1].disabled))
            {
                whichTypePageOfEle.uiCheckButtonArray[1].checkboxClick();

                if(typeof whichTypePageOfEle.uiCheckButtonArray[1].tips!==undefined)
                {
                    checkButtonTipsStr=whichTypePageOfEle.uiCheckButtonArray[1].tips;
                }
                if(checkButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=whichTypePageOfEle.uiCheckButtonArray[1];
                }
                else if(checkButtonTipsStr.indexOf("标尺")!==-1)
                {
                    whichTypePageOfEle.getAllsliders();//再次刷新slider
                    markBtn=whichTypePageOfEle.uiCheckButtonArray[1];

                    //焦点给第一个三角滑块
                    whichTypePageOfEle.noCheckbuttonEleArray[whichTypePageOfEle.uiSliderIndex].focus=true;
                    globalConsoleInfo("2#########找到标尺元素###########");
                }


                globalConsoleInfo("!!!!!"+whichTypePageOfEle.uiCheckButtonArray[1]+"触发点击事件");
            }
            break;
        case Qt.Key_3://数字3
            if(whichTypePageOfEle.uiCheckButtonArray[2]&&(!whichTypePageOfEle.uiCheckButtonArray[2].disabled))
            {
                whichTypePageOfEle.uiCheckButtonArray[2].checkboxClick();

                if(typeof whichTypePageOfEle.uiCheckButtonArray[2].tips!==undefined)
                {
                    checkButtonTipsStr=whichTypePageOfEle.uiCheckButtonArray[2].tips;
                }
                if(checkButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=whichTypePageOfEle.uiCheckButtonArray[2];
                }
                else if(checkButtonTipsStr.indexOf("标尺")!==-1)
                {
                    whichTypePageOfEle.getAllsliders();//再次刷新slider
                    markBtn=whichTypePageOfEle.uiCheckButtonArray[2];


                    //焦点给第一个三角滑块
                    whichTypePageOfEle.noCheckbuttonEleArray[whichTypePageOfEle.uiSliderIndex].focus=true;
                    globalConsoleInfo("3#########找到标尺元素###########");
                }

                globalConsoleInfo("!!!!!"+whichTypePageOfEle.uiCheckButtonArray[2]+"触发点击事件");
            }
            break;
        case Qt.Key_4://数字4
            if(whichTypePageOfEle.uiCheckButtonArray[3]&&(!whichTypePageOfEle.uiCheckButtonArray[3].disabled))
            {
                whichTypePageOfEle.uiCheckButtonArray[3].checkboxClick();

                if(typeof whichTypePageOfEle.uiCheckButtonArray[3].tips!==undefined)
                {
                    checkButtonTipsStr=whichTypePageOfEle.uiCheckButtonArray[3].tips;
                }
                if(checkButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=whichTypePageOfEle.uiCheckButtonArray[3];
                }
                else if(checkButtonTipsStr.indexOf("标尺")!==-1)
                {
                    whichTypePageOfEle.getAllsliders();//再次刷新slider
                    markBtn=whichTypePageOfEle.uiCheckButtonArray[3];

                    //焦点给第一个三角滑块
                    whichTypePageOfEle.noCheckbuttonEleArray[whichTypePageOfEle.uiSliderIndex].focus=true;
                    globalConsoleInfo("4#########找到标尺元素###########");
                }

                globalConsoleInfo("!!!!!"+whichTypePageOfEle.uiCheckButtonArray[3]+"触发点击事件");
            }
            break;
        case Qt.Key_5://数字5
            if(whichTypePageOfEle.uiCheckButtonArray[4]&&(!whichTypePageOfEle.uiCheckButtonArray[4].disabled))
            {
                whichTypePageOfEle.uiCheckButtonArray[4].checkboxClick();

                if(typeof whichTypePageOfEle.uiCheckButtonArray[4].tips!==undefined)
                {
                    checkButtonTipsStr=whichTypePageOfEle.uiCheckButtonArray[4].tips;
                }
                if(checkButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=whichTypePageOfEle.uiCheckButtonArray[4];
                }
                else if(checkButtonTipsStr.indexOf("标尺")!==-1)
                {
                    whichTypePageOfEle.getAllsliders();//再次刷新slider
                    markBtn=whichTypePageOfEle.uiCheckButtonArray[4];

                    //焦点给第一个三角滑块
                    whichTypePageOfEle.noCheckbuttonEleArray[whichTypePageOfEle.uiSliderIndex].focus=true;
                    globalConsoleInfo("5#########找到标尺元素###########");
                }



                globalConsoleInfo("!!!!!"+whichTypePageOfEle.uiCheckButtonArray[4]+"触发点击事件");
            }
            break;
        case Qt.Key_6://数字6
            if(whichTypePageOfEle.uiCheckButtonArray[5]&&(!whichTypePageOfEle.uiCheckButtonArray[5].disabled))
            {
                whichTypePageOfEle.uiCheckButtonArray[5].checkboxClick();
                if(typeof whichTypePageOfEle.uiCheckButtonArray[5].tips!==undefined)
                {
                    checkButtonTipsStr=whichTypePageOfEle.uiCheckButtonArray[5].tips;
                }
                if(checkButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=whichTypePageOfEle.uiCheckButtonArray[5];
                }
                else if(checkButtonTipsStr.indexOf("标尺")!==-1)
                {
                    whichTypePageOfEle.getAllsliders();//再次刷新slider
                    markBtn=whichTypePageOfEle.uiCheckButtonArray[5];

                    //焦点给第一个三角滑块
                    whichTypePageOfEle.noCheckbuttonEleArray[whichTypePageOfEle.uiSliderIndex].focus=true;
                    globalConsoleInfo("6#########找到标尺元素###########");
                }
                globalConsoleInfo("!!!!!"+whichTypePageOfEle.uiCheckButtonArray[5]+"触发点击事件");
            }
            break;
        case Qt.Key_7://数字7
            if(whichTypePageOfEle.uiCheckButtonArray[6]&&(!whichTypePageOfEle.uiCheckButtonArray[6].disabled))
            {
                whichTypePageOfEle.uiCheckButtonArray[6].checkboxClick();

                if(typeof whichTypePageOfEle.uiCheckButtonArray[6].tips!==undefined)
                {
                    checkButtonTipsStr=whichTypePageOfEle.uiCheckButtonArray[6].tips;
                }

                if(checkButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=whichTypePageOfEle.uiCheckButtonArray[6];
                }

                else if(checkButtonTipsStr.indexOf("标尺")!==-1)
                {

                    whichTypePageOfEle.getAllsliders();//再次刷新slider
                    markBtn=whichTypePageOfEle.uiCheckButtonArray[6];



                    //焦点给第一个三角滑块
                    whichTypePageOfEle.noCheckbuttonEleArray[whichTypePageOfEle.uiSliderIndex].focus=true;
                    globalConsoleInfo("7#########找到标尺元素###########");

                }
                globalConsoleInfo("!!!!!"+whichTypePageOfEle.uiCheckButtonArray[6]+"触发点击事件");
            }
            break;
        case Qt.Key_8://数字8
            if(whichTypePageOfEle.uiCheckButtonArray[7]&&(!whichTypePageOfEle.uiCheckButtonArray[7].disabled))
            {
                whichTypePageOfEle.uiCheckButtonArray[7].checkboxClick();

                if(typeof whichTypePageOfEle.uiCheckButtonArray[7].tips!==undefined)
                {
                    checkButtonTipsStr=whichTypePageOfEle.uiCheckButtonArray[7].tips;
                }
                if(checkButtonTipsStr.indexOf("Peak点")!==-1)
                {
                    peakPointBtn=whichTypePageOfEle.uiCheckButtonArray[7];
                }
                else if(checkButtonTipsStr.indexOf("标尺")!==-1)
                {
                    whichTypePageOfEle.getAllsliders();//再次刷新slider
                    markBtn=whichTypePageOfEle.uiCheckButtonArray[7];
                    globalConsoleInfo("8#########找到标尺元素###########");
                }

                globalConsoleInfo("!!!!!"+whichTypePageOfEle.uiCheckButtonArray[7]+"触发点击事件");
            }
            break;

        case Qt.Key_Escape://焦点切换到 右侧边栏
            globalConsoleInfo("♣♣♣♣ScopeView.qml收到Key_Escape♣♣♣♣");
            if(focusPageOfrightControl!==undefined)
            {
                focusPageOfrightControl.focus=true;
                globalConsoleInfo("#####ScopeView失去焦点，焦点被重置到----"+focusPageOfrightControl);
            }

            break;
        default:
            break;
        }
        event.accepted=true;//阻止事件继续传递
    }
    
    
    //判断页面是否可见
    function judgeVisiblePage()
    {
        //历史时域波形图
        if(tiDomainWaveObj.visible)
        {
            whichTypePageOfEle=tiDomainWaveObj;
            compositeFlag=-1;//历史时域波形图
        }
        if((analyzeMode !== 0)&&(analyzeMode !== 1)) //非实时频谱，非实时瀑布图
        {
            //历史瀑布图分析
            if(rtSpectrumObj === undefined || rtWaterFallObj === undefined)
                return;
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
        if(analyzeMode === 0)   //实时频谱
        {
            if(rtSpectrumObj === undefined)
                return;
            if(!rtSpectrumObj.visible)
            {
                whichTypePageOfEle=rtSpectrumObj_channel2;
            }
            else
            {
                whichTypePageOfEle=rtSpectrumObj;
            }


        }
        if(analyzeMode === 1)   //实时瀑布图
        {
            if(rtSpectrumObj === undefined)
                return;
            if(!rtSpectrumObj.visible)
            {
                whichTypePageOfEle=rtSpectrumObj_channel2;
            }
            else
            {
                whichTypePageOfEle=rtSpectrumObj;
            }
        }
        globalConsoleInfo("▲▼▲▼▲▼▲▼查看操作元素whichTypePageOfEle▲▼▲▼▲▼▲▼=="+whichTypePageOfEle);

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
        judgeVisiblePage();
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
                    globalConsoleInfo("#######peakPointBtn添加完毕########");
                }
                else if(thecheckButtonTipsStr.indexOf("标尺")!==-1)
                {
                    whichTypePageOfEle.getAllsliders();//再次刷新slider
                    markBtn=whichTypePageOfEle.uiCheckButtonArray[cc];
                    globalConsoleInfo("¦¦¦¦¦¦¦¦¦¦¦¦markBtn添加完毕¦¦¦¦¦¦¦¦¦¦");
                }
            }
        }
        else
        {
            globalConsoleInfo("！！！！！！getPeakAndmarkEle失败，whichTypePageOfEle不存在︽︽︽︽︽︽︽");
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
            rtSpectrumObj=Com.getNamedELementOfComponent(channel1,"RtSpectrum");
            rtWaterFallObj=Com.getNamedELementOfComponent(channel1,"RtWaterFall");

            //历史频谱图
            if(rtSpectrumObj&&(rtSpectrumObj.visible))
            {
                scopeChildEles.norepeatpush(rtSpectrumObj);
                globalConsoleInfo("♀♀♀♀♀♀scopeView已添加了子元素:通道1频谱图--"+rtSpectrumObj);
            }
            //历史瀑布图
            if(rtWaterFallObj&&(rtWaterFallObj.visible))
            {
                scopeChildEles.norepeatpush(rtWaterFallObj);
                globalConsoleInfo("♀♀♀♀♀♀scopeView已添加了子元素:通道1瀑布图--"+rtWaterFallObj);
            }
        }

        if(channel2.visible)  //通道2
        {
            rtSpectrumObj_channel2=Com.getNamedELementOfComponent(channel2,"RtSpectrum");
            rtWaterFallObj_channel2=Com.getNamedELementOfComponent(channel2,"RtWaterFall");
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
