import QtQuick 2.7
import "../Inc.js" as Com

Rectangle{
    id: rightBtn;
    width: Com.RightMenuWidth-8;
    height: 91;
    radius: 4;
    color: "#121212";
    border.color: "#67696B"
    border.width: 1
    property string textLabel: "Label";
    property string textData: "";
    property bool bHovered: false;
    property alias icon: iconFont.text
    property int selectBorderSize: 2
    property bool readOnly: false;
    signal click();

    Text{
        id: btnLabel;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.top: parent.top;
        anchors.topMargin: btnData.text.length ? 20 : 30;
        font.family: Com.fontFamily
        font.pixelSize: 18;
        text: textLabel;
        color: rightBtn.readOnly ? "#646464" : "white";
        horizontalAlignment: Text.AlignHCenter;
        verticalAlignment: Text.AlignVCenter;
        font.bold: true;
    }
    Text{
        id: btnData;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.top: btnLabel.bottom;
        anchors.topMargin: 10;
        font.pixelSize: 15;
        text: textData;
        color: "#D29928";
        horizontalAlignment: Text.AlignHCenter;
        verticalAlignment: Text.AlignVCenter;
        font.bold: true;
        visible: btnData.text.length ? true : false;
    }
    Text{
        id:iconFont
        anchors{top:parent.top; bottom: parent.bottom;left:parent.left}
        anchors.leftMargin: 8
        anchors.bottomMargin: 12
        font.family: "FontAwesome"
        color:btnLabel.color
        font.pixelSize: 20
        text: ""
        verticalAlignment: Text.AlignVCenter
    }
    Item{
        id:selcetBorder
        anchors.fill: parent
        visible: false
        Rectangle{
            color: Com.selectBorderColor
            width: rightBtn.width*0.2
            height:  selectBorderSize
            anchors{top:parent.top; left: parent.left}
        }
        Rectangle{
            color: Com.selectBorderColor
            width: selectBorderSize
            height: rightBtn.height*0.2
            anchors{top:parent.top; left: parent.left}
        }

        Rectangle{
            color: Com.selectBorderColor
            width: rightBtn.width*0.2
            height: selectBorderSize
            anchors{top:parent.top; right: parent.right}
        }
        Rectangle{
            color: Com.selectBorderColor
            width: selectBorderSize
            height: rightBtn.height*0.2
            anchors{top:parent.top; right: parent.right}
        }

        Rectangle{
            color: Com.selectBorderColor
            width: rightBtn.width*0.2
            height: selectBorderSize
            anchors{bottom:parent.bottom; left: parent.left}
        }
        Rectangle{
            color: Com.selectBorderColor
            width: selectBorderSize
            height: rightBtn.height*0.2
            anchors{bottom:parent.bottom; left: parent.left}
        }

        Rectangle{
            color: Com.selectBorderColor
            width: rightBtn.width*0.2
            height: selectBorderSize
            anchors{bottom:parent.bottom; right: parent.right}
        }
        Rectangle{
            color: Com.selectBorderColor
            width: selectBorderSize
            height: rightBtn.height*0.2
            anchors{bottom:parent.bottom; right: parent.right}
        }
    }
    MouseArea{
        id: btnMouseArea;
        anchors.fill: parent;
        hoverEnabled: true;
        onClicked: {
            if(!readOnly)
                click();
        }
        onEntered:
        {
            bHovered = true
            pressedAnim.start()
            releasedAnim.stop()
        }
        onExited:
        {
            releasedAnim.start()
            pressedAnim.stop()
            bHovered = false
        }
        PropertyAnimation {
            id: pressedAnim;
            target: rightBtn;
            property: "color";
            to: "#1F1F1F";
            duration: Com.animationSpeed
        }
        PropertyAnimation {
            id: releasedAnim;
            target: rightBtn;
            property: "color";
            to: "#121212"
            duration: Com.animationSpeed
        }
        PropertyAnimation {
            id: clickAnim;
            target: rightBtn;
            property: "border.color";
            to: "white"
            duration: 200
            onStopped: {
                rightBtn.border.color = "#67696B"
                rightBtn.click()
            }
        }
    }
    function keyPressed()
    {
        clickAnim.start();
    }
    function selected(flag)
    {
        selcetBorder.visible = flag
    }
    /*
    border.width: btnMouseArea.pressed ? 3 : 2;
    border.color: (bHovered || btnMouseArea.pressed) ? "#3d9291" : "#ACCDD2";
    gradient: Gradient{
        GradientStop{ position: 0.0; color: bHovered ? "#a0c3be" : "#777b96"}
        GradientStop{ position: 0.7; color: bHovered ? "#095247" : "#001e42"}
        GradientStop{ position: 1.0; color: bHovered ? "#024b42" : "#040436"}
    }
    */

}
