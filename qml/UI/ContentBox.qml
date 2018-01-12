import QtQuick 2.0
import "../Inc.js" as Com

import Qt.labs.folderlistmodel 2.0

//
Item {
    id: root
    width: 600
    height: 260

    property bool  isShowMaximized: false
    property string titleText:"UI"

    property color titleColor:"#ffffff"
    property int   borderWidth:2
    property color borderColor:  "#255363"
    property color titleMidColor:"#102833"
    property color bgColor:"#161616"

    //标题栏
    Item{
        id:title
        width: parent.width
        height: 20
        anchors{top: root.top; left: root.left;}
        clip:true
        Canvas{
            id:titleMid
            width: parent.width*0.7
            height: parent.height*0.7
            anchors{bottom: titleLeft.bottom; left: parent.left; }
            contextType: "2d";
            onPaint: {
                context.lineWidth = 1;
                context.strokeStyle = root.titleMidColor;
                context.fillStyle = root.titleMidColor;
                context.beginPath();
                context.moveTo(0 ,0);
                context.lineTo(width-height , 0);
                context.lineTo(width , height);
                context.lineTo(0 , height);
                context.lineTo(0 , 0);
                context.closePath();
                context.fill();
                context.stroke();
            }
        }
        Canvas{
            id:titleLeft
            width: parent.width*0.4
            height: parent.height
            anchors{top: parent.top; left: parent.left; }
            contextType: "2d";
            onPaint: {
                context.lineWidth = 1;
                context.strokeStyle = root.borderColor
                context.fillStyle = root.borderColor
                context.beginPath();
                context.moveTo(0 ,0);
                context.lineTo(width-height , 0);
                context.lineTo(width , height);
                context.lineTo(0 , height);
                context.lineTo(0 , 0);
                context.closePath();
                context.fill();
                context.stroke();
            }
            Text {
                id: idText
                text:titleText
                anchors.left: parent.left
                anchors.leftMargin: 4
                anchors.verticalCenter: parent.verticalCenter
                color:titleColor
                font.family: Com.fontFamily
                font.pixelSize: parent.height-4
            }
        }
    }//!--标题栏 End


    //上部横折线
    Item{
        id:midContent
        width: parent.width
        height: 20
        anchors.top: title.bottom
        Rectangle{
            id:midContentLine
            width: parent.width - parent.height*1.4
            anchors.left: parent.left
            anchors.top: parent.top
            height: root.borderWidth
            color: root.borderColor
        }
        Rectangle{
            id:midContentBg
            width: parent.width - parent.height*1.4
            anchors.top: midContentLine.bottom
            anchors.bottom: parent.bottom
            color: root.bgColor
        }
        Rectangle{
            id:midContentLeftLine
            width: root.borderWidth
            anchors.left: parent.left
            anchors.top: parent.top
            height: parent.height
            color: root.borderColor
        }
        Rectangle{
            id:midContentCorner
            width: parent.height*1.4
            height:width
            anchors{top: midContent.top; right: midContent.right; }
            anchors.topMargin: height-midContent.height-2
            anchors.rightMargin: width/2
            color: root.bgColor
            rotation: 45
            Rectangle{
                width: parent.width
                height: root.borderWidth
                color: root.borderColor
            }
        }
    }//!--上部横折线 End



    //主显示区域
    Rectangle{
        id:mainContent
        width: parent.width - 9
        anchors.top: midContent.bottom
        anchors.bottom: parent.bottom
        color: root.bgColor
        Rectangle{
            id:mainContentRight
            width: root.borderWidth
            height: parent.height
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            color: root.borderColor
        }
        Rectangle{
            id:mainContentLeft
            width: root.borderWidth
            height: parent.height
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            color: root.borderColor
        }
    }//!--主显示区域 End




    //下部横折线
    Item{
        id:bottomContent
        width: parent.width-1
        height: 20
        anchors.bottom: root.bottom
        anchors.bottomMargin: -20
        anchors.left: root.left
        anchors.leftMargin: -8
        rotation: 180
        opacity: root.opacity
        Rectangle{
            id:bottomContentLine
            width: parent.width - parent.height*1.4
            anchors.left: parent.left
            anchors.top: parent.top
            height: root.borderWidth
            color: root.borderColor
        }
        Rectangle{
            id:bottomContentBg
            width: parent.width - parent.height*1.4
            anchors.top: bottomContentLine.bottom
            anchors.bottom: parent.bottom
            color: root.bgColor
        }
        Rectangle{
            id:bottomContentLeftLine
            width: root.borderWidth
            anchors.left: parent.left
            anchors.top: parent.top
            height: parent.height
            color: root.borderColor
        }
        Rectangle{
            id:bottomContentCorner
            width: parent.height*1.4
            height:width
            anchors{top: bottomContent.top; right: bottomContent.right; }
            anchors.topMargin: height-bottomContent.height-2
            anchors.rightMargin: width/2
            color: root.bgColor
            rotation: 45
            Rectangle{
                width: parent.width
                height: root.borderWidth
                color: root.borderColor
            }
        }
    }//!--下部横折线 End


}
