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


var ElementType_ComboBox="ComboBox";
var ElementType_TextInput="TextInput";
var ElementType_FileDialog="_FileDialog";

var file_settings_defualt = "settings_default.json";
var file_settings_user = "settings_user.json";
var settings_default = new Object;
var settings_user = new Object;
var settings = new Object;
function settingsReset()
{
    var s = fileIO.read(file_settings_defualt);
    if(s.length)
        settings_default = JSON.parse(s);
    else
    {
        console.log("reset config fail");
    }
    fileIO.write(file_settings_user, JSON.stringify(settings_default));
}
function settingsLoad()
{
    var s = fileIO.read(file_settings_user);
    if(s.length)
    {
        settings_user = JSON.parse(s);
        settings = settings_user;
//        console.log("load config ok");
    }
    else
    {
        console.log("load config fail");
        settingsReset();
        settings = settings_default;
    }
}
function settingsSave(objs)
{
    for(var idx in objs){
        var obj = objs[idx];
        for (var id in settings) {
            if(settings[id].label === obj.textLabel)
            {
                settings[id].val = obj.textData;
                break;
            }
        }
    }
    fileIO.write(file_settings_user, JSON.stringify(settings));
}
function settingsSaveToFile()
{
    fileIO.write(file_settings_user, JSON.stringify(settings));
}
//settingsReset();
settingsLoad();
