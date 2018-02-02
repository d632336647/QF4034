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

function operateSpecView(key_code)
{
    //console.log("key_code:",key_code)
    var rtn = false
    if(key_code === Qt.Key_X || key_code === Qt.Key_F13)
    {
        console.log("operateSpecView x key_code:",key_code)
        idScopeView.svSetXSpan(true)
        idScopeView.svSetYSpan(false)
        idScopeView.svSetActiveFile(false)
        idScopeView.svSetSwitchFileEnable(false)
        idScopeView.svSetCloseMark()
        rtn = true
    }
    if(key_code === Qt.Key_Y || key_code === Qt.Key_F17)
    {
        console.log("operateSpecView y key_code:",key_code)
        idScopeView.svSetYSpan(true)
        idScopeView.svSetXSpan(false)
        idScopeView.svSetActiveFile(false)
        idScopeView.svSetSwitchFileEnable(false)
        idScopeView.svSetCloseMark()
        rtn = true
    }
    if(key_code === Qt.Key_PageUp)
    {
        if(idScopeView.svSetZoomIn())
            console.log("operateSpecView zoom in key_code:",key_code)
        if(idScopeView.svSetMoveMark(1))
            console.log("operateSpecView move mark right key_code:",key_code)
        rtn = true
    }
    if(key_code === Qt.Key_PageDown)
    {
        if(idScopeView.svSetZoomOut())
            console.log("operateSpecView zoom out key_code:",key_code)
        if(idScopeView.svSetMoveMark(0))
            console.log("operateSpecView move mark left key_code:",key_code)
        rtn = true
    }
    if(key_code === Qt.Key_Up)
    {
        console.log("operateSpecView scroll UP key_code:",key_code)
        idScopeView.svSetDragMove(0)
        rtn = true
    }
    if(key_code === Qt.Key_Down)
    {
        console.log("operateSpecView scroll Down key_code:",key_code)
        idScopeView.svSetDragMove(1)
        rtn = true
    }
    if(key_code === Qt.Key_Left)
    {
        if(idScopeView.svSetDragMove(2))
            console.log("operateSpecView scroll Left key_code:",key_code)
        if(idScopeView.svSetMoveFile(0))
            console.log("operateSpecView prev file view key_code:",key_code)
        rtn = true
    }
    if(key_code === Qt.Key_Right)
    {
        if(idScopeView.svSetDragMove(3))
            console.log("operateSpecView scroll Right key_code:",key_code)
        if(idScopeView.svSetMoveFile(1))
            console.log("operateSpecView next file view key_code:",key_code)
        rtn = true
    }
    if(key_code === Qt.Key_P || key_code === Qt.Key_F24)
    {
        console.log("operateSpecView show peak key_code:",key_code)
        idScopeView.svSetShowPeak()
        rtn = true
    }
    if(key_code === Qt.Key_M || key_code === Qt.Key_F23)
    {
        console.log("operateSpecView move peak key_code:",key_code)
        if(idScopeView.svSetShowMark())
        {
            idScopeView.svSetXSpan(false)
            idScopeView.svSetYSpan(false)
        }
        rtn = true
    }
    if(key_code === Qt.Key_S || key_code === Qt.Key_F27)
    {

        var mode = Settings.analyzeMode()
        if(mode > 1){
            console.log("operateSpecView switch file key_code:",key_code)
            idScopeView.svSetSwitchFile()
            idScopeView.svSetSwitchFileEnable(true)
            idScopeView.svSetActiveFile(true)
            idScopeView.svSetXSpan(false)
            idScopeView.svSetYSpan(false)
        }
        else
        {
            console.log("operateSpecView switch param set ch key_code:",key_code)
            idScopeView.svSetCloseMark()
            idScopeView.svSetClosePeak()
            idScopeView.svSetXSpan(false)
            idScopeView.svSetYSpan(false)
            idBottomPannel.chanegParamSetCh()
        }
        rtn = true
    }
    if(key_code === Qt.Key_F || key_code === Qt.Key_F9)//注意此按键的特殊处理
    {
        //jumpToMenu(Settings, idRightPannel, "analyzeMenu")
        idScopeView.svCloseAllOpBtn()
        idRightPannel.state = "SHOW"
        analyzeMenu.state = "SHOW"
        analyzeMenu.focus = true;
        return true
    }
    if(key_code === Qt.Key_A || key_code === Qt.Key_F12)
    {
        idScopeView.svSetChartReset()
        rtn = true
    }
    if(key_code === Qt.Key_H || key_code === Qt.Key_F19)
    {
        idBottomPannel.chanegSignalCh()
        rtn = true
    }

    if(rtn && idRightPannel.state === "SHOW")
    {
        idRightPannel.state = "HIDE"
        idRightPannel.focus = true
    }
    return rtn
}
