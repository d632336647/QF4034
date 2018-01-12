import QtQuick 2.0
import QtCharts 2.1
import "UI"
import "Lib.js" as Lib

Item {
    property bool hoverEnable: true

    property alias lineSeries1: lineSeries1
    property alias lineSeries2: lineSeries2
    property alias lineSeries3: lineSeries3

    property bool timeDodminEn: false
    property point bottomLeft
    property point topRight

    function updateFreqDodminAxis(waterfallVisible)
    {
        Lib.updateAxisX(idAxisX, centerFreq, bandwidth);
        bottomLeft.x = idAxisX.min;
        topRight.x = idAxisX.max;
        bottomLeft.y = 70
        topRight.y = 170;

        idAxisX.titleVisible = true;
        idAxisX.labelFormat = "";

        idAxisY.min = bottomLeft.y;
        idAxisY.max = topRight.y;
        idAxisY.labelFormat = "";
        if(waterfallVisible)
            idAxisY.tickCount = 11;//纵坐标间隔
        else
            idAxisY.tickCount = 21;        
        idAxisY.titleVisible = true;

        timeDodminEn = false;
    }
    function updateTimeDodminAxis()
    {
        idAxisX.min = bottomLeft.x;
        idAxisX.max = topRight.x;
        idAxisX.labelFormat = "%d";
        idAxisX.titleVisible = false;

        idAxisY.min = -32768;//bottomLeft.y;
        idAxisY.max = 32768;//topRight.y;
        idAxisY.labelFormat = "%d";
        idAxisY.titleVisible = false;
        timeDodminEn = true;
    }
    function addLineSeriesTimeDomin(fileName)
    {
        signalCheckBox1.visible = true;
        signalCheckBox2.visible = true;
        signalCheckBox3.visible = false;
        idPeak1.showPeak(undefined, false);
        if(fileName.length)
        {
            lineSeries1.visible = true;
            lineSeries2.visible = true;
            dataSource.updateTimeDomainFromFile(lineSeries1, lineSeries2, fileName);
            bottomLeft = dataSource.getWaveInfoBottomLeft(lineSeries1);
            topRight = dataSource.getWaveInfoTopRight(lineSeries1);
            updateTimeDodminAxis();
        }
        else
        {
            if(lineSeries1)
                removeLineSeries(lineSeries1);
            if(lineSeries2)
                removeLineSeries(lineSeries2);
        }
    }
    function updateLineSeries(){
        var lineSeries = lineSeries1;
        var peakVisible = false;
        var peakPoint=dataSource.updateFreqDodminFromData(lineSeries);
        idPeak1.showPeak(peakPoint, peakVisible);
    }
    function addLineSeries(lineSeries, fileName, signalCheckVisible, peakVisible)
    {
        if(fileName.length && (fileName !== "realtime") )
        {
            lineSeries.visible = true;
            var peakPoint=dataSource.updateFreqDodminFromFile(lineSeries, fileName);
            if(lineSeries === lineSeries1)
            {
                signalCheckBox1.visible = signalCheckVisible;  
                idPeak1.showPeak(peakPoint, peakVisible);
            }
            if(lineSeries === lineSeries2)
            {
                signalCheckBox2.visible = signalCheckVisible;
            }
            if(lineSeries === lineSeries3)
            {
                signalCheckBox3.visible = signalCheckVisible;
            }
        }
        else if(fileName==="realtime")
        {
            lineSeries.visible = true;
            signalCheckBox1.visible = signalCheckVisible;
            idPeak1.showPeak(peakPoint, peakVisible);
        }
        else if(lineSeries)
        {
            removeLineSeries(lineSeries)
        }
        return lineSeries
    }
    function removeLineSeries(lineSeries)
    {
        lineSeries.visible = false;
        if(lineSeries === lineSeries1)
            signalCheckBox1.visible = false;
        if(lineSeries === lineSeries2)
            signalCheckBox2.visible = false;
        if(lineSeries === lineSeries3)
            signalCheckBox3.visible = false;
    }
    function setLegendVisible(visible)
    {
        idChartView.legend.visible = visible;
    }
    function getAxisXBandwidth()
    {
        var skip = timeDodminEn ? 1 : resolution / 1000000.0;
        var bd =  skip * (idAxisX.tickCount - 1);
        return bd;
    }


    PeakView{
        id: idPeak1
        chartView: idChartView
    }
    Item{
        x: idChartView.width - 45
        y: 15
        z: 2
        Column{
            SignalCheckBox{
                id: signalCheckBox1
                signalColor: "#38ad6b"
                onSignalCheck: lineSeries1.visible = checked
            }
            SignalCheckBox{
                id: signalCheckBox2
                signalColor: "#3c84a7"
                onSignalCheck: lineSeries2.visible = checked
            }
            SignalCheckBox{
                id: signalCheckBox3
                signalColor: "#eb8817"
                onSignalCheck: lineSeries3.visible = checked
            }
        }
    }
    ChartView{
        z: 1
        id: idChartView
        animationOptions: ChartView.NoAnimation
        //theme: ChartView.ChartThemeDark
        anchors.fill: parent
        antialiasing: true
        backgroundColor: "#00000000"
        property bool openGL: true
        legend{
            visible: false
        }

        ValueAxis {
            id: idAxisX;
            min: -12.5;
            max: 12.5;
            tickCount: 11;
            titleText: "MHz";
            titleFont.pixelSize: 12;

        }
        ValueAxis {
            id: idAxisY;
            min: 70;
            max: 170;
            tickCount: 21;
            titleText: "dBm";
            titleFont.pixelSize: 12;
        }

        LineSeries {
            id: lineSeries1
            name: "signal 1"
            axisX: idAxisX
            axisY: idAxisY
            useOpenGL: idChartView.openGL
        }
        LineSeries {
            id: lineSeries2
            name: "signal 2"
            axisX: idAxisX
            axisY: idAxisY
            useOpenGL: idChartView.openGL
        }
        LineSeries {
            id: lineSeries3
            name: "signal 3"
            axisX: idAxisX
            axisY: idAxisY
            useOpenGL: idChartView.openGL
        }
        MouseArea{
            property var mousex
            property var mousey
            property string scrollType_axisX: "axisX"
            property string scrollType_axisY: "axisY"
            property string scrollType_axisMain: "axisMain"
            property string scrollType_null: "null"
            property string scrollType

            anchors.fill: parent
            hoverEnabled: true
            enabled: hoverEnable
            onPositionChanged: {
                var dataPoint = idChartView.mapToValue(Qt.point(mouseX, mouseY));
                if(dataPoint.x > idAxisX.min && dataPoint.x < idAxisX.max && dataPoint.y < idAxisY.min)
                    scrollType = scrollType_axisX;
                else if(dataPoint.x < idAxisX.min && dataPoint.y > idAxisY.min && dataPoint.y < idAxisY.max)
                    scrollType = scrollType_axisY;
                else if(dataPoint.x > idAxisX.min && dataPoint.x < idAxisX.max && dataPoint.y > idAxisY.min && dataPoint.y < idAxisY.max)
                    scrollType = scrollType_axisMain;
                else
                {
                    scrollType = scrollType_null;
                    return;
                }
                if(pressedButtons == Qt.LeftButton)
                {
                    if(scrollType != scrollType_axisY)
                    {
                        idChartView.scrollLeft(mouseX - mousex);
                        if(mouseX > mousex)
                        {
                            if(idAxisX.min < bottomLeft.x)
                            {
                                idAxisX.min = bottomLeft.x;
                                var bd =  getAxisXBandwidth();
                                if(idAxisX.max <= (idAxisX.min + bd))
                                    idAxisX.max = (idAxisX.min + bd);
                            }
                        }
                        else
                        {
                            if(idAxisX.max > topRight.x)
                            {
                                var bd =  getAxisXBandwidth();
                                if(idAxisX.max <= (idAxisX.min + bd))
                                    idAxisX.min = topRight.x - bd;
                                idAxisX.max = topRight.x;
                            }
                        }
                    }
                    mousex = mouseX;

                    if(scrollType == scrollType_axisY)  //if(scrollType != scrollType_axisX)
                        idChartView.scrollUp(mouseY - mousey);
                    mousey = mouseY;                    
                }
//                showTrip(dataPoint, mouseX, mouseY);
                idPeak1.updatePos();
            }
            onWheel: {
                if(wheel.angleDelta.y > 0)
                {
                    if(scrollType === scrollType_axisX || scrollType === scrollType_axisMain)
                    {
                        var bd =  getAxisXBandwidth();
                        if(idAxisX.max === (idAxisX.min + bd))
                            return;

                        var xyPoint = Qt.point(mouseX, mouseY);
                        var dataPoint = idChartView.mapToValue(xyPoint);
                        var div = 5.5;//timeDodminEn ? 5.5 : 5.5;//22;

                        var step = (idAxisX.max - idAxisX.min) / div;
                        idAxisX.max -= step;
                        idAxisX.min += step;

                        var xyPoint_new = idChartView.mapToPosition(dataPoint);
                        idChartView.scrollRight(xyPoint_new.x - xyPoint.x);

                        if(idAxisX.max < (idAxisX.min + bd))
                            idAxisX.max = (idAxisX.min + bd);
                    }
                    else if(scrollType === scrollType_axisY)
                    {
                        var div = 5.5;//timeDodminEn ? 22 : 22;
                        var step = (idAxisY.max - idAxisY.min) / div;
                        idAxisY.max -= step;
                        idAxisY.min += step;
                    }
                    else if(scrollType === scrollType_axisMain)
                    {
                        var xyPoint = Qt.point(mouseX, mouseY);
                        var dataPoint = idChartView.mapToValue(xyPoint);

                        idChartView.zoomIn();

                        var xyPoint_new = idChartView.mapToPosition(dataPoint);
                        idChartView.scrollRight(xyPoint_new.x - xyPoint.x);
                    }
                }
                else
                {
                    if(scrollType === scrollType_axisX || scrollType === scrollType_axisMain)
                    {
                        if(idAxisX.min === bottomLeft.x && idAxisX.max === topRight.x)
                            return;
                        var xyPoint = Qt.point(mouseX, mouseY);
                        var dataPoint = idChartView.mapToValue(xyPoint);
                        var div = 5;//timeDodminEn ? 5 : 5;//20;

                        var step = (idAxisX.max - idAxisX.min) / div;
                        idAxisX.max += step;
                        idAxisX.min -= step;

                        var xyPoint_new = idChartView.mapToPosition(dataPoint);
                        idChartView.scrollRight(xyPoint_new.x - xyPoint.x);

                        if(idAxisX.max > topRight.x)
                            idAxisX.max = topRight.x;
                        if(idAxisX.min < bottomLeft.x)
                            idAxisX.min = bottomLeft.x;
                    }
                    else if(scrollType === scrollType_axisY)
                    {
                        var div = 5;//timeDodminEn ? 20 : 20;
                        var step = (idAxisY.max - idAxisY.min) / div;
                        idAxisY.max += step;
                        idAxisY.min -= step;
                    }
                    else if(scrollType === scrollType_axisMain)
                    {
                        var xyPoint = Qt.point(mouseX, mouseY);
                        var dataPoint = idChartView.mapToValue(xyPoint);

                        idChartView.zoomOut();

                        var xyPoint_new = idChartView.mapToPosition(dataPoint);
                        idChartView.scrollRight(xyPoint_new.x - xyPoint.x);
                    }
                }
                idPeak1.updatePos();
            }
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onPressed: {
                mousex = mouseX;
                mousey = mouseY;
            }
        }
    }
    onWidthChanged: {
        idPeak1.updatePos();
    }
    onHeightChanged: {
        idPeak1.updatePos();
    }
    Component.onCompleted: {
        lineSeries1.width = 0.8
        lineSeries2.width = 0.8
        lineSeries3.width = 0.8
        removeLineSeries(lineSeries2);
        removeLineSeries(lineSeries3);
        dataSource.changeAxis(idChartView.axisX());
        dataSource.changeAxis(idChartView.axisY());
//        dataSource.update_file(lineSeries1, "E://proj/signalcapture/soft/pc/spectrumAnalyzer/doc/Data_fs100M_fd2M_fc10M_Comp.dat");
    }
}
