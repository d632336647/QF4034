//.pragma library
var fontFamily = "幼圆"
var animationSpeed = 200

///mj;mkl;lkm
///mj;mkl;lkm
var SDColor_success="#5cb85c";
var SDColor_default="#999";
var SDColor_primary="#428bca";
var SDColor_info="#5bc0de";
var SDColor_warning="#f0ad4e";
var SDColor_danger="#d9534f";

//var BGColor_main="#404040";

// PC
var BGColor_main="black";
// 4034
//var BGColor_main="#00000000";

//var BGColor_main="#247aa9";
//var BGColor_main="#0c3247"

var BottomBGColor= "black";
//var BottomBorderColor="#0f3f4d";
var BottomBorderColor="#552815";
//var BottomBorderColor="#404040";
//var BottomBorderColor="#0c3247";

var selectBorderColor="#d29928";

var series_color1 = "#daae00"
var series_color2 = "#00a4ef"
var series_color3 = "#dd55ea"




//获取指定名称或者objectName的元素组成的数组
var theArrayOfFindEles=[];


//不使用GloabalArray存储数组元素的代替数组,可以共用
var theSharedTargetArray=[];

var controlPannel={

    //左侧面板
    C_ESCAPE              : "017f", //ESC
    C_RETURN              : "01fe", //Return
    C_FN1                 : "01bf",
    C_FN2                 : "01df",
    C_FN3                 : "01ef",
    C_FN4                 : "01f7",
    C_FN5                 : "01fb",
    C_FN6                 : "01fd",



    //CONTROL 区域
    C_FREQUENCY_CHANNEL   : "03df",
    C_MEASURE             : "03bf",
    C_DET_DEMOD           : "037f",
    C_AUTO_COUPLE         : "02fe",
    C_SPAN_X_SCALE        : "047f",
    C_TRACE_VIEW          : "03fe",
    C_BW_AVG              : "03fd",
    C_TRIG                : "03fb",
    C_AMPLITUDE_Y_SCALE   : "04fd",
    C_DISPLAY             : "04fb",
    C_SINGLE              : "04f7",
    C_SWEEP               : "04ef",



    //system区域
    C_SYSTEM              :"02fd",
    C_PRESET              :"02fb",
    C_MARKER              :"03f7",
    C_PEAK_SEARCH         :"03ef",
    C_MARKER_FCTN         :"04df",
    C_MAKER_ARROW         :"04bf",
    C_SOURCE              :"04fe",

    //方向区
    C_UP_ARROW            :"027f",
    C_DOWN_ARROW          :"02bf",
    C_LEFT_ARROW          :"02ef",
    C_WRIGHT_ARROW        :"02df",
    C_POS_ENTER        	  :"02f7",

    //PARAMETER区域
    C_DIGIT_SEVEN         :"05df",
    C_DIGIT_EIGHT         :"05bf",
    C_DIGIT_NINE          :"057f",
    C_DIGIT_FOUR          :"05fb",
    C_DIGIT_FIVE          :"05f7",
    C_DIGIT_SIX           :"05ef",
    C_DIGIT_ONE           :"06bf",
    C_DIGIT_TWO           :"067f",
    C_DIGIT_THREE         :"05fd",
    C_DIGIT_ZERO          :"06f7",
    C_DIGIT_POINT         :"06ef",
    C_C_DIGIT_PLUS_MINUS  :"06df",
    C_BK_SP               :"06fd",
    C_ENTER               :"06fb",

    //滚轮消息
    C_WHEEL_CLOCKWISE     :"202d",
    C_WHEEL_ANTICLOCKWISE :"201e",
}
//设置面板按键值
function setControlPannel( keyname, keyValue)
{
    controlPannel[keyname]=keyValue;
}


//读取面板按键值
function getControlPannel( keyname)
{
    if(controlPannel[keyname])
        return controlPannel[keyname];
    else
        return 0;
}

var ElementType_ComboBox="ComboBox";
var ElementType_TextInput="TextInput";
var ElementType_FileDialog="_FileDialog";

var childArray=[]; //子元素存储数组
var GlobalTotalchildArray=[];//全局子元素存储数组
//for Settings.Set and Settings.Get
var OpSet = 0
var OpGet = 1
//去除数组重复元素
Array.prototype.contains=function(needle)
{

    for(var i in this)
    {
        if(this[i]===needle) return true;
    }
    return false;
}

