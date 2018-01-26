import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../qml/Inc.js" as Com

Item {
    id:root
    visible: true
    width: 200
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
    //»¬¿éµÄ¶ÔÓ¦Öµ
    property var exScopeViewEle:undefined
    property real handle1Value:fftData.peakPoint0.x
    property real handle2Value:fftData.peakPoint1.x
    property real handle3Value:fftData.peakPoint2.x



    property real horizonStepValue :0.02
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


        Keys.enabled: true
        Keys.forwardTo: [handle3]
        Keys.onPressed:{

            //globalConsoleInfo("#####handle3 收到按键消息#####"+event.key);
            switch(event.key)
            {
            case Qt.Key_Left:
                if(handle3Value<=0)
                {
                    handle3Value=0;
                    break;
                }
                handle3Value-=horizonStepValue;
                setX(2,handle3Value);
                root.percent3 = (handle3.x+handle3.width/2)/root.width;
                event.accepted=true;
                break;
            case Qt.Key_PageUp:
                if(handle3Value<=0)
                {
                    handle3Value=0;
                    break;
                }
                handle3Value-=horizonStepValue;
                setX(2,handle3Value);
                root.percent3 = (handle3.x+handle3.width/2)/root.width;
                event.accepted=true;
                break;
            case Qt.Key_Right:
                //console.info("handle3查看步进horizonStepValue===="+horizonStepValue);
                handle3Value+=horizonStepValue;
                if(handle3Value>1)
                {
                    handle3Value=1;
                }
                setX(2,handle3Value);
                root.percent3 = (handle3.x+handle3.width/2)/root.width;
                event.accepted=true;
                break;
            case Qt.Key_PageDown://Ë³Ê±Õë
                handle3Value+=horizonStepValue;
                if(handle3Value>1)
                {
                    handle3Value=1;
                }
                setX(2,handle3Value);
                root.percent3 = (handle3.x+handle3.width/2)/root.width;
                event.accepted=true;
                break;
            case Qt.Key_Escape:
                if(exScopeViewEle)
                {
                    exScopeViewEle.focus=true;//½¹µã»¹¸øScopeView
                }
                event.accepted=true;
                break;
            case Qt.Key_Exclam://功能键1

            case Qt.Key_At://功能键2

            case Qt.Key_NumberSign://功能键3

            case Qt.Key_Dollar://功能键4

            case Qt.Key_Percent://功能键5

            case Qt.Key_AsciiCircum://功能键6

            case Qt.Key_Space://功能键 return
                idScopeView.focusPageOfrightControl.focus=true;
                idScopeView.focusPageOfrightControl.state="SHOW";
                console.info("※※※※※handle3  功能键呼出菜单※※※※※");
                event.accepted=true;
                break;
            default:
                break;
            }

            
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

        Keys.enabled: true
        Keys.forwardTo: [handle2]
        Keys.onPressed:{

            //globalConsoleInfo("#####handle2 收到按键消息#####"+event.key);
            switch(event.key)
            {
            case Qt.Key_Left:
                if(handle2Value<=0)
                {
                    handle2Value=0;
                    break;
                }
                handle2Value-=horizonStepValue;
                setX(1,handle2Value);
                root.percent2 = (handle2.x+handle2.width/2)/root.width;
                event.accepted=true;
                break;
            case Qt.Key_PageUp://滚轮逆时针
                if(handle2Value<=0)
                {
                    handle2Value=0;
                    break;
                }
                handle2Value-=horizonStepValue;
                setX(1,handle2Value);
                root.percent2 = (handle2.x+handle2.width/2)/root.width;
                event.accepted=true;
                break;
            case Qt.Key_Right:
                //console.info("handle2查看步进horizonStepValue===="+horizonStepValue);
                handle2Value+=horizonStepValue;
                if(handle2Value>1)
                {
                    handle2Value=1;
                }
                setX(1,handle2Value);
                root.percent2 = (handle2.x+handle2.width/2)/root.width;
                event.accepted=true;
                break;
            case Qt.Key_PageDown://Ë³Ê±Õë
                handle2Value+=horizonStepValue;
                if(handle2Value>1)
                {
                    handle2Value=1;
                }
                setX(1,handle2Value);
                root.percent2 = (handle2.x+handle2.width/2)/root.width;
                event.accepted=true;
                break;
            case Qt.Key_Escape:
                if(exScopeViewEle)
                {
                    exScopeViewEle.focus=true;//½¹µã»¹¸øScopeView
                }
                event.accepted=true;
                break;
            case Qt.Key_Exclam://功能键1

            case Qt.Key_At://功能键2

            case Qt.Key_NumberSign://功能键3

            case Qt.Key_Dollar://功能键4

            case Qt.Key_Percent://功能键5

            case Qt.Key_AsciiCircum://功能键6

            case Qt.Key_Space://功能键 return
                idScopeView.focusPageOfrightControl.focus=true;
                idScopeView.focusPageOfrightControl.state="SHOW";
                console.info("※※※※※handle2  功能键呼出菜单※※※※※");
                event.accepted=true;
                break;
            default:
                break;
            }


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
                console.info("UiSlider.qml 查看percent1=="+percent1);
            }
        }

        Keys.enabled: true
        Keys.forwardTo: [handle1]
        Keys.onPressed:{

            //globalConsoleInfo("#####handle1 收到按键消息#####"+event.key);
            switch(event.key)
            {
            case Qt.Key_Left:
                if(handle1Value<=0)
                {
                    handle1Value=0;
                    break;
                }
                handle1Value-=horizonStepValue;
                //console.info("handle1查看handle1Value===="+handle1Value);
                setX(0,handle1Value);
                root.percent1 = (handle1.x+handle1.width/2)/root.width;
                event.accepted=true;
                break;
            case Qt.Key_PageUp://ÄæÊ±Õë
                if(handle1Value<=0)
                {
                    handle1Value=0;
                    break;
                }
                handle1Value-=horizonStepValue;
                setX(0,handle1Value);
                root.percent1 = (handle1.x+handle1.width/2)/root.width;
                event.accepted=true;
                break;
            case Qt.Key_Right:
                //console.info("handle1查看步进horizonStepValue===="+horizonStepValue);
                handle1Value+=horizonStepValue;
                if(handle1Value>1)
                {
                    handle1Value=1;
                }
                setX(0,handle1Value);
                root.percent1 = (handle1.x+handle1.width/2)/root.width;
                event.accepted=true;
                break;
            case Qt.Key_PageDown://Ë³Ê±Õë
                handle1Value+=horizonStepValue;
                if(handle1Value>1)
                {
                    handle1Value=1;
                }
                setX(0,handle1Value);
                root.percent1 = (handle1.x+handle1.width/2)/root.width;
                event.accepted=true;
                break;
            case Qt.Key_Escape:
                if(exScopeViewEle)
                {
                    exScopeViewEle.focus=true;//½¹µã»¹¸øScopeView
                }
                event.accepted=true;
                break;
            case Qt.Key_Exclam://功能键1

            case Qt.Key_At://功能键2

            case Qt.Key_NumberSign://功能键3

            case Qt.Key_Dollar://功能键4

            case Qt.Key_Percent://功能键5

            case Qt.Key_AsciiCircum://功能键6

            case Qt.Key_Space://功能键 return
                idScopeView.focusPageOfrightControl.focus=true;
                idScopeView.focusPageOfrightControl.state="SHOW";
                console.info("※※※※※handle1  功能键呼出菜单※※※※※");
                event.accepted=true;
                break;

            default:
                break;
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
            break;
        case 1:
            handle2.x  = root.width * percent - handle2.width/2;
            if(handle2.x<0)
            {
                handle2.x=0;
            }
            break;
        case 2:
            handle3.x  = root.width * percent - handle3.width/2;
            if(handle3.x<0)
            {
                handle3.x=0;
            }
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
