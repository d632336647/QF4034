.pragma library

function updateAxisX(axisX, centerFreq, bandwidth)
{
    axisX.min = centerFreq - bandwidth/2;
    axisX.max = centerFreq + bandwidth/2;
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

