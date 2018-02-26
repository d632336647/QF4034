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
    width: 200
    anchors.topMargin: 4
    //anchors.bottomMargin: 4

    //border.color: Com.BottomBorderColor
    //border.width: 1
    color: Com.BGColor_main
    property var parentPointer: undefined
    signal hideCompleted
    ColumnLayout {
        id:content
        spacing: 4;
        anchors.top: parent.top;
        anchors.left: parent.left
        anchors.leftMargin: 4;
        property int itemWidth: root.width - 8
        RightButton {
            id: btn_menu;
            textLabel: "关闭菜单";
            width: parent.itemWidth
            onClick: {
                switchSystemMenu()
            }
        }
        RightButton {
            id: btn_quit;
            textLabel: "退出程序";
            icon: "\uf090";
            width: parent.itemWidth
            onClick: {
                Settings.save()
                captureThread.exit()
                dataSource.clearPCIE()
                Qt.quit()
            }
        }
        RightButton {
            id: btn_reset;
            textLabel: "重启系统";
            width: parent.itemWidth
            //icon:"\uf07c"
            onClick: {
                Settings.executeCommand("shutdown -r -t 5")
                btn_quit.click()
            }
        }
        RightButton {
            id: btn_shutdown;
            textLabel: "关机";
            width: parent.itemWidth
            onClick: {
                Settings.executeCommand("shutdown -s -t 5")
                btn_quit.click()
            }
        }
        RightButton {
            id: empty2;
            textLabel: "";
            width: parent.itemWidth
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
            id: empty4;
            textLabel: "";
            //icon:"\uf07c"
            onClick: {
            }
        }
        RightButton {
            id: btn_return;
            textLabel: "关闭菜单";
            width: parent.itemWidth
            onClick: {
                switchSystemMenu()
            }
        }

    }
    //过渡动画
    states: [
        State {
            name: "SHOW"
            PropertyChanges { target: root; x: root.parent.width-root.width}
            onCompleted:{
            }
        },
        State {
            name: "HIDE"
            PropertyChanges { target: root; x: root.parent.width}
            onCompleted: {
                root.hideCompleted()
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

    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{
        var key = [Qt.Key_Q, Qt.Key_F21, Qt.Key_F1, Qt.Key_F2, Qt.Key_F3, Qt.Key_F4, Qt.Key_F8]
        var fid = [btn_menu, btn_menu, btn_menu, btn_quit, btn_reset, btn_shutdown, btn_return]
        Lib.clickFunctionKey(event.key, key, fid);
        event.accepted = true;
    }
    function hideMenu(){}
    function turnToMainMenu(){}
    function turnToParentMenu(){}
    function switchSystemMenu()
    {
        if(root.state === "HIDE")
        {
            root.parentPointer = mainWindow.activeFocusItem
            root.state = "SHOW"
            root.focus = true;
        }
        else
        {
            root.state = "HIDE"
            if(idRightPannel.state === "HIDE")
            {
                idRightPannel.focus = true
                root.parentPointer = idRightPannel
            }
            else
                root.parentPointer.focus = true
        }
    }
    function btnReturnClick()
    {
        btn_return.keyPressed()
    }
    function btnQuitClick()
    {
        btn_quit.keyPressed()
    }
    function btnShutdownClick()
    {
        btn_shutdown.keyPressed()
    }
    function btnResetClick()
    {
        btn_reset.keyPressed()
    }
    function btnExitClick()
    {
        btn_exit.keyPressed()
    }
}

