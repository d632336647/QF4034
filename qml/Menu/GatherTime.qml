import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../Inc.js" as Com
import "../UI"


Flipable{
    id:root;
    width: Com.RightMenuWidth
    height: 91
    signal  showComplete
    property int angle : 0  //翻转角度
    property bool flipped : false //用来标志是否翻转
    property alias text:btn_capturetime.textLabel
    property alias unit:numberEdit.unit
    property alias readOnly:btn_capturetime.readOnly
    Rectangle{
        color: Com.bgColorMain
    }

    front: RightButton {
        id: btn_capturetime;
        anchors.fill: parent
        textLabel: "采集时间";
        onClick: {
            root.flipped = true
            root.state = "toBack"
            root.focus=true;
            loadParam()
        }
    }
    back: LineEdit {
        id: numberEdit;
        anchors.fill: parent
        unit: "Sec"
        text: "123"
        okBtn: true
        prefix: btn_capturetime.textLabel
        onAccepted: {
            root.flipped = false
            root.state = "toFront"
            root.focus=true;
            setParam();
        }
        onOkBtnClicked: {
            root.flipped = false
            root.state = "toFront"
            root.focus=true;
            setParam()
        }
        onAreaClicked: {
            root.flipped = false
            root.state = "toFront"
            root.focus=true;
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
                root.showComplete();
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
        NumberAnimation{property:"angle";duration:300}
    }
    function loadParam()
    {
        numberEdit.text = Settings.captureSize()
    }
    function setParam(val)
    {
        Settings.captureSize(Com.OpSet, val)
        gatherMenu.updateParams()

    }

}