Array.prototype.norepeatpush=function(theEle)
{

    if(!this.contains(theEle))
    {
        this.push(theEle);
    }


    return this;
}



//清空侧面板子元素存储数组
function clearchildArray()
{
    childArray.splice(0,childArray.length);
    childArray=[];
    globalConsoleInfo("                           ");
    globalConsoleInfo("............................");
    globalConsoleInfo("                           ");

}
//清空所有子元素存储数组
function clearglobalchildArray()
{
    GlobalTotalchildArray.splice(0,GlobalTotalchildArray.length);
    GlobalTotalchildArray=[];
    globalConsoleInfo("                           ");
    globalConsoleInfo("[............................]");
    globalConsoleInfo("                           ");

}

//触发翻转控件的响应函数
function clickFlexchild(theindex)//第二个参数表示是否是设置起始值
{

    var index=theindex;
    var isSetMinFlag=true;
    var list=childArray;
    var tempobj=list[index];
    tempobj.focus=true;//获得焦点
    tempobj.parent.focus=false;
    var flexObj=list[index];
    var thefrontres=typeof(flexObj.front);
    if(thefrontres!==undefined)    //说明是翻转控件
    {

        var theobjchilid=flexObj.children;
        var editobj=theobjchilid[0];//LineEdit控件
        var btnobj=theobjchilid[1];//RightButton控件
        var okbtnobj=theobjchilid[2];//右下角确定按钮
        for(var tt in editobj)
        {
            globalConsoleInfo("###遍历翻转控件editobj##########"+tt+"#####"+editobj[tt]);
        }
        globalConsoleInfo("------------------分割-------------------------------");
        for(var uu in btnobj)
        {
            globalConsoleInfo("###遍历翻转控件btnobj##########"+uu+"#####"+btnobj[uu]);
        }
        if(flexObj.side===1)//说明是正面，可以编辑
        {

            if(editobj.rangeMode)//范围输入类型
            {

                editobj.rangeMinFocus=true;
                editobj.selectAllOfTextinput();

            }
            else            //单文本输入类型
            {
                editobj.editfocus=true;
                editobj.selectAllOfTextinput();
            }

            globalConsoleInfo("...........进入编辑状态.............");
        }
        else
        {
            btnobj.click();  //rightbutton调用click
            globalConsoleInfo("...........背面.............");
        }
    }



}

//触发非翻转控件子元素点击事件
function clickchild(theindex,theenterFlag)//第二个参数表示是不是确认
{

    var index=theindex;
    var enterFlag=theenterFlag;
    var list=childArray;
    var minValueToSet=true;//是否是设置起始值
    var tempobj=list[index];

    var textlabelStr=tempobj["textLabel"];
    globalConsoleInfo("*******list["+index+"]标签为:"+textlabelStr+"     触发点击事件******");

    var tempstr=tempobj.toString();
    var underline_index=tempstr.indexOf("_");
    var trueth=tempstr.indexOf("ColumnLayout");
    if(trueth!==-1)
    {
        globalConsoleInfo("错误！列布局对象传入childArray");
    }

    tempobj.focus=true;//获得焦点
    tempobj.parent.focus=false;
    var finnalEleTypeStr=tempstr.substr(0,underline_index);
    if(finnalEleTypeStr!=="RightButton")
    {
        globalConsoleInfo("查看明确元素类型-----"+finnalEleTypeStr);
        if(finnalEleTypeStr.indexOf("FileButton")!==-1)//文件打开按钮
        {
            tempobj.openTheFileDlg();
        }
        else   //翻转控件
        {
            console.info("clickFlexchild即将调用,查看子元素索引-----"+index);
            if(tempobj.enabled && (!tempobj.readOnly))
            {
            clickFlexchild(index);
            }
        }

    }
    else  //RightButton 控件
    {
        if(typeof(tempobj.click)=='function')
        {
            globalConsoleInfo(tempobj+"click函数执行");

            tempobj.click();
        }
    }

}

