import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../qml/Inc.js" as Com

Rectangle{
    id: root
    width: 190
    height: 20
    color: "#00FFFFFF"
    visible: false
    property alias xstring: peakTextX.text
    property alias ystring: peakTextY.text
    property color textColor: Com.series_color1
    border.color: "#67696B"
    radius: 4
    Item{
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.right: parent.right
        anchors.rightMargin: 5
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        Text {
           id: peakTitle
           anchors.left: parent.left
           width: parent.width*0.2
           height: parent.height
           verticalAlignment: Text.AlignVCenter
           horizontalAlignment: Text.AlignLeft
           text: "Mark:"
           color: textColor
           font.family: "Calibri"
           font.pixelSize: 12
           font.bold: true
        }
        Rectangle{
            id:xRect
            anchors.top: parent.top
            anchors.left: peakTitle.right
            width: parent.width*0.42
            height: parent.height
            color: "#00FFFFFF"
            Text {
               id: peakTextX
               anchors.fill: parent
               verticalAlignment: Text.AlignVCenter
               horizontalAlignment: Text.AlignLeft
               text: "000"
               color: textColor
               font.family: "Calibri"
               font.pixelSize: 12
               font.bold: true
            }
            Text {
               id: peakTextUnit
               anchors.fill: parent
               verticalAlignment: Text.AlignVCenter
               horizontalAlignment: Text.AlignRight
               text: "MHz  "
               color: textColor
               font.family: "Calibri"
               font.pixelSize: 12
               font.bold: true
            }
        }

        Rectangle{
            id:yRect
            anchors.top: parent.top
            anchors.left: xRect.right
            width: parent.width*0.38
            height: parent.height
            color: "#00FFFFFF"
            Text {
               id: peakTextY
               anchors.fill: parent
               verticalAlignment: Text.AlignVCenter
               horizontalAlignment: Text.AlignLeft
               text: "000"
               color: textColor
               font.family: "Calibri"
               font.pixelSize: 12
               font.bold: true
            }
            Text {
               id: peakUnit2
               anchors.fill: parent
               verticalAlignment: Text.AlignVCenter
               horizontalAlignment: Text.AlignRight
               text: "dBm"
               color: textColor
               font.family: "Calibri"
               font.pixelSize: 12
               font.bold: true
            }
        }
    }
}
