import QtQuick 2.0
import "../Inc.js" as Com

import Qt.labs.folderlistmodel 2.0

//
Item {
    id: root
    width: 200
    height: 100
    visible: false
    property string title:"消息框"
    property string note: ""
    property bool   isWarning: true
    property var    parentObject: undefined
    ContentBox{
        id:contentBox
        anchors.fill: parent
        titleText: title
        borderColor:  isWarning ? "#E14646" : "#255363"
        titleMidColor:isWarning ? "#A97070" : "#102833"
    }
    Text{
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height * 0.5
        text:note
        color:"white"
        font.family: Com.fontFamily
        font.pixelSize: 24
        horizontalAlignment: Text.AlignHCenter;
        verticalAlignment: Text.AlignVCenter;
    }

    PropertyAnimation {
        id: fadeOut;
        target: root;
        property: "opacity";
        to: 0;
        easing.type: Easing.InQuint;
        duration: 2000
    }
    onOpacityChanged: {
        if(opacity === 0)
        {
            opacity = 1
            visible = false
            parentObject.visible = false
        }
    }
    onVisibleChanged:
    {
        if(visible)
            fadeOut.start()
    }
}
