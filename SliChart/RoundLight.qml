import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../qml/Inc.js" as Com

Item{
    id:root
    width: width
    height: width
    property real  r: width
    property color color: "red"
    Canvas{
        id:bg
        anchors.fill: parent
        contextType: "2d";
        visible: false
        onPaint: {
            context.lineWidth = 1;
            //createRadialGradient(x1,y1,r1,x2,y2,r2) //起点终点都是圆//起点圆可以看成比较大的原点
            var radial = context.createRadialGradient(x+r/2, y+r/2, 1, x+r/2, y+r/2, 0.45*r); //重合的圆心坐标
            radial.addColorStop(0, color);
            radial.addColorStop(1,'#00000000');
            context.strokeStyle = '#00000000';
            context.fillStyle = radial;
            context.arc(x+r/2, y+r/2, r, 0, Math.PI*2);
            context.fill();  //填充
            context.stroke();
        }
    }
    Canvas{
        id:lightOn
        anchors.fill: parent
        contextType: "2d";
        onPaint: {
            context.lineWidth = 1;
            context.strokeStyle = color;
            context.fillStyle = color;
            context.arc(x+r/2, y+r/2, 0.2*r, 0, Math.PI*2);
            context.fill();  //填充
            context.stroke();
        }
    }
    Canvas{
        id:lightOff
        anchors.fill: parent
        contextType: "2d";
        visible: !lightOn.visible
        onPaint: {
            context.lineWidth = 1;
            context.strokeStyle = "gray";
            context.fillStyle = "gray";
            context.arc(x+r/2, y+r/2, 0.2*r, 0, Math.PI*2);
            context.fill();  //填充
            context.stroke();
        }
    }
    Timer{
        id:flash
        interval: 1000
        running: true
        repeat: true
        property bool isBright: true
        onTriggered: {
            if(isBright)
                root.color = "gray"
            else
                root.color = "#56FF00"
            isBright = !isBright
            //bg.visible = isBright
            lightOn.visible = isBright

        }

    }
}
