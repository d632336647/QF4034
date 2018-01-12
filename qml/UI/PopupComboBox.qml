import QtQuick 2.2
import QtQuick.Controls 1.4
import "../Inc.js" as Com

Rectangle{
    implicitWidth: 180;
    implicitHeight: 30;
    radius: 5;

    property alias currentIndex: commbox.currentIndex
    property alias currentText: commbox.currentText
    property string type: Com.ElementType_ComboBox

    signal selected;

    property var dataModel: [];
    ComboBox{
        id: commbox;
        anchors.fill: parent;
        model: dataModel;
        onCurrentIndexChanged: {
            selected();
        }
    }
}
