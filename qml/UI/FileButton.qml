import QtQuick 2.0
import QtQuick.Dialogs 1.2
import "../Inc.js" as Com

Rectangle{
    id:fileBtn
    width: 192;
    height: 91;
    radius: 4;
    color: "#121212";
    border.color: "#67696B"
    border.width: 1
    property string textLabel: "Label";
    property string textData: "";
    property bool bHovered: false;
    property alias icon: iconFont.text
    property int selectBorderSize: 2
    property bool readOnly: false;
    property string fullPath: "";
    property string fileName: "";
    signal click();


    Text{
        id: btnLabel;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.top: parent.top;
        anchors.topMargin: btnData.text.length ? 20 : 30;
        font.family: Com.fontFamily
        font.pixelSize: 18;
        text: textLabel;
        color: fileBtn.readOnly ? "#646464" : "white";
        horizontalAlignment: Text.AlignHCenter;
        verticalAlignment: Text.AlignVCenter;
        font.bold: true;
    }
    Text{
        id: btnData;
        anchors.horizontalCenter: parent.horizontalCenter;
        anchors.top: btnLabel.bottom;
        anchors.topMargin: 10;
        font.pixelSize: 15;
        text: textData;
        color: "#D29928";
        horizontalAlignment: Text.AlignHCenter;
        verticalAlignment: Text.AlignVCenter;
        font.bold: true;
        visible: btnData.text.length ? true : false;
    }
    Text{
        id:iconFont
        anchors{top:parent.top; bottom: parent.bottom;left:parent.left}
        anchors.leftMargin: 8
        anchors.bottomMargin: 12
        font.family: "FontAwesome"
        color:btnLabel.color
        font.pixelSize: 20
        text: ""
        verticalAlignment: Text.AlignVCenter
    }

    FileDialog{
        id: fileDialog
        title: "请选择存储文件夹"
        //nameFilters: ["Data Files (*.dat)", "All files (*.*)"]
        folder: "file:///"+Settings.filePath()//shortcuts.home
        selectFolder : true
        selectMultiple: false
        onAccepted: {
            fullPath = fileDialog.fileUrl.toString().slice(8)
            var s = fullPath.split('/')
            fileName = s[s.length - 1]
            //console.log(fullPath);
            fileBtn.click();
            Settings.filePath(Com.OpSet, fullPath)
        }
        onRejected: {
            fullPath = ""
            fileName = ""
        }
    }
    MouseArea{
        id: btnMouseArea;
        anchors.fill: parent;
        hoverEnabled: true;
        onClicked: {
            if(!readOnly)
            {
                fileDialog.open()
            }
        }
        onEntered:
        {
            bHovered = true
            pressedAnim.start()
            releasedAnim.stop()
        }
        onExited:
        {
            releasedAnim.start()
            pressedAnim.stop()
            bHovered = false
        }
        PropertyAnimation {
            id: pressedAnim;
            target: fileBtn;
            property: "color";
            to: "#1F1F1F";
            duration: Com.animationSpeed
        }
        PropertyAnimation {
            id: releasedAnim;
            target: fileBtn;
            property: "color";
            to: "#121212"
            duration: Com.animationSpeed
        }
    }
}
