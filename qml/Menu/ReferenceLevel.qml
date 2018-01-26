import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../Inc.js" as Com
import "../UI"


Flipable{
    id:root;
    width: 200
    height: 91
    signal  showComplete
    property int angle : 0  //翻转角度
    property bool flipped : false //用来标志是否翻转
    property var parentPointer: undefined
    property alias inputFocus:numberEdit.inputFocus
    objectName: "参考电平翻转控件";
    Rectangle{
        color: Com.BGColor_main
    }

    front: RightButton {
        id: btn_centerfreq;
        objectName: "参考电平翻转控件正面";
        anchors.fill: parent
        textLabel: "通道"+(Settings.paramsSetCh()+1)+" 参考电平";
        onClick: {
            root.flipped = true
            root.state = "toBack"
            loadParam()
        }
    }
    back:LineEdit {
        id: numberEdit;
        objectName: "参考电平翻转控件背面";
        anchors.fill: parent
        unit: "dBm"
        rangeMode: true
        min:"-120"
        max:"10"
        prefix: btn_centerfreq.textLabel
        okBtn: true
        onAccepted: {
            root.flipped = false;
            root.state = "toFront";
            globalConsoleInfo("★★ReferenceLevel.qml响应onAccepted,查看root.parentPointer---"+root.parentPointer);
            root.parentPointer.focus=true;//侧边栏获得焦点
        }
        onOkBtnClicked: {
            root.flipped = false
            root.state = "toFront"
            globalConsoleInfo("★★ReferenceLevel.qml响应onOkBtnClicked,查看root.parentPointer---"+root.parentPointer);
            root.parentPointer.focus=true;//侧边栏获得焦点
            setParam(numberEdit.min, numberEdit.max)
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
        //idScopeView.updateSepctrumAxisY(numberEdit.min, numberEdit.max)
    }
    function loadParam()
    {
        numberEdit.min = Settings.reflevelMin()
        numberEdit.max = Settings.reflevelMax()

        btn_centerfreq.textLabel = "通道"+(Settings.paramsSetCh()+1)+" 参考电平";
        //numberEdit.text = Settings.centerFreq()
    }
    function setParam(min, max)
    {

        if(0){
            messageBox.title = "警告"
            messageBox.note  = "参数超出范围,已自动为您校正!"
            messageBox.isWarning = true
            messageBox.visible = true
        }

        if(parseFloat(min) !== Settings.reflevelMin())
            Settings.reflevelMin(Com.OpSet, min)
        if(parseFloat(max) !== Settings.reflevelMax())
            Settings.reflevelMax(Com.OpSet, max)
        idScopeView.updateSepctrumAxisY(min, max)
        //analyzeMenu.updateParams()
    }
}
