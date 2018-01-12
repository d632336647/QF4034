import QtQuick 2.0
import QtQuick.Layouts 1.3

Item {
    implicitWidth: 100
    implicitHeight: 35
    //color: "#888888"

    property bool labelShow: true
    property string label: ""

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 18
        color: "#333"
        text: label.length ? label + "： " : ""
        visible: labelShow
    }
}
