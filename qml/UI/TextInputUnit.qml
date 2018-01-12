import QtQuick 2.0
import "../Inc.js" as Com

Rectangle{
    implicitHeight: 35;
    implicitWidth: 180;
    color: "#eeeeee";
    border.color: bHovered ? "#909090" : "#d0d0d0";
    radius: 5;

    property alias labelInput: input_text.text
    property string labelUnit: "";
    property bool bHovered: false;
    property bool bFocused: false;
    property color unitColor: "#e0e0e0";

    property string type: Com.ElementType_TextInput

    TextInput{
        id: input_text;
        color: "#333";
        focus: bFocused;
        clip: true;
        anchors.verticalCenter: parent.verticalCenter;
        anchors.left: parent.left;
        anchors.leftMargin: 5;
        anchors.right: input_unit.left;
        anchors.rightMargin: 5;        
    }
    Rectangle{
        id: input_unit;
        width: labelUnit.length * 15;
        anchors.top: parent.top;
        anchors.topMargin: 1;
        anchors.right: parent.right;
        anchors.rightMargin: 1;
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 1;
        radius: 5;
        color: unitColor;
        Rectangle{
            height: parent.height;
            anchors.left: parent.left;
            width: labelUnit.length ? 5 : 0;
            color: unitColor;
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter;
            anchors.right: parent.right;
            anchors.rightMargin: 5;
            font.pixelSize: 18;
            color: "#333";
            text: labelUnit;
        }
    }

    MouseArea{
        anchors.fill: parent;
        hoverEnabled: true;
        onClicked: bFocused = true;
        onEntered: bHovered = true;
        onExited: {bHovered = false; bFocused = false}
    }
}
