import QtQuick 2.7
import "../Inc.js" as Com

Rectangle {
    id: root
    property alias text: input.text //
    property alias hint: hint.text //
    property alias prefix: prefix.text //
    property alias unit: unit.text //
    property alias echoMode: input.echoMode // echoMode: TextInput.Password  密码模式 或者 正常模式(默认)
    property alias inputMask: input.inputMask
    property alias min: minval.text
    property alias max: maxval.text
    property alias inputFocus: input.focus
    property int  fontSize: 18 //定义字体大小
    property bool showHint:false
    property bool hovered:false
    property bool focused:false
    property bool okBtn: false
    property bool rangeMode: false
    signal accepted
    signal okBtnClicked
    signal areaClicked
    height:  60;
    radius: 4
    Rectangle {
        id:wrapper
        anchors.fill: parent
        color: "#121212"
        border.color: "#67696B"
        border.width: 1
        radius: 4
        clip:true
        Text {
            id: hint  //水印层文字显示
            visible: showHint;
            anchors { fill: parent; leftMargin: 14 }
            verticalAlignment: Text.AlignVCenter //垂直对齐
            horizontalAlignment: Text.AlignHCenter
            text: qsTr("100")
            font.pixelSize: fontSize //字体大小
            color: "white"
            opacity: input.length ? 0 : 1 //不透明度
        }
        Text {
            id: prefix
            anchors { top: parent.top; topMargin: 8; left:parent.left; leftMargin: 8}
            font.family: Com.fontFamily
            verticalAlignment: Text.AlignVCenter  //垂直对齐
            horizontalAlignment: Text.AlignLeft
            font.pixelSize: fontSize
            font.bold: true;
            color: "white"
            //opacity: !hint.opacity //和hint相反
        }
        MouseArea{
            id: btnInputArea;
            anchors.fill: parent;
            hoverEnabled: true;
            //propagateComposedEvents: true /*允许传递鼠标事件*/
            onClicked:{
                //input.focus = true;
                //areaClicked()
            }
            onEntered:
            {
                hovered = true
                pressedAnim.start()
                releasedAnim.stop()
            }
            onExited:
            {
                releasedAnim.start()
                pressedAnim.stop()
                hovered = false

            }
            PropertyAnimation {
                id: pressedAnim;
                target: wrapper;
                property: "color";
                to: "#1F1F1F";
                duration: 200
            }
            PropertyAnimation {
                id: releasedAnim;
                target: wrapper;
                property: "color";
                to: "#121212"
                duration: 200
            }
        }


        TextInput {
            id: input
            visible: !rangeMode
            enabled: !rangeMode
            focus: focused
            width: parent.width * 0.3
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height*0.3
            y:parent.height *0.3
            verticalAlignment: Text.AlignVCenter  //垂直对齐
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: fontSize
            passwordCharacter:"*"
            selectByMouse: true //是否可以选择文本
            selectionColor: "white"
            selectedTextColor: "black"
            color: "white"
            activeFocusOnPress: true
            onAccepted: root.accepted()  //链接到信号
            validator: RegExpValidator { regExp: /[+-]?\d+(\.\d+)?$/ }
            //validator:  DoubleValidator { bottom: -1000.0; top:1000 }
            Rectangle{
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "white"
            }

        }
        Item{
            id: rangeInput
            visible: rangeMode
            enabled: rangeMode
            width: parent.width * 0.5
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height*0.3
            y:parent.height *0.3
            TextInput{
                id:minval
                text: "-100"
                color: "white"
                font.pixelSize: fontSize
                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width * 0.4
                height: parent.height
                selectByMouse: true //是否可以选择文本
                selectionColor: "white"
                selectedTextColor: "black"
                verticalAlignment: Text.AlignVCenter  //垂直对齐
                horizontalAlignment: Text.AlignHCenter
                Rectangle{
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "white"
                }
            }
            Text {
                id:mid
                font.family: "FontAwesome"
                font.pixelSize: 16
                color: "white"
                text: "\uf07e"
                anchors.top: parent.top
                anchors.left: minval.right
                width: parent.width * 0.2
                height: parent.height
                verticalAlignment: Text.AlignVCenter  //垂直对齐
                horizontalAlignment: Text.AlignHCenter
            }
            TextInput{
                id:maxval
                text: "10"
                color: "white"
                font.pixelSize: fontSize
                anchors.top: parent.top
                anchors.left: mid.right
                width: parent.width * 0.4
                height: parent.height
                selectByMouse: true //是否可以选择文本
                selectionColor: "white"
                selectedTextColor: "black"
                verticalAlignment: Text.AlignVCenter  //垂直对齐
                horizontalAlignment: Text.AlignHCenter
                Rectangle{
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1
                    color: "white"
                }
            }
        }
        Text{
            id:unit
            anchors { left: input.right; right: parent.right; top: input.top; bottom: input.bottom }
            anchors.rightMargin: 20
            verticalAlignment: Text.AlignVCenter  //垂直对齐
            horizontalAlignment: Text.AlignRight
            font.pixelSize: fontSize
            color: "white"
            text:""
        }


        Canvas{
            anchors.fill: parent
            contextType: "2d";
            onPaint: {
                context.lineWidth = 1.2;
                context.strokeStyle = "#67696B";
                context.fillStyle = "#535557";
                context.beginPath();
                context.moveTo(width, height);
                context.lineTo(0.44*width , height);
                context.lineTo(0.61*width , 0.74*height);
                context.lineTo(width , 0.74*height);
                context.closePath();
                context.fill();
                context.stroke();
            }
        }
        Rectangle{
            id:okButton
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 2
            anchors.right: parent.right
            anchors.rightMargin: 2
            width: parent.width*0.4
            height: 22
            color:"#00000000"
            enabled: okBtn
            visible: okBtn
            Text {
                id: okText
                anchors.fill: parent
                verticalAlignment: Text.AlignVCenter  //垂直对齐
                horizontalAlignment: Text.AlignLeft
                color: "#C4C4C4"
                text: "   确定"
                font.bold: true
                font.pixelSize: 14
                font.family: Com.fontFamily
            }
            MouseArea{
                anchors.fill: parent
                hoverEnabled: true
                onEntered:{
                    okText.color = "white"
                }
                onExited:{
                    okText.color = "#C4C4C4"
                }
                onClicked: {
                    okBtnClicked()
                }
            }
        }

    }
    onInputFocusChanged:
    {
    //    if(inputFocus)
    //        wrapper.border.color = "red"
    //    else
    //        wrapper.border.color = "#67696B"
    }
}
