import QtQuick 2.0
import "../Inc.js" as Com

import Qt.labs.folderlistmodel 2.0

//
Item {
    id: root
    anchors.centerIn: parent
    width: 600
    height: 400
    property string savePath:  Settings.filePath() //"D:/Store/"
    property string selectedFilename: ""
    property var    parentObject: undefined
    property var popBoxchildArray:[]; //弹出框子元素存储数组
    property var filelistchildArray:[]; //弹出对话框的所有子元素
    property var stateRectArray:[]; //弹出对话框下面的按钮
    property int nowFocusIndex:-1; //获得焦点的按钮索引
    property var everyElementInStateRect:undefined; //StateRect类型的元素
    property int mouseAreaElementIndex:0; //QQuickMouseArea元素索引
    //文件选择框
    ContentBox{
        id:box
        titleText: "文件选择"
        anchors.fill: parent
        bgColor: "#000000"
        //遍历文件夹模块
        Item {
            objectName: "fileChoose"
            anchors.top: parent.top
            anchors.topMargin: 30
            anchors.left: parent.left
            anchors.leftMargin: 4
            height: 320
            width: parent.width-40

            FolderListModel
            {
                 id: foldermodel
                 folder: "file:"+savePath //需要解析的文件夹
                 showDirs: true //是否显示文件夹。默认为真
                 showDotAndDotDot: false //如果为真，"." and ".."目录被包含在model中，否则被排除。默认为假
                 nameFilters: ["*.dat","*.png"] //筛选过滤作用，注意的是目录不会被过滤排除
                 sortField: FolderListModel.Type //设置排序模式,是一个枚举值，下面进行讲解
                 showOnlyReadable: true
                 sortReversed: false //如果为真，逆转排序顺序。默认为假

            }

            Component {
                id: fileDelegate
                Rectangle{
                    id:wrapper
                    objectName:"popUpfileDelegate"
                    width: parent.width
                    height: 18
                    color: wrapper.ListView.isCurrentItem ? "#404244" : "#000000"
                    border.color: "#67696B"
                    border.width: wrapper.ListView.isCurrentItem ? 1 :0
                    radius: 4
                    property var flag: chartflag
                    Text {
                        id:fileIndex
                        anchors.left: parent.left
                        width: parent.width * 0.1
                        text:" "+(index+1)+"/"+foldermodel.count
                        color: foldermodel.isFolder(index)? "#404244" : "#D69545" //判断是否文件夹
                        font.pixelSize: 16
                    }
                    Text {
                        id:fName
                        anchors.left: fileIndex.right
                        width: parent.width * 0.8
                        text:" "+fileName
                        color: foldermodel.isFolder(index)? "#404244" : "#D69545" //判断是否文件夹
                        font.pixelSize: 16
                    }
                    Text {
                        id:chartflag
                        anchors.left: fName.right
                        width: parent.width * 0.1
                        height:parent.height
                        font.family: "FontAwesome"
                        text: "\uf159"
                        objectName: fileName
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment:   Text.AlignVCenter
                        color: selectState(savePath+"/"+fileName)
                        font.pixelSize: 16
                    }
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            wrapper.ListView.view.currentIndex = index//更新视图索引
                            listView.focus = true
                            selectedFilename = savePath+"/"+ fileName
                        }
                        onEntered:
                        {
                            pressedAnim.start()
                            releasedAnim.stop()
                        }
                        onExited:
                        {
                            releasedAnim.start()
                            pressedAnim.stop()
                        }

                    }
                    PropertyAnimation {
                        id: pressedAnim;
                        target: wrapper;
                        property: "color";
                        to: "#404244";
                        duration: 200
                    }
                    PropertyAnimation {
                        id: releasedAnim;
                        target: wrapper;
                        property: "color";
                        to: "#000000"
                        duration: 200
                    }
                }
            }
            Rectangle{
                id:subTop
                anchors.top: parent.top
                height: 20
                color: box.bgColor
                width: parent.width
                Text {
                    id:fileIndexTop
                    anchors.left: parent.left
                    width: parent.width * 0.1
                    font.family: Com.fontFamily
                    text:"索引/总数"
                    color:"white"
                }
                Text {
                    id:fNameTop
                    anchors.left: fileIndexTop.right
                    width: parent.width * 0.78
                    font.family: Com.fontFamily
                    text:" 文件名"
                    color:"white"
                }
                Text {
                    id:chartflagTop
                    anchors.left: fNameTop.right
                    font.family: Com.fontFamily
                    text:"通道选定状态"
                    color:"white"
                }
            }
            //文件列表
            ListView{
                id:listView
                anchors{top:subTop.bottom;bottom: parent.bottom}
                width: parent.width
                model: foldermodel
                delegate: fileDelegate
                onCurrentIndexChanged: {
                    //console.log("clicked idx:"+listView.currentIndex)
                }
                //highlight: Rectangle{
                //    color:"lightblue"
                //}
                Component.onCompleted: {
                    listView.currentIndex = -1
                }
                Keys.enabled: true
                Keys.forwardTo: [fileDelegate]
                Keys.onPressed:{
                    switch(event.key)
                    {
                    case Qt.Key_0:
                    case Qt.Key_1:
                    case Qt.Key_2:
                    case Qt.Key_3:
                    case Qt.Key_4:
                    case Qt.Key_5:
                    case Qt.Key_6:
                    case Qt.Key_7:
                    case Qt.Key_8:
                    case Qt.Key_9:
                    event.accepted = true;
                        //console.log(event.key - Qt.Key_0)
                        //keyname.text = event.key - Qt.Key_0;
                        break;
                    }
                }
            }//文件列表 end
         }//遍历文件夹模块 end

        StateRect{
            id:closeBox
            anchors.right: box.right
            anchors.rightMargin: 40
            anchors.bottom: box.bottom
            anchors.bottomMargin: 10
            width: 100;
            height: 24
            //textLabel:"关闭"
            btnName: "关闭"
            onClicked:
            {
                root.visible = false
                analyzeMode.focus=true
                root.focus=false;
                globalConsoleInfo("查看StateRect里的root=="+root);
                parentObject.visible = false;
            }
        }
        StateRect{
            id:cancleBox
            anchors.right: closeBox.left
            anchors.rightMargin: 8
            anchors.bottom: closeBox.bottom
            width: 100;
            height: 24
            btnName: "关闭通道"
            onClicked:
            {

                if(selectedFilename.length>0)
                {
                    var apply = true
                    if(Qt.colorEqual(listView.currentItem.flag.color, Com.series_color1))
                        cancleSelect(0, false)
                    else if(Qt.colorEqual(listView.currentItem.flag.color, Com.series_color2))
                        cancleSelect(1, false)
                    else if(Qt.colorEqual(listView.currentItem.flag.color, Com.series_color3))
                        cancleSelect(2, false)
                    else{
                        noteBox.opacity = 1
                        noteBox.visible = true
                        noteText.text = "未选中有效通道"
                        fadeOut.stop()
                        fadeOut.start()
                        apply = false
                    }
                    if(apply)
                        analyzeMenu.updateParams();
                }else{
                    noteBox.opacity = 1
                    noteBox.visible = true
                    noteText.text = "请先选取文件"
                    fadeOut.stop()
                    fadeOut.start()
                }

            }
        }
        StateRect{
            id:select3
            anchors.right: cancleBox.left
            anchors.rightMargin: 8
            anchors.bottom: cancleBox.bottom
            width: 100;
            height: 24
            textIcon: "\uf159"
            iconColor: Com.series_color3
            btnName: "通道3"
            onClicked:
            {
                cancleSelect(2,true)
                if(dataSource.addHistoryFile("series3",selectedFilename))
                {
                    listView.currentItem.flag.color = Com.series_color3
                    Settings.historyFile3(Com.OpSet, selectedFilename);
                }
                else
                {
                    noteBox.opacity = 1
                    noteBox.visible = true
                    noteText.text = "文件是空文件,通道3已关闭"
                    fadeOut.stop()
                    fadeOut.start()
                }
                analyzeMenu.updateParams();
            }
        }
        StateRect{
            id:select2
            anchors.right: select3.left
            anchors.rightMargin: 8
            anchors.bottom: select3.bottom
            width: 100;
            height: 24
            textIcon: "\uf159"
            iconColor: Com.series_color2
            btnName: "通道2"
            onClicked:
            {
                cancleSelect(1,true)
                if(dataSource.addHistoryFile("series2",selectedFilename))
                {
                    listView.currentItem.flag.color = Com.series_color2
                    Settings.historyFile2(Com.OpSet, selectedFilename);
                }
                else
                {
                    noteBox.opacity = 1
                    noteBox.visible = true
                    noteText.text = "文件是空文件,通道2已关闭"
                    fadeOut.stop()
                    fadeOut.start()
                }
                analyzeMenu.updateParams();
            }
        }
        StateRect{
            id:select1
            anchors.right: select2.left
            anchors.rightMargin: 8
            anchors.bottom: select2.bottom
            width: 100;
            height: 24
            textIcon: "\uf159"
            iconColor: Com.series_color1
            btnName: "通道1"
            onClicked:
            {
                cancleSelect(0,true)
                if(dataSource.addHistoryFile("series1",selectedFilename))
                {
                    listView.currentItem.flag.color = Com.series_color1
                    Settings.historyFile1(Com.OpSet, selectedFilename);
                }
                else
                {
                    noteBox.opacity = 1
                    noteBox.visible = true
                    noteText.text = "文件是空文件,通道1已关闭"
                    fadeOut.stop()
                    fadeOut.start()
                }
                analyzeMenu.updateParams();
            }
        }
    }//！--文件选择框 end

    Rectangle{
        id:noteBox
        anchors.centerIn: parent
        width: parent.width*0.6
        height: 30
        color: "#00000000"
        visible: false
        Canvas{
            anchors.fill: parent
            contextType: "2d";
            onPaint: {
                context.lineWidth = 1.5;
                context.strokeStyle = "#D34A4A";
                context.fillStyle = "#D34A4A";
                context.beginPath();
                context.moveTo(0 , 0);
                context.lineTo(0.98*width , 0);
                context.lineTo(width , 0.25*height);
                context.lineTo(width , height);
                context.lineTo(0.02*width , height);
                context.lineTo(0 , 0.75*height);
                context.closePath();
                context.fill();
                context.stroke();
            }
        }
        Text {
            id: noteText
            anchors.fill: parent
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "white"
            font.family: Com.fontFamily
            font.pixelSize: 16
            text: "请先取消选定状态"
        }
        PropertyAnimation {
            id: fadeOut;
            target: noteBox;
            property: "opacity";
            to: 0;
            easing.type: Easing.InExpo;
            duration: 1500
        }
    }

    function selectState(name)
    {
        if(name === Settings.historyFile1())
            return Com.series_color1
        else if(name === Settings.historyFile2())
            return Com.series_color2
        else if(name === Settings.historyFile3())
            return Com.series_color3
        else
            return "#00000000"
    }
    function cancleSelect(index, cover)
    {

        var color = "#00000000"
        switch(index)
        {
        case 0:
            Settings.historyFile1(Com.OpSet,"")
            dataSource.delHistoryFile("series1")
            color = Com.series_color1
            break;
        case 1:
            Settings.historyFile2(Com.OpSet,"")
            dataSource.delHistoryFile("series2")
            color = Com.series_color2
            break;
        case 2:
            Settings.historyFile3(Com.OpSet,"")
            dataSource.delHistoryFile("series3")
            color = Com.series_color3
            break;
        default:
            break;
        }

        if(cover)
            deleteIfExist(index);
        else
            deleteIfExist(-1);

        var org_idx = listView.currentIndex
        //遍历取消当前的选中状态
        for(var i=0; i<listView.count; i++)
        {
            listView.currentIndex = i;
            var idx_color = listView.currentItem.flag.color;

            //console.log(i, cur_color, color, b)
            if(Qt.colorEqual(idx_color, color))
            {
                listView.currentItem.flag.color = "#00000000"
                break;
            }
        }
        listView.currentIndex = org_idx
    }

    function deleteIfExist(idx)
    {
        var isExist = false;
        var text = ""
        var cur_color = listView.currentItem.flag.color;

        if(Qt.colorEqual(cur_color, Com.series_color1))
        {
            isExist = true;
            text = (idx!==0?"通道1已关闭":"通道1已更新")
            Settings.historyFile1(Com.OpSet,"")
            dataSource.delHistoryFile("series1")
        }
        else if(Qt.colorEqual(cur_color, Com.series_color2))
        {
            isExist = true;
            text = (idx!==1?"通道2已关闭":"通道2已更新")
            Settings.historyFile2(Com.OpSet,"")
            dataSource.delHistoryFile("series2")
        }
        else if(Qt.colorEqual(cur_color, Com.series_color3))
        {
            isExist = true;
            text = (idx!==2?"通道3已关闭":"通道3已更新")
            Settings.historyFile3(Com.OpSet,"")
            dataSource.delHistoryFile("series3")
        }

        if(isExist)
        {
            noteBox.opacity = 1
            noteBox.visible = true
            noteText.text = text
            fadeOut.stop()
            fadeOut.start()
        }
        else
            noteBox.visible = false
        return isExist
    }


    //遍历弹出框的元素
    function getItemOfPopBox(popObj)
    {
        var atomlist=popObj.children;



        for ( var i in atomlist)
        {


            var tempstr=atomlist[i].toString();
            var eachChild=atomlist[i];
            var index=tempstr.indexOf("_");
            var ContentBoxindex=tempstr.indexOf("ContentBox");

            var StateRectindex=tempstr.indexOf("StateRect");

            var QQuickItemindex=tempstr.indexOf("QQuickItem");


            if(StateRectindex!==-1)
            {
                popBoxchildArray.norepeatpush(atomlist[i]);
            }

            if(eachChild.objectName==="fileChoose")
            {
                popBoxchildArray.norepeatpush(eachChild);
            }
            if(ContentBoxindex!==-1)//子控件为ContentBoxindex
            {

                getItemOfPopBox(atomlist[i]);//递归
            }


        }


        return popBoxchildArray;
    }

    //文件列表框
    function getFileListBoxElement(popObj)
    {
        var rightListAarry= getItemOfPopBox(popObj);
        for(var idt=0;idt<rightListAarry.length;idt++)
        {

            var theelement=rightListAarry[idt];
            var tempNamestr=theelement.toString();
            globalConsoleInfo("◆◆◆◆rightListAarry"+idt+"===="+tempNamestr);
            if(theelement.objectName==="fileChoose")
            {
                globalConsoleInfo("★★★★找到文件列表框");
                return theelement;
            }

        }
        globalConsoleInfo("××××未到文件列表框");
        return popObj;

    }

    //文件列表框和下面的按钮
    function getAllAtomChildrenOfPopBox(popObj)
    {
        var rightListAarry= getItemOfPopBox(popObj);
        for(var idt=0;idt<rightListAarry.length;idt++)
        {
            var theelement=rightListAarry[i];
            var tempNamestr=theelement.toString();
            var theStateRectindex=tempNamestr.indexOf("StateRect");
            if(theStateRectindex!==-1)
            {
                filelistchildArray.norepeatpush(rightListAarry[i]);
            }
            if(theelement.objectName==="fileChoose")
            {
                filelistchildArray.norepeatpush(theelement);
            }

        }
        return filelistchildArray;
    }

    //下面的按钮
    function getStateRectOfFileList(popObj)
    {
        var rightListAarry= getItemOfPopBox(popObj);
        for(var idt=0;idt<rightListAarry.length;idt++)
        {
            var theelement=rightListAarry[idt];
            var tempNamestr=theelement.toString();
            var theStateRectindex=tempNamestr.indexOf("StateRect");
            if(theStateRectindex!==-1)
            {
                stateRectArray.norepeatpush(rightListAarry[idt]);
            }


        }
        return stateRectArray;
    }
    Keys.enabled: true
    Keys.forwardTo: root
    Keys.onPressed:
    {
        switch(event.key)
        {
        case Qt.Key_Escape:

            root.visible = false

            root.focus=false;
            analyzeMode.analyzeChildren[analyzeMode.currentBorderSel].focus=true;

            //analyzeMode.focus=true;
            break;
        case Qt.Key_Left:
            globalConsoleInfo("PopuBox.qml收到Qt.Key_Left消息");
            nowFocusIndex--;
            if(nowFocusIndex<0)
            {
                nowFocusIndex=stateRectArray.length-1;
            }
            stateRectArray[nowFocusIndex].focus=true;

            for(var pp=0;pp<stateRectArray[nowFocusIndex].children.length;pp++ )
            {
                //globalConsoleInfo(pp+"      ==="+stateRectArray[nowFocusIndex].children[pp]);
                everyElementInStateRect=stateRectArray[nowFocusIndex].children[pp];
                if(everyElementInStateRect.toString().indexOf("MouseArea")!=="-1")
                    mouseAreaElementIndex= pp;
            }
            everyElementInStateRect=stateRectArray[nowFocusIndex].children[mouseAreaElementIndex];
            everyElementInStateRect.entered();
            everyElementInStateRect.exited();
            globalConsoleInfo("←"+stateRectArray[nowFocusIndex].btnName);
            break;
        case Qt.Key_Right:
            globalConsoleInfo("PopuBox.qml收到Qt.Key_Right消息");
            nowFocusIndex++;

            if(nowFocusIndex>stateRectArray.length-1)
            {
                nowFocusIndex=0;
            }
            stateRectArray[nowFocusIndex].focus=true;
            for(var qq=0;qq<stateRectArray[nowFocusIndex].children.length;qq++ )
            {
                //globalConsoleInfo(pp+"      ==="+stateRectArray[nowFocusIndex].children[pp]);
                everyElementInStateRect=stateRectArray[nowFocusIndex].children[qq];
                if(everyElementInStateRect.toString().indexOf("MouseArea")!=="-1")
                    mouseAreaElementIndex= qq;
            }
            everyElementInStateRect=stateRectArray[nowFocusIndex].children[mouseAreaElementIndex];
            everyElementInStateRect.entered();
            everyElementInStateRect.exited();

            globalConsoleInfo("→"+stateRectArray[nowFocusIndex].btnName);
            break;
        default:
            globalConsoleInfo("popBox.qml收到按键消息"+event.key);
            break;


        }

    }

}

