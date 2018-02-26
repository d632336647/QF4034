import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../Inc.js" as Com
import "../UI"


Flipable{
    id:root;
    objectName: "sampRate"
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
        id: numberEdit;
        anchors.fill: parent
        unit: "MHz"
        text: "100"
        okBtn: true
        prefix: btnsamplerate.textLabel
        onAccepted: {
            root.flipped = false
            root.state = "toFront"
            root.parentPointer.focus=true;//侧边栏获得焦点
            setParam(numberEdit.text);
        }
        onOkBtnClicked: {
            root.flipped = false
            root.state = "toFront"
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
    function returnParent()
    {
        gatherMenu.state = "HIDE"
        idRightPannel.focus = true
    }
    function selfPressed(key_code)
    {
        if( key_code === Qt.Key_F3 )
            numberEdit.okBtnClicked()
        else
            loadParam()
        numberEdit.borderColor = "#67696B"
        gatherMenu.focus = true
    }
    function keyPressed()
    {
        numberEdit.showSelectStyle()
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
