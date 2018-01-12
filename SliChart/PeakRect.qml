import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../qml/Inc.js" as Com

Rectangle{
    id:root
    width: 12
    height: 26
    color: "#00FFFFFF"
    visible: false
    Canvas{
        anchors.fill: parent
        contextType: "2d";
        onPaint: {
            context.lineWidth = 1;
            //context.strokeStyle = "#4AEC91";
            //context.fillStyle = "#D038ad6b";
            context.strokeStyle = "black";
            context.fillStyle = "#E06FFF26";
            context.beginPath();
            context.moveTo(0.5*width ,  0);
            context.lineTo(width , 0.5*height);
            context.lineTo(0.5*width , height);
            context.lineTo(0 , 0.5*height);
            context.closePath();
            context.fill();
            context.stroke();
        }
    }
}
