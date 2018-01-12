import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Item {
    property color backgroundColor: "red"
    property color textColor: "white"
    property alias text: checktext.text
    property alias checked: checkBox.checked
    signal boxChecked
    visible: true

    Rectangle{
        width: 10
        height: 10
        anchors.top: parent.top
        anchors.topMargin: 2
        color: backgroundColor
        Text {
            id: checktext
            anchors.fill: parent
            color: textColor
            text: qsTr("text")
        }
    }
    CheckBox {
        id: checkBox
        checked: true
        onClicked: {
            boxChecked()
        }
    }

}