//获取主面板右侧按钮,递归ColumnLayout
function getMainControlPannel( targetObj)
{
    var primarylist=targetObj.children;
    for ( var i in primarylist)
    {

        var tempstr=primarylist[i].toString();

        var index=tempstr.indexOf("_");
        var trueth=tempstr.indexOf("ColumnLayout");
        if(trueth!==-1)//子控件为ColumnLayout布局
        {
            getMainControlPannel(primarylist[i]);//递归
        }
        else//说明直接就是子控件
        {

            var strOfTypeName=tempstr.substr(0,index);

            childArray.norepeatpush(primarylist[i]);
        }

    }

    return childArray;

}
//获取主面板的所有子控件,递归ColumnLayout
function getEveryItemOfControlPannel( targetObj)
{
    var primarylist=targetObj.children;
    var textLabelStr="";

    for ( var i in primarylist)
    {


        var tempstr=primarylist[i].toString();
        if(typeof primarylist[i]["textLabel"]==="string")
        {
            tempstr=primarylist[i]["textLabel"];
        }
        //globalConsoleInfo("查看   primarylist"+[i]+"===="+tempstr+" "+textLabelStr);
        var eachChild=primarylist[i];
        var index=tempstr.indexOf("_");
        var trueth=tempstr.indexOf("ColumnLayout");
        var QQuickItemindex=tempstr.indexOf("QQuickItem");
        var QQuickRectangleindex=tempstr.indexOf("QQuickRectangle");
        if((trueth!==-1)||(QQuickItemindex!==-1)||(QQuickRectangleindex!==-1))//子控件为ColumnLayout或QQuickItem布局
        {
            getAtomItemOfWhichControlPannel(primarylist[i])
        }
        else//说明直接就是子控件
        {

            var strOfTypeName=tempstr.substr(0,index);
            GlobalTotalchildArray.norepeatpush(primarylist[i]);
        }

    }

    return GlobalTotalchildArray;
}



//获取面板的子控件,递归ColumnLayout
function getItemOfControlPannel( targetObj)
{
    var primarylist=targetObj.children;


    for ( var i in primarylist)
    {

        var tempstr=primarylist[i].toString();

        var eachChild=primarylist[i];
        if(eachChild.objectName==="mainrightControlPannel")//说明是主面板
        {
            globalConsoleInfo("该子元素为主面板");
            clearchildArray();
            getMainControlPannel(eachChild);
            return childArray;
        }
        var index=tempstr.indexOf("_");
        var trueth=tempstr.indexOf("ColumnLayout");

        if(trueth!==-1)//子控件为ColumnLayout布局
        {
            getItemOfControlPannel(primarylist[i]);//递归




        }
        for(var bb=0;bb<childArray.length;bb++)
        {
            if(childArray[bb]["textLabel"]==="返回主菜单")
                return childArray;
        }
        if(trueth===-1)//说明直接就是子控件
        {

            var strOfTypeName=tempstr.substr(0,index);

            childArray.norepeatpush(primarylist[i]);
        }

    }
    return childArray;
}
//获取元素所有子控件,递归Rectangle,ColumnLayout,QQuickItem
function getAtomItemOfWhichControlPannel(lastObj)
{
    var atomlist=lastObj.children;


    for ( var i in atomlist)
    {

        var tempstr=atomlist[i].toString();
        var eachChild=atomlist[i];
        var index=tempstr.indexOf("_");
        var Rectangleindex=tempstr.indexOf("Rectangle");
        var ColumnLayoutindex=tempstr.indexOf("ColumnLayout");

        if((Rectangleindex!==-1)||(ColumnLayoutindex!==-1))//子控件为Rectangle布局或ColumnLayout
        {
            getAtomItemOfWhichControlPannel(atomlist[i]);//递归
        }
        else//说明是原子控件
        {
            GlobalTotalchildArray.norepeatpush(atomlist[i]);
        }

    }


    return GlobalTotalchildArray;
}


//返回当前currentBorderSel的值
function getcurrentBorderSelValue(currentChildAarray)
{

    if(currentChildAarray.currentBorderSel)
        return currentChildAarray.currentBorderSel;
    else
    {
        globalConsoleInfo("!!!"+currentChildAarray+"属性currentBorderSel不存在");
        return 0;
    }
}



