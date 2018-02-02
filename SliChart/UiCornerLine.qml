import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import "../qml/Inc.js" as Com

Item {
    id:root
    width: 200;
    height: 200;
    //border.color: "#808080";

    property string btnName: "";
    property string textLabel: "";
    property string textData: "";
    property bool hovered: false;

    property color themeColor: "#67696B"
    property color titleColor: "#ffffff"
    property bool  showHeadLine: false
    signal clicked;

    Rectangle{
        id:topLine
        anchors.fill: parent
        color: "#00FFFFFF";
        border.color:"#67696B"
        radius: 4
        Item{
            anchors.top: parent.top
            anchors.topMargin: 1
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.right:parent.right
            anchors.rightMargin: 40
            height: 10
            visible: showHeadLine
            LinearGradient{
                anchors.fill: parent
                gradient: Gradient{
                    GradientStop{ position: 0.0; color: "#B1B1B1"}
                    GradientStop{ position: 0.6; color: "black"}
                    //GradientStop{ position: 1.0; color: "black"}
                }
                start: Qt.point(0, 0)
                end: Qt.point(parent.width, parent.height)
            }
        }
    }
}
