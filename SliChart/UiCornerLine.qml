import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
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

    signal clicked;

    Rectangle{
        id:topLine
        anchors.fill: parent
        color: "#00FFFFFF";
        border.color:"#67696B"
        radius: 4
        Canvas{
            anchors.fill: parent
            contextType: "2d";
            visible: false
            onPaint: {
                context.lineWidth = 2;
                context.strokeStyle = "#67696B";
                //context.fillStyle = "#121212";
                context.beginPath();
                context.moveTo(0 , 0);
                context.lineTo(width , 0);
                context.lineTo(width , height);
                context.lineTo(0 , height);
                context.lineTo(0 , 0);
                context.closePath();
                //context.fill();
                context.stroke();
            }
        }
    }
}