//返回当前获得焦点的子元素索引
function getFocusIndex(currentChildAarray)
{

    var list=currentChildAarray;
    var curFocus=0;
    globalConsoleInfo("■■查看元素个数:"+list.length);
    for( var k=0;k<list.length;k++)
    {

        if(list[k].focus)
        {
            curFocus=k;
            break;
        }
    }

    globalConsoleInfo("■■当前获得焦点的子元素索引为:"+curFocus);
    return curFocus;
}
//设置上一个元素获得焦点
function setPrevFocus(currentChildAarray,curIndex)
{

    var list=currentChildAarray;
    var thecurIndex=curIndex;
    var therightIndex=thecurIndex-1;
    if(therightIndex<0)
    {
        therightIndex=list.length-1;
    }
    list[therightIndex].focus=true;

    globalConsoleInfo("▲▲焦点已上移,当前获得焦点的子元素索引为:"+therightIndex);
    return list[therightIndex];
}

//设置下一个元素获得焦点
function setNextFocus(currentChildAarray,curIndex)
{

    var list=currentChildAarray;
    var thecurIndex=curIndex;
    var therightIndex=thecurIndex+1;
    if(therightIndex>list.length-1)
    {
        therightIndex=0;
    }
    list[therightIndex].focus=true;

    globalConsoleInfo("▼▼焦点已下移,当前获得焦点的子元素索引为:"+therightIndex);
    return list[therightIndex];
}
//先清空原数组，
function resetAndgetItemOfControlPannel(targetObj)
{
    clearchildArray();//先清空

    var thechlidArray=getItemOfControlPannel(targetObj);

    return thechlidArray;

}

//获取某个组件的具有指定名字或objectName的元素组成的数组
function getNamedELementOfComponentArray(targetObj,namestr)
{
    theArrayOfFindEles.splice(0,theArrayOfFindEles.length);
    theArrayOfFindEles=[];

    var globalchlidArray=getEveryItemOfControlPannel(targetObj);

    var childeTypeStr="";

    var childeobjectName="";

    var childeTextlabelStr="";
    for(var nn=0;nn<globalchlidArray.length;nn++)
    {
        childeTypeStr=globalchlidArray[nn].toString();
        childeobjectName=globalchlidArray[nn].objectName;
        childeTextlabelStr=globalchlidArray[nn].textLabel;
        if((childeTypeStr.indexOf(namestr)!==-1)||(childeobjectName===namestr)||(childeTextlabelStr===namestr))
        {
            //globalConsoleInfo("☆☆☆名称为"+namestr+"的元素,已添加到数组☆☆☆");
            theArrayOfFindEles.norepeatpush(globalchlidArray[nn]) ;
        }
    }
    if(theArrayOfFindEles.length==0)
    {
        return undefined;
    }
    return theArrayOfFindEles;
}


//不使用GlobalTotalchildArray获取元素所有子控件,递归Rectangle,ColumnLayout,QQuickItem
function getAtomItem(lastObj)
{
    var atomlist=lastObj.children;


    for ( var i in atomlist)
    {

        console.info("======getAtomItem函数遍历=:"+i+"===="+atomlist[i]);
        var tempstr=atomlist[i].toString();
        var eachChild=atomlist[i];
        var index=tempstr.indexOf("_");
        var Rectangleindex=tempstr.indexOf("Rectangle");
        var ColumnLayoutindex=tempstr.indexOf("ColumnLayout");

        if((Rectangleindex!==-1)||(ColumnLayoutindex!==-1))//子控件为Rectangle布局或ColumnLayout
        {
            getAtomItem(atomlist[i]);//递归
        }
        else//说明是原子控件
        {
            theSharedTargetArray.norepeatpush(atomlist[i]);
        }

    }


    return theSharedTargetArray;
}


//获取某个元素的所有子控件,递归ColumnLayout
function getEveryItem( targetObj)
{
    var primarylist=targetObj.children;
    var textLabelStr="";

    for ( var i in primarylist)
    {


        var tempstr=primarylist[i].toString();
        if(typeof primarylist[i]["textLabel"]==="string")
        {
            tempstr=primarylist[i]["textLabel"];
        }
        console.info("查看   primarylist "+[i]+"===="+tempstr+" "+textLabelStr);

        var eachChild=primarylist[i];
        var index=tempstr.indexOf("_");
        var trueth=tempstr.indexOf("ColumnLayout");
        var QQuickItemindex=tempstr.indexOf("QQuickItem");
        var QQuickRectangleindex=tempstr.indexOf("QQuickRectangle");


        if((trueth!==-1)||(QQuickItemindex!==-1)||(QQuickRectangleindex!==-1))//子控件为ColumnLayout或QQuickItem布局
        {

            getAtomItem(primarylist[i]);

        }
        else//说明直接就是子控件
        {

            var strOfTypeName=tempstr.substr(0,index);
            theSharedTargetArray.norepeatpush(primarylist[i]);
        }

    }

    return theSharedTargetArray;
}


