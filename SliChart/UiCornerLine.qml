import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "../qml/Inc.js" as Com

Item {
    id:root
    width: Com.RightMenuWidth;
    height: 200;
    //border.color: "#808080";

    property string cornerName: "";
    property string textLabel: "";
    property string textData: "";
    property bool   hovered: false;

    property color themeColor: "#67696B"
    property color titleColor: "#ffffff"
    property color cornerTextColor: "#C0C0C0"
    property bool  showHeadLine: false
    property bool  showName: false
    signal clicked;

    Rectangle{
        id:topLine
        anchors.fill: parent
        color: "#00FFFFFF";
        border.color:"#67696B"
        radius: 4
        Item{
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right:parent.right
            anchors.leftMargin: 58
            anchors.rightMargin: 40
            height: 1
            visible: showHeadLine
            LinearGradient{
                anchors.fill: parent
                gradient: Gradient{
                    GradientStop{ position: 0.0; color: Com.series_color1}
                    GradientStop{ position: 0.8; color: "#67696B"}
                    //GradientStop{ position: 1.0; color: "black"}
                }
                start: Qt.point(0, 0)
                end: Qt.point(parent.width, 0)
            }
        }
        Item{
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.topMargin: 16
            anchors.bottomMargin: 4
            width: 1
            visible: showHeadLine
            LinearGradient{
                anchors.fill: parent
                gradient: Gradient{
                    GradientStop{ position: 0.0; color: Com.series_color1}
                    GradientStop{ position: 0.8; color: "#67696B"}
                }
                start: Qt.point(0, 0)
                end: Qt.point(0, parent.height)
            }
        }
    }

    Canvas{
        id:offStyle
        visible: showName          //realTimeMode
        anchors.top: parent.top
        anchors.left: parent.left
        width: 60
        height: 18
        contextType: "2d";
        onPaint: {
            context.lineWidth = 1.5;
            context.strokeStyle = "#00000000";
            context.fillStyle = "#343536";
            context.beginPath();
            context.moveTo(0, 0);
            context.lineTo(width , 0);
            context.lineTo(0.6*width , height);
            context.lineTo(0 , height);
            context.closePath();
            context.fill();
            context.stroke();
        }
    }
    Canvas{
        id:onStyle
        visible: showHeadLine          //realTimeMode
        anchors.top: parent.top
        anchors.left: parent.left
        width: 60
        height: 18
        contextType: "2d";
        onPaint: {
            context.lineWidth = 1.5;
            context.strokeStyle = "#00000000";
            context.fillStyle = Com.series_color1;
            context.beginPath();
            context.moveTo(0, 0);
            context.lineTo(width , 0);
            context.lineTo(0.6*width , height);
            context.lineTo(0 , height);
            context.closePath();
            context.fill();
            context.stroke();
        }
    }
    Text {
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.left: parent.left
        anchors.leftMargin: 2
        font.pixelSize: 12
        color: cornerTextColor
        font.family: "幼圆"
        text: "通道"+(chIndex+1)
    }
}

