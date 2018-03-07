import QtQuick 2.7
import "../Inc.js" as Com
import "../Lib.js" as Lib

Rectangle {
    id: root
    property alias editfocus: input.focus //
    property alias text: input.text //
    property alias hint: hint.text //
    property alias prefix: prefix.text //
    property alias unit: unit.text //
    property alias echoMode: input.echoMode // echoMode: TextInput.Password  密码模式 或者 正常模式(默认)
    property alias inputMask: input.inputMask
    property alias min: minval.text
    property alias max: maxval.text
    property alias inputFocus: input.focus
    property alias rangeMinFocus: minval.focus
    property alias rangeMaxFocus: maxval.focus
    property int  fontSize: 15 //定义字体大小
    property bool showHint:false
    property bool hovered:false
    property bool focused:false
    property bool okBtn: false
    property bool rangeMode: false
    property color borderColor: "#67696B"
    signal accepted
    signal okBtnClicked
    signal areaClicked
    height:  60;
    radius: 4
    Rectangle {
        id:wrapper
        anchors.fill: parent
        color: "#121212"
        border.color: borderColor
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
            PropertyAnimation {
                id: clickAnim;
                target: root;
                property: "borderColor";
                to: "white"
                duration: 200
                onStopped: {
                    //wrapper.border.color = "#67696B"
                }
            }
        }


        TextInput {
            objectName:"theUserinput"
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

            validator:RegExpValidator{regExp: /[+-]?\d+[\.]?\d+$/}
            //inputMask: "####.##"
            activeFocusOnPress: true
            onAccepted: root.accepted()  //链接到信号
            Rectangle{
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: "white"
            }
            Keys.enabled: true
            Keys.forwardTo: [input]
            Keys.onPressed:{
                switch(event.key)
                {
                case Qt.Key_Up:
                case Qt.Key_Down:
                    event.accepted = true;
                    break;
                default:
                    break;
                }
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
                validator:RegExpValidator{regExp: /[+-]?\d+[\.]?\d+$/}
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
                Keys.enabled: true
                Keys.forwardTo: [minval]
                Keys.onPressed:{
                    switch(event.key)
                    {
                    case Qt.Key_Right:
                    case Qt.Key_Left:
                        console.log("cursorPosition:", cursorPosition)
                        maxval.focus = true
                        maxval.selectAll()
                        event.accepted = true;
                        break;
                    case Qt.Key_Up:
                    case Qt.Key_Down:
                        event.accepted = true;
                        break;
                    default:
                        break;
                    }
                }
            }
            Text {
                id:mid
                font.family: "FontAwesome"
                font.pixelSize: 13
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
                validator:RegExpValidator{regExp: /[+-]?\d+[\.]?\d+$/}
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
                Keys.enabled: true
                Keys.forwardTo: [maxval]
                Keys.onPressed:{
                    switch(event.key)
                    {
                    case Qt.Key_Right:
                    case Qt.Key_Left:
                        minval.focus = true
                        minval.selectAll()
                        event.accepted = true;
                        break;
                    case Qt.Key_Up:
                    case Qt.Key_Down:
                        event.accepted = true;
                        break;
                    default:
                        break;
                    }
                }
            }
        }
        Text{
            id:unit
            anchors { left: input.right; right: parent.right; top: input.top; bottom: input.bottom }
            anchors.rightMargin: 14
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
    Keys.enabled: true
    Keys.forwardTo: [input, minval, maxval]
    Keys.onPressed:{
        if(Lib.operateSpecView(event.key))
        {
            root.borderColor = "#67696B"
            root.parent.loadParam()
            root.parent.returnParent()
            event.accepted = true;
            return
        }
        switch(event.key)
        {
        case Qt.Key_F1:
        case Qt.Key_F8:
            root.borderColor = "#67696B"
            root.parent.loadParam()
            root.parent.returnParent()
            break;
        case Qt.Key_F2:
        case Qt.Key_F3:
        case Qt.Key_F4:
        case Qt.Key_F5:
        case Qt.Key_F6:
            root.parent.selfPressed(event.key)
            return;
        case Qt.Key_Enter:
            root.okBtnClicked();
            root.borderColor = "#67696B"
            break;
        default:
            break;
        }
        event.accepted = true;
    }

    function showSelectStyle()
    {
        clickAnim.start();
        if(!rangeMode){
            input.focus = true
            input.selectAll();
        }
        else{
            minval.focus = true
            minval.selectAll()
        }
    }
    //文本框选中状态
    function selectAllOfTextinput()
    {
        if(input.focus)
        {
            input.selectAll();
        }
        else if(minval.focus)
        {
            minval.selectAll();
        }
        else if(maxval.focus)
        {
            maxval.selectAll();
        }
    }
}
