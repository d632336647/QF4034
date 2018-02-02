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
    objectName: "centerFreq"
    signal  showComplete
    property int angle : 0  //翻转角度
    property bool  flipped :  false //用来标志是否翻转
    property var parentPointer: undefined
    property alias inputFocus:numberEdit.inputFocus
    property bool  readOnly:false //为了和采样率的属性保持一致
    Rectangle{
        color: Com.BGColor_main
    }

    front: RightButton {
        id: btn_centerfreq;
        anchors.fill: parent
        textLabel: "通道"+(Settings.paramsSetCh()+1)+" 中心频率";
        onClick: {
            root.flipped = true;
            root.state = "toBack";
            loadParam()
        }
    }
    back: LineEdit {
        id: numberEdit;
        anchors.fill: parent
        unit: "MHz"
        text: "60"
        prefix: btn_centerfreq.textLabel
        okBtn: true
        onAccepted: {
            root.flipped = false
            root.state = "toFront"
            root.parentPointer.focus = true;
            setParam(numberEdit.text)

        }
        onOkBtnClicked: {
            root.flipped = false
            root.state = "toFront"
            root.parentPointer.focus = true;
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
    function returnParent()
    {
        analyzeMenu.state = "HIDE"
        idRightPannel.focus = true
    }
    function selfPressed()
    {
        numberEdit.borderColor = "#67696B"
        analyzeMenu.focus = true
    }
    function keyPressed()
    {
        numberEdit.showSelectStyle()
    }
    function loadParam()
    {
        numberEdit.text = Settings.centerFreq()
        btn_centerfreq.textLabel = "通道"+(Settings.paramsSetCh()+1)+" 中心频率";
    }
    function setParam(val)
    {
        if(0){
            messageBox.title = "警告"
            messageBox.note  = "参数超出范围,已自动为您校正!"
            messageBox.isWarning = true
            messageBox.visible = true
        }
        if(parseFloat(val) !== Settings.centerFreq()){
            Settings.centerFreq(Com.OpSet, val)
            analyzeMenu.reloadParams()
            analyzeMenu.updateParams()
        }

    }

}
