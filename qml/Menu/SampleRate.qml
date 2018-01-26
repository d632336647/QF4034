import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../Inc.js" as Com
import "../UI"


Flipable{
    id:root;
    objectName: "采样率翻转控件"
    width: 200
    height: 91
    signal  showComplete
    property int angle : 0  //翻转角度
    property bool flipped : false //用来标志是否翻转
    property var parentPointer: undefined
    property alias text:btnsamplerate.textLabel
    property alias unit:numberEdit.unit
    property alias readOnly:btnsamplerate.readOnly
    Rectangle{
        color: Com.BGColor_main
    }

    front: RightButton {
        objectName: "采样率翻转控件正面";
        id: btnsamplerate;
        anchors.fill: parent
        textLabel: "采样率";
        onClick: {
            root.flipped = true
            root.state = "toBack"
            loadParam()
        }
    }
    back: LineEdit {
        objectName: "采样率翻转控件背面";
        id: numberEdit;
        anchors.fill: parent
        unit: "MHz"
        text: "100"
        okBtn: true
        prefix: btnsamplerate.textLabel
        onAccepted: {
            root.flipped = false
            root.state = "toFront"
            globalConsoleInfo("★★SampleRate.qml响应onAccepted,查看root.parentPointer---"+root.parentPointer)
            root.parentPointer.focus=true;//侧边栏获得焦点
            setParam(numberEdit.text);
        }
        onOkBtnClicked: {
            root.flipped = false
            root.state = "toFront"
             globalConsoleInfo("★★SampleRate.qml响应onOkBtnClicked,查看root.parentPointer---"+root.parentPointer)
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

            }
        },
        State{
            name:"toFront" //
            PropertyChanges {target:root; angle:360}
            onCompleted: {

            }
        }
    ]

    transitions: Transition {
        NumberAnimation{property:"angle";duration:Com.animationSpeed}
    }
    Component.onCompleted:
    {
        if(Settings.clkMode() !== 0)
            btnsamplerate.readOnly = true
        else
            btnsamplerate.readOnly = false
    }
    function loadParam()
    {
        numberEdit.text = Settings.captureRate()
    }
    function setParam(val)
    {
        Settings.captureRate(Com.OpSet, val)
        gatherMenu.updateParams()
    }
}
