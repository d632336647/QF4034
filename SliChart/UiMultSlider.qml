import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../qml/Inc.js" as Com

Item {
    id:root
    visible: true
    width: 200
    height: 10
    property real  min: 0
    property real  max: 100
    property alias value: slider.value
    property real  range: max - min
    property color handleColor:   Com.series_color1
    property real  sliderOpacity: 0.5
    signal handleReleased
    Slider{
        id:slider
        anchors.fill: parent
        //stepSize: 0.001
        value: 0
        style: SliderStyle {
                  groove: Rectangle {
                      implicitHeight: 2
                      width: slider.width
                      color: handleColor
                      opacity: sliderOpacity
                      //border.color: handleColor
                      //radius: 4
                  }
                  handle: Item {
                      //anchors.centerIn: parent
                      //color: control.pressed ? "white" : "lightgray"
                      implicitWidth: 40
                      implicitHeight: 10
                      Rectangle {
                        id:handler
                        anchors.fill: parent
                        color: handleColor
                        //opacity: sliderOpacity
                        border.color: control.pressed ? "white" : handleColor
                        radius: 4
                      }
                  }
              }
        onValueChanged:{
            //console.log(root.max, root.min)
        }
        onHoveredChanged: {
            //console.log(hovered)

            if(hovered)
            {
                pressedAnim.start()
            }
            else
                releasedAnim.start()
        }
        onPressedChanged: {
            if(!pressed)
            {
                root.handleReleased()
            }
        }
    }
    Text {
        id: name
        color: "white"
        text: root.value
        visible: false
    }
    PropertyAnimation {
        id: pressedAnim;
        target: root;
        property: "sliderOpacity";
        to: 1;
        duration: 300
    }
    PropertyAnimation {
        id: releasedAnim;
        target: root;
        property: "sliderOpacity";
        to: 0.5
        duration: 300
    }
}
