import QtQuick 2.0
import "../Inc.js" as Com

//自定义标题栏
Rectangle {
    id: root                       //创建标题栏
    anchors.top: parent.top             //对标题栏定位
    anchors.left: parent.left
    anchors.right: parent.right
    height: 32                          //设置标题栏高度
    color: "#1F1F1F"                    //设置标题栏背景颜色
    property bool isShowMaximized: false
    property alias source:titleIcon.source
    property alias text:titleText.text
    MouseArea {
        id: dragRegion
        anchors.fill: parent
        property point clickPos: "0,0"
        onPressed: {
            clickPos = Qt.point(mouse.x,mouse.y)
        }
        onPositionChanged: {
            //鼠标偏移量
            var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
            //如果mainwindow继承自QWidget,用setPos
            mainWindow.setX(mainWindow.x+delta.x) //mainWindow为 main.cpp导入的view对象
            mainWindow.setY(mainWindow.y+delta.y)
        }
    }
    Image{
        id:titleIcon
        height: parent.height * 0.7
        width: 36
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.15
        //source: "qrc:/rc/image/app.ico"
        fillMode: Image.PreserveAspectFit
    }
    Text{
        id:titleText
        color:"#d0d0d0"
        font.family: Com.fontFamily
        font.pixelSize: 18
        text: "窗口标题"
        height: parent.height * 0.7
        anchors.top: parent.top
        anchors.topMargin: parent.height * 0.2
        anchors.left: titleIcon.right
    }
    Rectangle{
        id:closeBtn
        height: parent.height
        width: 45
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        color:"#1F1F1F"
        Text{
            font.family: "FontAwesome"
            color:"#BEC0C2"
            font.pixelSize: 18
            text: "\uf00d"
            anchors.centerIn: parent
        }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onClicked:
            {
                Settings.save()
                captureThread.exit()
                //mainWindow.close()
                Qt.quit()
            }
            onEntered:
            {
                pressedAnim.start()
                releasedAnim.stop()
            }
            onExited:
            {
                releasedAnim.start()
                pressedAnim.stop()
            }
            PropertyAnimation {
                id: pressedAnim;
                target: closeBtn;
                property: "color";
                to: "#aaff0000";
                duration: 200
            }
            PropertyAnimation {
                id: releasedAnim;
                target: closeBtn;
                property: "color";
                to: "#1F1F1F"
                duration: 200
            }
        }
    }//!--closeBtn End


    Rectangle{
        id:maxBtn
        height: parent.height
        width: 45
        anchors.right: closeBtn.left
        anchors.rightMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        color:"#1F1F1F"
        Text{
            id:maxBtnIcon
            font.family: "FontAwesome"
            color:"#BEC0C2"
            //font.pixelSize: 18
            text: "\uf2d0"
            anchors.centerIn: parent
        }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onClicked:
            {
                //Qt.quit()无法关闭窗口
                if(root.isShowMaximized)
                {
                    mainWindow.showNormal()
                    root.isShowMaximized = false
                    maxBtnIcon.text =  "\uf2d0"
                }
                else
                {
                    mainWindow.showMaximized()
                    root.isShowMaximized = true
                    maxBtnIcon.text =  "\uf2d2"
                }
            }
            onEntered:
            {
                pressedMaxBtnAnim.start()
                releasedMaxBtnAnim.stop()
            }
            onExited:
            {
                releasedMaxBtnAnim.start()
                pressedMaxBtnAnim.stop()
            }
            PropertyAnimation {
                id: pressedMaxBtnAnim;
                target: maxBtn;
                property: "color";
                to: "#404244";
                duration: 200
            }
            PropertyAnimation {
                id: releasedMaxBtnAnim;
                target: maxBtn;
                property: "color";
                to: "#1F1F1F"
                duration: 200
            }
        }
    }//!--maxBtn End


    Rectangle{
        id:minBtn
        height: parent.height
        width: 45
        anchors.right: maxBtn.left
        anchors.rightMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        color:"#1F1F1F"
        Text{
            font.family: "FontAwesome"
            color:"#BEC0C2"
            //font.pixelSize: 18
            text: "\uf2d1"
            anchors.centerIn: parent
        }
        MouseArea{
            anchors.fill: parent
            hoverEnabled: true
            onClicked:
            {
                mainWindow.showMinimized();
            }
            onEntered:
            {
                pressedMinBtnAnim.start()
                releasedMinBtnAnim.stop()
            }
            onExited:
            {
                releasedMinBtnAnim.start()
                pressedMinBtnAnim.stop()
            }
            PropertyAnimation {
                id: pressedMinBtnAnim;
                target: minBtn;
                property: "color";
                to: "#404244";
                duration: 200
            }
            PropertyAnimation {
                id: releasedMinBtnAnim;
                target: minBtn;
                property: "color";
                to: "#1F1F1F"
                duration: 200
            }
        }
    }//!--minBtn end

}
