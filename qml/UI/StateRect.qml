import QtQuick 2.0
import "../Inc.js" as Com

Item {
    id:root
    implicitWidth: 167.5;
    implicitHeight: 20;

    //border.color: "#808080";


    property string btnName: "";
    property string textLabel: "";
    property string textData: "";
    property string textIcon: "";
    property bool hovered: false;

    property color themeColor: "#67696B"
    property color titleColor: "#ffffff"
    property color iconColor:  "#ffffff"
    signal clicked;


    Rectangle{
        id:bottomLine
        anchors.fill: parent
        border.color: root.themeColor
        border.width: 1
        radius: 4
        color: "#00000000"
    }

    Text{
        id:textTile
        //anchors.top: parent.top
        //anchors.topMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10;
        horizontalAlignment: Text.AlignLeft;
        verticalAlignment: Text.AlignVCenter;
        text: textLabel
        font.family: Com.fontFamily
        color: titleColor;
        font.pixelSize: 14
    }



    Text{
        //anchors.bottom: parent.bottom
        //anchors.bottomMargin: 2
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: textTile.right
        anchors.leftMargin: 10;
        horizontalAlignment: Text.AlignLeft;
        verticalAlignment: Text.AlignVCenter;
        text:textData;
        font.family: Com.fontFamily
        color: "yellow"
        font.pixelSize: 12
    }
    Text{
        id:btnIcon
        anchors.top: parent.top
        anchors.right: parent.right
        width: parent.width*0.37
        height: parent.height
        horizontalAlignment: Text.AlignLeft;
        verticalAlignment: Text.AlignVCenter;
        text: textIcon;
        font.family: "FontAwesome"
        color: iconColor
        font.pixelSize: 16
    }
    Text{
        id:idBtn
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: btnIcon.text.length>0?btnIcon.left:parent.right
        anchors.rightMargin:btnIcon.text.length>0?4:0
        height: parent.height
        horizontalAlignment: btnIcon.text.length>0?Text.AlignRight:Text.AlignHCenter;
        verticalAlignment: Text.AlignVCenter;
        text:btnName;
        font.family: Com.fontFamily
        color: titleColor
        font.pixelSize: 14
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
    PropertyAnimation {
        id: clickAnim;
        target: root;
        property: "themeColor";
        to: "white"
        duration: 100
        onStopped: {
            root.themeColor = "#67696B"
        }
    }
    Connections{
        target: root
        onClicked:{
            clickAnim.start()
        }
    }

}
