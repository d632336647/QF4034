//.pragma library
var fontFamily = "幼圆"
var animationSpeed = 200

///mj;mkl;lkm
///mj;mkl;lkm
//var SDColor_success="#5cb85c";
//var SDColor_default="#999";
//var SDColor_primary="#428bca";
//var SDColor_info="#5bc0de";
//var SDColor_warning="#f0ad4e";
//var SDColor_danger="#d9534f";

//RightMenuWidth
var RightMenuWidth =150;

//var bgColorMain="#404040";

// PC
var bgColorMain="black";
// 4034
//var bgColorMain="#00000000";

//var bgColorMain="#247aa9";
//var bgColorMain="#0c3247"

var bottomBGColor= "black";
//var bottomBorderColor="#0f3f4d";
var bottomBorderColor="#552815";
//var bottomBorderColor="#404040";
//var bottomBorderColor="#0c3247";

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
    C_WHEEL_CLOCKWISE     :"201e",
    C_WHEEL_ANTICLOCKWISE :"202d",
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




