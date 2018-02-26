function updateAxisX(idAxisX, cf, bw)
{
    idAxisX.min = cf - bw/2;
    idAxisX.max = cf + bw/2;
}


function jumpToMenu(handle, parent, obj_name)
{
    var obj = handle.findQuickItem(obj_name);

    console.log("jumpToMenu", obj)
    obj.state = "SHOW"
    obj.focus = true;

    //parent_menu.state = "HIDE"
}

function menuLoadParam(handle, parent, obj_name)
{
    var obj = handle.findQuickItem(obj_name);

    console.log("loadParam", obj)

    obj.loadParam();
}

function clickFunctionKey(key_code, key_array, id_array)
{
    if(id_array.length === undefined || key_array.length === undefined)
    {
        console.log("clickFunctionKey error", "arg is not array")
        return false;
    }
    if(id_array.length === 0 || key_array.length === 0)
    {
        console.log("clickFunctionKey error", "array length is 0")
        return false;
    }
    if(id_array.length !== key_array.length)
    {
        console.log("clickFunctionKey error", "array length is diff")
        return false;
    }

    var idx = -1;
    for(var i = 0; i < key_array.length; i++)
    {
        if( parseInt(key_array[i]) === key_code)
        {
            idx = i;
            break;
        }
    }
    if(idx < 0)
    {
        return false
    }
    var callback = id_array[idx].keyPressed
    if(callback === undefined)
    {
        console.log("clickFunctionKey error", "callback is undefined")
        return false
    }
    callback()
    return true
}
function dPrintf(text)
{
    console.log(text)
}
function operateSpecView(key_code)
{
    //console.log("key_code:",key_code)
    var rtn = false
    var force_return = false
    switch(key_code)
    {
    case Qt.Key_X:
    case Qt.Key_F13:
        dPrintf("operateSpecView x")
        idScopeView.svSetXSpan(true)
        idScopeView.svSetYSpan(false)
        idScopeView.svSetActiveFile(false)
        idScopeView.svSetSwitchFileEnable(false)
        idScopeView.svSetCloseMark()
        rtn = true
        break;
    case Qt.Key_Y:
    case Qt.Key_F17:
        dPrintf("operateSpecView y")
        idScopeView.svSetYSpan(true)
        idScopeView.svSetXSpan(false)
        idScopeView.svSetActiveFile(false)
        idScopeView.svSetSwitchFileEnable(false)
        idScopeView.svSetCloseMark()
        rtn = true
        break;
    case Qt.Key_PageUp://roll button
        if(idScopeView.svSetZoomIn())
            dPrintf("operateSpecView zoom in")
        if(idScopeView.svSetMoveMark(1))
            dPrintf("operateSpecView move mark right")
        rtn = true
        break;
    case Qt.Key_PageDown://roll button
        if(idScopeView.svSetZoomOut())
            dPrintf("operateSpecView zoom out")
        if(idScopeView.svSetMoveMark(0))
            dPrintf("operateSpecView move mark left")
        rtn = true
        break;
    case Qt.Key_Up:
        dPrintf("operateSpecView scroll UP")
        idScopeView.svSetDragMove(0)
        rtn = true
        break;
    case Qt.Key_Down:
        dPrintf("operateSpecView scroll Down")
        idScopeView.svSetDragMove(1)
        rtn = true
        break;
    case Qt.Key_Left:
        if(idScopeView.svSetDragMove(2))
            dPrintf("operateSpecView scroll Left")
        if(idScopeView.svSetMoveFile(0))
            dPrintf("operateSpecView prev file view")
        rtn = true
        break;
    case Qt.Key_Right:
        if(idScopeView.svSetDragMove(3))
            dPrintf("operateSpecView scroll Right")
        if(idScopeView.svSetMoveFile(1))
            dPrintf("operateSpecView next file view")
        rtn = true
        break;
    case Qt.Key_P://Peak Search
    case Qt.Key_F24:
        dPrintf("operateSpecView show peak")
        idScopeView.svSetShowPeak()
        rtn = true
        break;
    case Qt.Key_M://Marker
    case Qt.Key_F23:
        dPrintf("operateSpecView move peak")
        if(idScopeView.svSetShowMark()){
            idScopeView.svSetXSpan(false)
            idScopeView.svSetYSpan(false)
        }
        rtn = true
        break;
    case Qt.Key_S://Source
    case Qt.Key_F27:
        var mode = Settings.analyzeMode()
        if(mode > 1){
            dPrintf("operateSpecView switch file")
            idScopeView.svSetSwitchFile()
            idScopeView.svSetSwitchFileEnable(true)
            idScopeView.svSetActiveFile(true)
            idScopeView.svSetXSpan(false)
            idScopeView.svSetYSpan(false)
        }
        else
        {
            dPrintf("operateSpecView switch param set ch")
            idScopeView.svSetCloseMark()
            idScopeView.svSetClosePeak()
            idScopeView.svSetXSpan(false)
            idScopeView.svSetYSpan(false)
            idBottomPannel.chanegParamSetCh()
        }
        rtn = true
        break;
    case Qt.Key_F://Frequency 注意此按键的特殊处理
    case Qt.Key_F9:
        //jumpToMenu(Settings, idRightPannel, "analyzeMenu")
        idScopeView.svCloseAllOpBtn()
        idRightPannel.state = "SHOW"
        analyzeMenu.state = "SHOW"
        analyzeMenu.focus = true;
        rtn = true
        force_return = true
        break;
    case Qt.Key_A://Auto couple
    case Qt.Key_F12:
        idScopeView.svSetChartReset()
        rtn = true
        break;
    case Qt.Key_D://Display
    case Qt.Key_F18:
        idBottomPannel.chanegSignalCh()
        rtn = true
        break;
    case Qt.Key_G://SinGle
    case Qt.Key_F19:
        idScopeView.svSetSingleSweep(false)
        rtn = true
        break;
    case Qt.Key_E://SweEp
    case Qt.Key_F20:
        idScopeView.svSetSingleSweep(true)
        rtn = true
        break;
    case Qt.Key_Q:
    case Qt.Key_F21://SYSTEM
        systemMenu.switchSystemMenu()
        force_return = true
        break;
    case Qt.Key_R:
    case Qt.Key_F22://PRESET
        setPreset()
        rtn = true
        break;
    //暂时未完善的功能
    case Qt.Key_F25://MARKER_FCTN
        showNoticeTip("此功能暂未完善,请使用Marker代替")
        break;
    case Qt.Key_F26://MAKER_ARROW
        showNoticeTip("此功能暂未完善,请使用Marker代替")
        break;
    //暂不支持的功能
    case Qt.Key_F10://MEASURE
    case Qt.Key_F11://DET_DEMOD
    case Qt.Key_F14://TRACE_VIEW
    case Qt.Key_F15://BW_AVG
    case Qt.Key_F16://TRIG
        showNoFunctionTip()
        rtn = true
        force_return = true;
        break;
    default:
        break;
    }
    if(force_return)
        return rtn
    if(rtn && idRightPannel.state === "SHOW")
    {
        idRightPannel.state = "HIDE"
        idRightPannel.focus = true
    }
    return rtn
}

function setPreset()
{
    console.log("---------------------------Set Preset updateParams------------------------------")
    captureThread.stopCapture()
    dataSource.stopSample()
    Settings.loadDefault()
    var outmode = 0;
    var chCount = 2;
    var ddcfreq = Settings.ddcFreq();//MHz
    var extractfactor = Settings.extractFactor();
    var fsbcoef  = Settings.fsbCoef();//1.25B
    dataSource.setPreConditionParam(outmode, chCount, ddcfreq, extractfactor, fsbcoef);

    var clkMode     = Settings.clkMode();
    var captureRate = Settings.captureRate();
    var triggerMode = Settings.triggerMode();
    var captureMode = Settings.captureMode();
    var captureSize = Settings.captureSize();
    dataSource.setCaptureParam(clkMode, captureRate, triggerMode, captureMode, captureSize);

    analyzeMenu.updateParams()
    idScopeView.svCloseAllOpBtn()
}

function showNoFunctionTip()
{
    messageBox.title = "警告"
    messageBox.note  = "暂不支持此功能!"
    messageBox.isWarning = true
    messageBox.visible = true
}
function showNoticeTip(str)
{
    messageBox.title = "提示"
    messageBox.note  = str
    messageBox.isWarning = false
    messageBox.visible = true
}
