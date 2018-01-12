import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../qml/Inc.js" as Com

Rectangle{
    id:root

    property color textColor: "#404044"
    property real  itemHeight: height*0.096

    property int   max: 50

    Column {
        anchors.fill: parent
        spacing: 0
        Item {
            width: parent.width
            height: itemHeight
            Text {anchors.fill: parent; color: textColor; text: "0"; horizontalAlignment: Text.AlignRight}
        }
        Item {
            width: parent.width
            height: itemHeight
            Text {anchors.fill: parent; color: textColor; text: fixLable(max*0.1); horizontalAlignment: Text.AlignRight}
        }
        Item {
            width: parent.width
            height: itemHeight
            Text {anchors.fill: parent; color: textColor; text: fixLable(max*0.2); horizontalAlignment: Text.AlignRight}
        }
        Item {
            width: parent.width
            height: itemHeight
            Text {anchors.fill: parent; color: textColor; text: fixLable(max*0.3); horizontalAlignment: Text.AlignRight}
        }
        Item {
            width: parent.width
            height: itemHeight
            Text {anchors.fill: parent; color: textColor; text: fixLable(max*0.4); horizontalAlignment: Text.AlignRight}
        }
        Item {
            width: parent.width
            height: itemHeight
            Text {anchors.fill: parent; color: textColor; text: fixLable(max*0.5); horizontalAlignment: Text.AlignRight}
        }
        Item {
            width: parent.width
            height: itemHeight
            Text {anchors.fill: parent; color: textColor; text: fixLable(max*0.6); horizontalAlignment: Text.AlignRight}
        }
        Item {
            width: parent.width
            height: itemHeight
            Text {anchors.fill: parent; color: textColor; text: fixLable(max*0.7); horizontalAlignment: Text.AlignRight}
        }
        Item {
            width: parent.width
            height: itemHeight
            Text {anchors.fill: parent; color: textColor; text: fixLable(max*0.8); horizontalAlignment: Text.AlignRight}
        }
        Item {
            width: parent.width
            height: itemHeight
            Text {anchors.fill: parent; color: textColor; text: fixLable(max*0.9); horizontalAlignment: Text.AlignRight}
        }
        Item {
            width: parent.width
            height: itemHeight
            Text {anchors.fill: parent; color: textColor; text: max; horizontalAlignment: Text.AlignRight}
        }

    }
    function fixLable(val)
    {
        if(max<11)
            return ""
        return val.toFixed(0)
    }


}
