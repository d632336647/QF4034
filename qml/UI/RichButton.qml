import QtQuick 2.7
import "../Inc.js" as Com

Item{
    id: root;
    width: 192;
    height: 91;
    property color bgColor: "#000000"
    Rectangle{
        anchors.fill: parent
        color: bgColor
    }
    Canvas{
        anchors.fill: parent
        contextType: "2d";
        onPaint: {
            context.lineWidth = 1.5;
            context.strokeStyle = "#67696B";
            context.fillStyle = "#121212";
            context.beginPath();
            context.moveTo(0 ,0);
            context.lineTo(0.9*width , 0);
            context.lineTo(width , width-0.9*width);
            context.lineTo(width , 0.7*height);
            context.lineTo(0.6*width , 0.7*height);
            context.lineTo(0.4*width , height);
            context.lineTo(0.1*width, height);
            context.lineTo(0, 0.75*height);
            context.closePath();
            context.fill();
            context.stroke();
        }
    }
    Canvas{
        anchors.fill: parent
        contextType: "2d";
        onPaint: {
            context.lineWidth = 1.5;
            context.strokeStyle = "#67696B";
            context.fillStyle = "#121212";
            context.beginPath();
            context.moveTo(width , height);
            context.lineTo(0.44*width , height);
            context.lineTo(0.61*width , 0.74*height);
            context.lineTo(width , 0.74*height);
            context.closePath();
            context.fill();
            context.stroke();
        }
    }
}
