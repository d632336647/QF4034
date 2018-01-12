import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Item {
    property color signalColor: "red"
    property alias checked: checkBox.checked
    signal signalCheck

    implicitWidth: 15
    implicitHeight: 15

    visible: false
    Row{
        anchors.fill: parent
        spacing: 2
        Rectangle{
            width: 10
            height: 10
            anchors.top: parent.top
            anchors.topMargin: 2
            color: signalColor
            Text {
                id: checktext
                anchors.fill: parent
                color: "#FFFFFF"
                text: qsTr("text")
            }
        }
        CheckBox {
            id: checkBox
            checked: true
            onClicked: {
                signalCheck()
            }
        }
    }
}
