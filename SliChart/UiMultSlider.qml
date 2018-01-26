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
    property var exScopeViewEle:undefined
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
                globalConsoleInfo("uiMultSlider.qml²é¿´slider.value=="+slider.value);
                root.handleReleased();
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
    Keys.enabled: true
    Keys.forwardTo: [slider]
    Keys.onPressed:{
        switch(event.key)
        {

        case Qt.Key_Left:
            globalConsoleInfo("UiMultSlider.qmlÊÕµ½Qt.Key_LeftÏûÏ¢");
            if(slider.value<=0)
            {
                slider.value=0;
            }
            slider.value-=0.05;

            break;
        case Qt.Key_PageUp://ËõÐ¡
            globalConsoleInfo("UiMultSlider.qmlÊÕµ½¹öÂÖÄæÊ±ÕëÏûÏ¢");
            if(slider.value<=0)
            {
                slider.value=0;
            }
            slider.value-=0.05;

            break;
        case Qt.Key_Right:
            globalConsoleInfo("UiMultSlider.qmlÊÕµ½Qt.Key_RightÏûÏ¢");
            if(slider.value>=1)
            {
                slider.value=1;
            }
            slider.value+=0.05;

            break;
        case Qt.Key_PageDown://·Å´ó
            globalConsoleInfo("UiMultSlider.qmlÊÕµ½¹öÂÖË³Ê±ÕëÏûÏ¢");
            if(slider.value>=1)
            {
                slider.value=1;
            }
            slider.value+=0.05;

            break;
        case Qt.Key_Escape://½¹µãÇÐ»»µ½ scopeView¶ø²»ÊÇTiDomainWave
            globalConsoleInfo("#####²é¿´UiMultSlider.parent.parent===="+root.parent.parent);
            //            root.parent.parent.focus=true;
            if(exScopeViewEle)
            {
                exScopeViewEle.focus=true;
            }
            break;
        default:
            globalConsoleInfo("#####UiMultSlider.qmlÊÕµ½°´¼üÏûÏ¢#####"+event.key);
            break;
        }
        event.accepted=true;//×èÖ¹ÊÂ¼þ¼ÌÐø´«µÝ
    }
}