//获取某个组件的具有指定名字或objectName的元素
function getNamedELementOfComponent(targetObj,namestr)
{


    var globalchlidArray=getEveryItemOfControlPannel(targetObj);

    var childeTypeStr="";

    var childeobjectName="";

    var childeTextlabelStr="";
    for(var nn=0;nn<globalchlidArray.length;nn++)
    {
        childeTypeStr=globalchlidArray[nn].toString();
        childeobjectName=globalchlidArray[nn].objectName;
        childeTextlabelStr=globalchlidArray[nn].textLabel;
        if((childeTypeStr.indexOf(namestr)!==-1)||(childeobjectName===namestr)||(childeTextlabelStr===namestr))
        {
            globalConsoleInfo("★★★找到名称为"+namestr+"的元素,它的索引是"+nn);
            return globalchlidArray[nn];
        }
    }

    return undefined;
}
//清除覆盖在当前页面上面的页面（父辈页面）
function clearTopPage(currentPage)
{
    var prevfamilyTree=[];//需要清空的数组
    for(var tmpparentobj=currentPage.parent;tmpparentobj.objectName!=="mainboxRectangle";tmpparentobj=tmpparentobj.parent)
    {

        prevfamilyTree.norepeatpush(tmpparentobj);
    }
    currentPage.state="HIDE";
    currentPage.focus=false;
    for(var zz=0;zz<prevfamilyTree.length;zz++)
    {
        prevfamilyTree[zz].state="HIDE";
        prevfamilyTree[zz].focus=false;
        globalConsoleInfo(prevfamilyTree+".......隐藏........");
    }
}
//跳转到任意制定页面（第一个页面为当前页面，默认参数是root.第二个参数是目的页面的父组件，第三个为目的页面的字符串名）
function jumptoTargetPage(currentPage,parentComponent,targetName)
{


    clearglobalchildArray();//先清空
    globalConsoleInfo(">>>>>>>>>>>>>将要跳转到>>>"+targetName+"页面");



    var therightnameEle=getNamedELementOfComponent(parentComponent,targetName);
    globalConsoleInfo("查看要跳转的目标元素为"+therightnameEle);
    if(therightnameEle===undefined)
    {
        console.error("未找到"+targetName+"页面");

        return undefined;
    }

    clearTopPage(currentPage);


    //globalConsoleInfo(currentPage+"已隐藏！！！！")





    var familytree=[];


    for(var tmpobj=therightnameEle.parent;tmpobj.objectName!=="mainboxRectangle";tmpobj=tmpobj.parent)
    {
        globalConsoleInfo("*******查看父辈元素为"+tmpobj);
        familytree.norepeatpush(tmpobj);
    }
    familytree.reverse();
    globalConsoleInfo("==查看familytree.length==="+familytree.length);
    for(var vv=0;vv<familytree.length;vv++)
    {
        familytree[vv].state="SHOW";
        globalConsoleInfo("==查看familytree"+"["+vv+"]"+familytree[vv]+".state===="+familytree[vv].state);

    }

    if(typeof(therightnameEle.parent.loadParam)=='function')
    {
        therightnameEle.parent.loadParam();
    }


    therightnameEle.focus=true;
    therightnameEle.state="SHOW";

    if(typeof(therightnameEle.loadParam)=='function')
    {
        therightnameEle.loadParam();
    }

    return 1;

}


//重置所有子元素数组，
function resetGlobalItemOfElement(targetObj)
{
    globalConsoleInfo("=======resetGlobalItemOfElement函数执行======");
    clearglobalchildArray();//先清空
    var globalchlidArray=getEveryItemOfControlPannel(targetObj);
    return globalchlidArray;

}


//判断元素是不是数组

function isArray(o)
{
    return Object.prototype.toString.call(o)==='[object Array]';
}




