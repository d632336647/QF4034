import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../Inc.js" as Com
import "../UI"


Flipable{
    id:root;
    objectName: "观测带宽翻转控件";
    width: 200
    height: 91
    signal  showComplete
    property int angle : 0  //翻转角度
    property bool  flipped : false //用来标志是否翻转
    property alias inputFocus:numberEdit.inputFocus
    property var parentPointer: undefined
    property bool  readOnly:false //为了和采样率的属性保持一致
    Rectangle{
        color: Com.BGColor_main
    }

    front: RightButton {
        id: btn_resolution;
        objectName: "观测带宽翻转控件正面";
        anchors.fill: parent
        textLabel: "通道"+(Settings.paramsSetCh()+1)+" 观测带宽";
        //icon:"\uf002"
        onClick: {
            root.flipped = true
            root.state = "toBack"
            loadParam()
        }
    }
    back: LineEdit {
        objectName: "观测带宽翻转控件背面";
        id: numberEdit;
        anchors.fill: parent
        unit: "MHz"
        text: "25"
        okBtn: true
        prefix: btn_resolution.textLabel
        onAccepted: {
            root.flipped = false;
            root.state = "toFront";
            globalConsoleInfo("★★ViewBandwidth.qml响应onAccepted,查看root.parentPointer---"+root.parentPointer);
            root.parentPointer.focus=true;//侧边栏获得焦点
            setParam(numberEdit.text);
        }
        onOkBtnClicked: {
            root.flipped = false
            root.state = "toFront"
            globalConsoleInfo("★★ViewBandwidth.qml响应onOkBtnClicked,查看root.parentPointer---"+root.parentPointer);
            root.parentPointer.focus=true;//侧边栏获得焦点
            setParam(numberEdit.text)
        }
        onAreaClicked: {
            root.flipped = false
            root.state = "toFront"
        }
    }  //指定正面
    transform:Rotation{ //指定原点
        origin.x:root.width/2; origin.y:root.height/2
        axis.x: 1
        axis.y: 0 //指定按y轴旋转
        axis.z: 0
        angle:root.angle
    }
    states:[
        State{
            name:"toBack" //背面的状态
            PropertyChanges {target:root; angle:180}
            onCompleted: {
                loadParam()
                root.showComplete();
            }
        },
        State{
            name:"toFront" //
            PropertyChanges {target:root; angle:360}
            onCompleted: {
                root.state = "toBack"
            }
        }
    ]

    transitions: Transition {
        NumberAnimation{property:"angle";duration:Com.animationSpeed}
    }
    Component.onCompleted:
    {
        root.state = "toBack"
    }
    function loadParam()
    {
        numberEdit.text = Settings.bandWidth()
        btn_resolution.textLabel = "通道"+(Settings.paramsSetCh()+1)+" 观测带宽";
    }
    function setParam(val)
    {
        if(0){
            messageBox.title = "警告"
            messageBox.note  = "参数超出范围,已自动为您校正!"
            messageBox.isWarning = true
            messageBox.visible = true
        }
        if(parseFloat(val) !== Settings.bandWidth()){
            Settings.bandWidth(Com.OpSet, val)
            analyzeMenu.reloadParams()
            analyzeMenu.updateParams()
        }
    }
}
