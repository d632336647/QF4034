import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../qml/Inc.js" as Com

Item {
    id:root
    visible: true
    width: Com.RightMenuWidth
    height: 20
    property real min: 0
    property real max: 100
    property real range: max - min
    property real percent1: 0.5
    property real percent2: 0.5
    property real percent3: 0.5
    property alias visible1: handle1.visible
    property alias visible2: handle2.visible
    property alias visible3: handle3.visible
    Rectangle {
        anchors.fill: parent
        color: "#00FFFFFF"
    }

    Rectangle {
        id:bgline
        anchors.centerIn: parent
        height: 1
        width: parent.width
        color: "gray"
    }

    Rectangle {
        id:handle3
        width: 12;
        objectName: "triangleEle"
        x: 0
        y: 0
        height: parent.height
        color: "#00000000"
        Drag.active: dragArea3.drag.active
        Drag.hotSpot.x: 10
        Drag.hotSpot.y: 10
        Canvas{
            anchors.fill: parent
            contextType: "2d";
            onPaint: {
                context.lineWidth = 1;
                context.strokeStyle = Com.series_color3;
                context.fillStyle = Com.series_color3;
                context.beginPath();
                context.moveTo(width/2 , 0);
                context.lineTo(width , height);
                context.lineTo(0 , height);
                context.closePath();
                context.fill();
                context.stroke();
            }
        }
        MouseArea {
            id: dragArea3
            anchors.fill: parent
            drag.target: parent
            drag.minimumX: -parent.width/2
            drag.maximumX: root.width - parent.width/2
            drag.minimumY: 0
            drag.maximumY: root.height - parent.height
            onPressed:{
                bgline.color = Com.series_color3
            }
            onReleased:{
                bgline.color = "gray"
            }
        }
        onXChanged:
        {
            if(dragArea3.pressed)
                root.percent3 = (x+width/2)/root.width;
        }

    }

    Rectangle {
        id:handle2
        width: 12;
        objectName: "triangleEle"
        x: 0
        y: 0
        height: parent.height
        color: "#00000000"
        Drag.active: dragArea2.drag.active
        Drag.hotSpot.x: 10
        Drag.hotSpot.y: 10
        Canvas{
            anchors.fill: parent
            contextType: "2d";
            onPaint: {
                context.lineWidth = 1;
                context.strokeStyle = Com.series_color2;
                context.fillStyle = Com.series_color2;
                context.beginPath();
                context.moveTo(width/2 , 0);
                context.lineTo(width , height);
                context.lineTo(0 , height);
                context.closePath();
                context.fill();
                context.stroke();
            }
        }
        MouseArea {
            id: dragArea2
            anchors.fill: parent
            drag.target: parent
            drag.minimumX: -parent.width/2
            drag.maximumX: root.width - parent.width/2
            drag.minimumY: 0
            drag.maximumY: root.height - parent.height
            onPressed:{
                bgline.color = Com.series_color2
            }
            onReleased:{
                bgline.color = "gray"
            }
        }
        onXChanged:
        {
            if(dragArea2.pressed)
                root.percent2 = (x+width/2)/root.width;
        }
    }

    Rectangle {
        id:handle1
        width: 12;
        objectName: "triangleEle"
        x: 0
        y: 0
        height: parent.height
        color: "#00000000"
        Drag.active: dragArea1.drag.active
        Drag.hotSpot.x: 10
        Drag.hotSpot.y: 10
        Canvas{
            anchors.fill: parent
            contextType: "2d";
            onPaint: {
                context.lineWidth = 1;
                context.strokeStyle = Com.series_color1;
                context.fillStyle = Com.series_color1;
                context.beginPath();
                context.moveTo(width/2 , 0);
                context.lineTo(width , height);
                context.lineTo(0 , height);
                context.closePath();
                context.fill();
                context.stroke();
            }
        }
        MouseArea {
            id: dragArea1
            anchors.fill: parent
            drag.target: parent
            drag.minimumX: -parent.width/2
            drag.maximumX: root.width - parent.width/2
            drag.minimumY: 0
            drag.maximumY: root.height - parent.height
            onPressed:{
                bgline.color = Com.series_color1
            }
            onReleased:{
                bgline.color = "gray"
            }
        }
        onXChanged:
        {
            if(dragArea1.pressed)
            {
                root.percent1 = (x+width/2)/root.width;
            }
        }

    }
    Text {
        id: name
        color: "white"
        text: root.percent1
        visible: false
    }
    onRangeChanged:
    {

    }
    function moveTop(idx)
    {
        //slider.z
        switch(idx)
        {
        case 0:
            break;
        case 1:
            break;
        case 2:
            break;
        default:
            break;
        }
    }

    function setX(idx, percent)
    {
        switch(idx)
        {
        case 0:
            handle1.x  = root.width * percent - handle1.width/2;
            if(handle1.x<0)
            {
                handle1.x=0;
            }
            percent1 = percent
            break;
        case 1:
            handle2.x  = root.width * percent - handle2.width/2;
            if(handle2.x<0)
            {
                handle2.x=0;
            }
            percent2 = percent
            break;
        case 2:
            handle3.x  = root.width * percent - handle3.width/2;
            if(handle3.x<0)
            {
                handle3.x=0;
            }
            percent3 = percent
            break;
        default:
            break;
        }
    }
    function setVisible(idx, visible)
    {
        switch(idx)
        {
        case 0:
            visible1 = visible
            break;
        case 1:
            visible2 = visible
            break;
        case 2:
            visible3 = visible
            break;
        default:
            break;
        }
    }
}
