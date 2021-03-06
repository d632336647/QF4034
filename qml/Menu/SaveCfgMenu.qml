import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../Inc.js" as Com
import "../Lib.js" as Lib
import "../UI"

Rectangle{
    id:root

    state: "HIDE"
    width: Com.RightMenuWidth
    anchors.topMargin: 4
    anchors.bottomMargin: 4

    //border.color: Com.bottomBorderColor
    //border.width: 1
    color: Com.bgColorMain

    ColumnLayout {
        id:content
        spacing: 4;
        anchors.top: parent.top;
        anchors.left: parent.left
        anchors.leftMargin: 4;
        property int itemWidth: root.width - 8
        RightButton {
            id: btn_menu;
            textLabel: "返回主菜单";
            icon:"\uf090"
            width: parent.itemWidth
            onClick: {
                turnToMainMenu()
            }
        }
        RightButton {
            id: btn_savemode;
            textLabel: "存储模式";
            width: parent.itemWidth
            onClick: {
                saveMode.loadParam()
                saveMode.state = "SHOW"
            }
        }
        RightButton {
            id: btn_namemode;
            textLabel: "命名模式";
            width: parent.itemWidth
            onClick: {
                nameMode.loadParam()
                nameMode.state = "SHOW"
            }
        }
        FileButton{
            id: btn_filepath;
            textLabel: "文件路径";
            //icon:"\uf115"
            width: parent.itemWidth
            onClick: {
                messageBox.title = "注意"
                messageBox.note  = "存储路径已更新!"
                messageBox.isWarning = false
                messageBox.visible = true
            }
        }
        RightButton {
            id: empty1;
            textLabel: "";
            //icon:"\uf07c"
            onClick: {
            }
        }
        RightButton {
            id: empty2;
            textLabel: "";
            //icon:"\uf07c"
            onClick: {
            }
        }
        RightButton {
            id: empty3;
            textLabel: "";
            //icon:"\uf07c"
            onClick: {
            }
        }
        RightButton {
            id: btn_return;
            textLabel: "返回上级";
            icon:"\uf112"
            width: parent.itemWidth
            onClick: {
                turnToParentMenu()
            }
        }


    }
    SaveMode{
        id:saveMode
        anchors.top: parent.top
        anchors.bottom: parent.bottom
    }
    NameMode {
        id:nameMode
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        objectName: "nameMode"
    }


    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{
        if(Lib.operateSpecView(event.key))
        {
            hideMenu()
            event.accepted = true;
            return
        }
        var key = [Qt.Key_F1, Qt.Key_F2, Qt.Key_F3, Qt.Key_F8]
        var fid = [btn_menu, btn_savemode, btn_namemode, btn_return]
        Lib.clickFunctionKey(event.key, key, fid);
        event.accepted = true;
    }
    //过渡动画
    states: [
        State {
            name: "SHOW"
            PropertyChanges { target: root; x: root.parent.width-Com.RightMenuWidth}
            onCompleted:{
                root.focus = true;
            }
        },
        State {
            name: "HIDE"
            PropertyChanges { target: root; x: root.parent.width}
            onCompleted: {
            }
        }
    ]
    transitions: [
         Transition {
             from: "SHOW"
             to: "HIDE"
             PropertyAnimation { properties: "x"; easing.type: Easing.OutCubic }
         },
         Transition {
             from: "HIDE"
             to: "SHOW"
             PropertyAnimation { properties: "x"; easing.type: Easing.OutCubic }
         }
    ]
    //！--过渡动画结束
    function hideMenu()
    {
        root.state = "HIDE"
    }
    function turnToMainMenu()
    {
        hideMenu()
        idRightPannel.state="SHOW";
        idRightPannel.focus = true;
    }
    function turnToParentMenu()
    {
        root.state = "HIDE"
        idRightPannel.focus = true
    }
    function updateParams()
    {
        var saveMode = Settings.saveMode();
        var nameMode = Settings.nameMode();
        var storePath = Settings.filePath();
        dataSource.setStorParam(saveMode, nameMode, storePath);
        idBottomPannel.updateParams()
    }

}


