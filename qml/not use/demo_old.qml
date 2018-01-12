import QtQuick 2.4
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2

Rectangle{
    visible: true;
    width: 800;
    height: 600;

    BusyIndicator{
        id: busy;
        running: false;
        anchors.centerIn: parent;
        z: 2;
    }
    Text{
        id: stateLabel;
        visible: false;
        anchors.centerIn: parent;
        z: 3;
    }

    Image{
        id: imageViewer;
        asynchronous: true;
        cache: false;
        //anchors.fill: parent;
  //      width: parent.width - 130;
//      height: parent.height - 50;
//        anchors.left: parent.left;
 //       anchors.leftMargin: 2;
        anchors.top: parent.top;
        anchors.right: rightPannel.left;
        anchors.bottom: bottomPannel.top;
        anchors.bottomMargin: 5;
        //fillMode: Image.PreserveAspectFit;
        source: "data2.bmp";
        onStatusChanged: {
            if(imageViewer.status == Image.Loading)
            {
                busy.running = true;
                stateLabel.visible = false;
            }
            else if(imageViewer.status == Image.Ready){
                busy.running = false;
            }
            else if(imageViewer.status == Image.Error){
                busy.running = false;
                stateLabel.visible = true;
                stateLabel.text = "ERROR";
            }
        }
    }
    Rectangle{
        id: rightPannel;
        visible: true
        border.color: "#808080";
        border.width: 2;
        anchors.top: imageViewer.top;
 //       anchors.left: imageViewer.right;
 //       anchors.leftMargin: 10;
        anchors.right: parent.right;
        anchors.rightMargin: 5;
        anchors.bottom: bottomPannel.top;
        anchors.bottomMargin: 5;
        width: 110;
        height: parent.height - 50;
        //

        Text{
            id: rightPannelText;
            font.pixelSize: 20;
            font.bold: true;
            text: "功能按钮区";
            //width: parent.width;
            anchors.top: parent.top;
            anchors.topMargin: 10;
            anchors.horizontalCenter: parent.horizontalCenter;
        }

        Column{
            anchors.top: rightPannelText.bottom;
            anchors.topMargin: 30;
            spacing: 30;
            anchors.horizontalCenter: parent.horizontalCenter;
            Button{                
                text: "采集参数显示";
                style: ButtonStyle{
                    background: Rectangle{
                        implicitWidth:  90;
                        implicitHeight: 25;
                        color: control.hovered ? "#d0d0d0" : "#c0c0c0";
                        border.width: control.pressed ? 2 : 1;
                        border.color: (control.hovered || control.pressed)
                            ? "green" : "#888888";
                        radius: 5;
                    }
                }
            }
            Button{   
                text: "频谱分析设置";
                style: ButtonStyle{
                    background: Rectangle{
                        implicitWidth:  90;
                        implicitHeight: 25;
                        color: control.hovered ? "#d0d0d0" : "#c0c0c0";
                        border.width: control.pressed ? 2 : 1;
                        border.color: (control.hovered || control.pressed)
                            ? "green" : "#888888";
                        radius: 5;
                    }
                }
            }
            Button{               
                text: "存储设置";
                style: ButtonStyle{
                    background: Rectangle{
                        implicitWidth:  90;
                        implicitHeight: 25;
                        color: control.hovered ? "#d0d0d0" : "#c0c0c0";
                        border.width: control.pressed ? 2 : 1;
                        border.color: (control.hovered || control.pressed)
                            ? "green" : "#888888";
                        radius: 5;
                    }
                }
            }
        }
    }


    Rectangle{
        id: bottomPannel;
        border.color: "#808080";
        border.width: 2;
        width: parent.width;
        height: 40;
        anchors.left: parent.left;
        anchors.leftMargin: 4;
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 4;
        anchors.right: parent.right;
        anchors.rightMargin: 5;


        Row{
            anchors.left: parent.left;
            anchors.leftMargin: 10;
            spacing: 30;
            anchors.verticalCenter: parent.verticalCenter;

            Button{
                text: "采集参数显示";
                style: ButtonStyle{
                    background: Rectangle{
                        implicitWidth:  90;
                        implicitHeight: 25;
                        color: control.hovered ? "#d0d0d0" : "#c0c0c0";
                        border.width: control.pressed ? 2 : 1;
                        border.color: (control.hovered || control.pressed)
                            ? "green" : "#888888";
                        radius: 5;
                    }
                }
            }
            Button{
                text: "频谱分析参数显示";
                style: ButtonStyle{
                    background: Rectangle{
                        implicitWidth:  90;
                        implicitHeight: 25;
                        color: control.hovered ? "#d0d0d0" : "#c0c0c0";
                        border.width: control.pressed ? 2 : 1;
                        border.color: (control.hovered || control.pressed)
                            ? "green" : "#888888";
                        radius: 5;
                    }
                }
            }
            Button{
                text: "操作参数显示";
                style: ButtonStyle{
                    background: Rectangle{
                        implicitWidth:  90;
                        implicitHeight: 25;
                        color: control.hovered ? "#d0d0d0" : "#c0c0c0";
                        border.width: control.pressed ? 2 : 1;
                        border.color: (control.hovered || control.pressed)
                            ? "green" : "#888888";
                        radius: 5;
                    }
                }
            }
        }
    }




}
