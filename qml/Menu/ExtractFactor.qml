import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3
import "../Inc.js" as Com
import "../UI"

Rectangle{
    id:root

    state: "HIDE"
    width: 200
    //anchors.topMargin: 4
    //anchors.bottomMargin: 4

    //border.color: Com.BottomBorderColor
    //border.width: 1
    color: Com.BGColor_main
    objectName: "extractFactor"
    ColumnLayout {
        id:content
        spacing: 4;
        anchors.top: parent.top;
        anchors.left: parent.left
        anchors.leftMargin: 4;
        property int itemWidth: root.width - 8
        RightButton {
            id: btn_return;
            textLabel: "返回";
            icon:"\uf112"
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE"
                root.focus = false;

            }
        }
        RightButton {
            id: btn_prevpage;
            textLabel: "上一页";
            icon:"\uf062"
            width: parent.itemWidth
            onClick: {
                idFlick.flick(0, 534 * 2)
                //selected(true)
                //setParam(0)
            }
        }
        Flickable{
            id:idFlick
            width: parent.itemWidth
            height: 376
            contentWidth: parent.itemWidth
            contentHeight: 95*14-4
            clip:true
            ColumnLayout {
                id:flickContent
                spacing: 4;
                anchors.fill: parent
                RightButton {
                    id: btn_2;
                    textLabel: "2";
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(2)
                    }
                }
                RightButton {
                    id: btn_4;
                    textLabel: "4";
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(4)
                    }
                }
                RightButton {
                    id: btn_8;
                    textLabel: "8";
                    //icon:"\uf07c"
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(8)
                    }
                }
                RightButton {
                    id: btn_16;
                    textLabel: "16";
                    //icon:"\uf07c"
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(16)
                    }
                }
                RightButton {
                    id: btn_32;
                    textLabel: "32";
                    //icon:"\uf07c"
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(32)
                    }
                }
                RightButton {
                    id: btn_64;
                    textLabel: "64";
                    //icon:"\uf07c"
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(64)
                    }
                }
                RightButton {
                    id: btn_128;
                    textLabel: "128";
                    //icon:"\uf07c"
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(128)
                    }
                }
                RightButton {
                    id: btn_256;
                    textLabel: "256";
                    //icon:"\uf07c"
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(256)
                    }
                }
                RightButton {
                    id: btn_512;
                    textLabel: "512";
                    //icon:"\uf07c"
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(512)
                    }
                }
                RightButton {
                    id: btn_1024;
                    textLabel: "1024";
                    //icon:"\uf07c"
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(1024)
                    }
                }
                RightButton {
                    id: btn_2048;
                    textLabel: "2048";
                    //icon:"\uf07c"
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(2048)
                    }
                }
                RightButton {
                    id: btn_4096;
                    textLabel: "4096";
                    //icon:"\uf07c"
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(4096)
                    }
                }
                RightButton {
                    id: btn_8192;
                    textLabel: "8192";
                    //icon:"\uf07c"
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(8192)
                    }
                }
                RightButton {
                    id: btn_16384;
                    textLabel: "16384";
                    //icon:"\uf07c"
                    onClick: {
                        clearSelectBorder()
                        selected(true)
                        setParam(16384)
                    }
                }
            }
        }
        RightButton {
            id: btn_nextpage;
            textLabel: "下一页";
            icon:"\uf063"
            onClick: {
                idFlick.flick(0, -534*2)
            }
        }

        RightButton {
            id: btn_exit;
            textLabel: "返回主菜单";
            icon: "\uf090";
            width: parent.itemWidth
            onClick: {
                root.state = "HIDE";
                root.focus = false;
                root.parent.state="HIDE";//非直接菜单必须加这句
                idRightPannel.state="SHOW";
                idRightPannel.focus=true;
            }
        }
    }

    Keys.enabled: true
    Keys.forwardTo: [root]
    Keys.onPressed:{


    }
    function keyup()
    {
        globalConsoleInfo("key up")
    }
    function keydowm()
    {
        globalConsoleInfo("key down")
    }
    function keyenter()
    {
        globalConsoleInfo("key enter")
    }
    //过渡动画
    states: [
        State {
            name: "SHOW"
            PropertyChanges { target: root; x: root.parent.width-root.width}
            onCompleted:{
                root.focus = true;
                globalConsoleInfo("                                    ");
                globalConsoleInfo("                                    ");
                globalConsoleInfo("☆☆☆☆ClockSeting.qml获得焦点☆☆☆☆");
                globalConsoleInfo("                                    ");
                globalConsoleInfo("                                    ");
                //传递获得焦点的页面元素
                idScopeView.focusPageOfrightControl=root;
                Com.childArray=Com.resetAndgetItemOfControlPannel(root);
                Com.GlobalTotalchildArray=Com.resetGlobalItemOfElement(root);


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

    function clearSelectBorder()
    {
        var list = flickContent.children
        for(var i in list)
        {
            list[i].selected(false);
        }
    }
    function loadParam()
    {
        var list = flickContent.children
        var currentval = Settings.extractFactor()
        for(var i in list)
        {
           if( parseInt(list[i].textLabel) === currentval)
           {
               list[i].selected(true);
               break;
           }
        }
    }
    function setParam(val)
    {
        Settings.extractFactor(Com.OpSet, val)
        preconditionMenu.updateParams()
    }
}

