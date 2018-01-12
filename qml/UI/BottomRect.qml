import QtQuick 2.0
import "../Inc.js" as Com

Item {
    id:root
    implicitWidth: 160;
    implicitHeight: 28;

    //border.color: "#808080";


    property string btnName: "";
    property string textLabel: "";
    property string textData: "";
    property bool hovered: false;

    property color themeColor: "#67696B"
    property color titleColor: "#ffffff"

    signal clicked;

    Rectangle{
        id:topLine
        width: parent.width-2
        anchors.right: parent.right
        anchors.top: parent.top
        color: root.themeColor;
        height: 1
    }
    Rectangle{
        id:topBackground
        width:  parent.width*0.3
        height: parent.height * 0.4
        anchors.right: parent.right
        anchors.top: parent.top
        //color: "#D6CF9A";
        color: "black"//Com.BGColor_main
        clip: true
        Rectangle{
            id: topMidRect
            anchors.top: parent.top
            anchors.right: parent.right
            width:  parent.width*0.70
            height: width
            color: root.themeColor;
        }
        Rectangle{
            id: topLeftRect
            anchors.top: topMidRect.top
            anchors.topMargin: -height/2
            anchors.left: topMidRect.left
            anchors.leftMargin: -width/2
            width:  parent.height *2
            height: width
            color: root.themeColor;
            rotation: 45
        }

        Rectangle{
            id:topRightRect
            anchors.top: parent.top
            anchors.topMargin: -height/2
            anchors.right: topMidRect.right
            anchors.rightMargin:-width/2
            width:  parent.height*2
            height: width
            rotation: 45
            color: Com.BGColor_main//"red"
        }
    }




    Rectangle{
        id:bottomLine
        anchors.bottom: parent.bottom
        width: parent.width-6
        height: 1
        color:root.themeColor
    }
    Rectangle{
        id: bottomMidRect
        width: parent.width * 0.2
        anchors.bottom: parent.bottom
        height: parent.height * 0.2
        color: Com.BottomBGColor;
        clip: true
        Rectangle{
            id: bottomBackground
            width:  parent.width*0.8
            height: width
            //color: "#D6CF9A";
            color: root.themeColor;
        }
        Rectangle{
            id:bottomRight
            anchors.left: bottomBackground.left
            anchors.leftMargin: bottomBackground.width-width/2
            width:  parent.height*2
            height: width
            rotation: 45
            color: root.themeColor
        }
        Rectangle{
            id:bottomLeft
            anchors.right: bottomMidRect.right
            anchors.rightMargin: bottomMidRect.width-width/2
            width:  parent.height*2
            height: width
            rotation: 45
            color: Com.BottomBGColor;
        }
    }

    Text{
        id:textTile
        anchors.top: topLine.bottom
        anchors.topMargin: 2
        anchors.left: parent.left
        anchors.leftMargin: 4;
        horizontalAlignment: Text.AlignLeft;
        verticalAlignment: Text.AlignVCenter;
        text: textLabel
        font.family: Com.fontFamily
        color: titleColor;
        font.pixelSize: 14
    }



    Text{
        anchors.bottom: bottomLine.bottom
        anchors.bottomMargin: 2
        anchors.left: textTile.right
        anchors.leftMargin: 4;
        horizontalAlignment: Text.AlignLeft;
        verticalAlignment: Text.AlignVCenter;
        text:textData;
        font.family: Com.fontFamily
        color: "yellow"
        font.pixelSize: 12
    }

    Text{
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignLeft;
        verticalAlignment: Text.AlignVCenter;
        text:btnName;
        font.family: Com.fontFamily
        color: titleColor
        font.pixelSize: 16
    }


    MouseArea{
        anchors.fill: parent;
        hoverEnabled: true;
        onClicked: root.clicked()
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
            target: root;
            property: "themeColor";
            to: "#D29928";
            duration: Com.animationSpeed
        }
        PropertyAnimation {
            id: releasedAnim;
            target: root;
            property: "themeColor";
            to: "#67696B"
            duration: Com.animationSpeed
        }
    }


}
