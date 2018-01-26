import QtQuick 2.0
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import "../qml/Inc.js" as Com

Item {
    id:root
    property color  backgroundColor: "red"
    property bool   hoverd: false
    property bool   disabled: false
    property bool   checked: false
    property alias  iconFontText: iconFont.text
    property color  textColor: "white"
    property string mode: "checkbox"  //  button / checkbox
    property string tips: ""
    signal clicked
    visible: true
    width: 30
    height: 30
    Text{
        id:iconFont
        anchors.centerIn: parent
        width: parent.width - 2
        height: parent.height - 2
        font.family: "FontAwesome"
        font.pixelSize: 22
        color: disabled ? "#67696B" : textColor
        text: "\uf1de"
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }
    Rectangle{
        id:bg
        anchors.fill: parent
        border.color: "#67696B"
        radius: 4
        color: checked ? "#00000000" : "#90000000"
    }
    ToolTip {
        id: toolTips
        parent: root
        visible: root.hoverd
        font.family: Com.fontFamily
        text: root.tips
        contentItem: Text {
            text: toolTips.text
            font: toolTips.font
            color: "white"
        }
        background: Rectangle {
            border.color: "#67696B"
            color: "#000000"
            radius: 4
        }
    }
    MouseArea{
        id: btnMouseArea;
        anchors.fill: parent;
        enabled: !disabled
        hoverEnabled: true;
        onClicked: {
            checked = !checked
            root.clicked()
        }
        onEntered:{
            pressedAnim.start()
            releasedAnim.stop()
            hoverd = true
        }
        onExited:{
            releasedAnim.start()
            pressedAnim.stop()
            hoverd = false
        }
        onPressed:{
            if(mode == "button"){
                bg.border.color = "#D29928"
                iconFont.color  = "#D29928"
            }
        }
        onReleased: {
            if(mode == "button"){
                bg.border.color = "#D3D4D4"
                iconFont.color  = textColor
            }
        }
        PropertyAnimation {
            id: pressedAnim;
            target: bg;
            property: "border.color";
            to: "#D3D4D4";
            duration: 300
        }
        PropertyAnimation {
            id: releasedAnim;
            target: bg;
            property: "border.color";
            to: "#67696B"
            duration: 300
        }
    }


    function checkboxClick()
    {

        checked = !checked
        root.clicked()
    }
}
