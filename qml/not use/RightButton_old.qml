import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0

Button{
    id: rightButton;
    style: ButtonStyle{
        background: Rectangle{
            implicitWidth: 180;
            implicitHeight: 60;
            color: control.hovered ? "#6A5ACD" : "#9370DB";
            border.width: control.pressed ? 3 : 2;
            border.color: (control.hovered || control.pressed) ? "#3d9291" : "#ACCDD2";
            radius: 5;
            gradient: Gradient{
                GradientStop{ position: 0.0; color: control.hovered ? "#a0c3be" : "#777b96"}
                GradientStop{ position: 0.7; color: control.hovered ? "#095247" : "#001e42"}
                GradientStop{ position: 1.0; color: control.hovered ? "#024b42" : "#040436"}
            }
        }
        label: Item{
            Text {
                id: rightBtnText;
                anchors.fill: parent;
                font.pixelSize: 18;
                text: rightButton.text;
                color: "white";
                //color: control.hovered ? "white": "dark";
                horizontalAlignment: Text.AlignHCenter;
                verticalAlignment: Text.AlignVCenter;
                font.bold: true;
            }
        }
    }
}
