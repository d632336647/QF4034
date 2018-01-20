/****************************************************************************
**
** Copyright (C) 2016 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the Qt Charts module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:GPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3 or (at your option) any later version
** approved by the KDE Free Qt Foundation. The licenses are as published by
** the Free Software Foundation and appearing in the file LICENSE.GPL3
** included in the packaging of this file. Please review the following
** information to ensure the GNU General Public License requirements will
** be met: https://www.gnu.org/licenses/gpl-3.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/
#include <QGuiApplication>
#include <QtWidgets/QApplication>
#include <QQmlApplicationEngine>
#include <QtCharts/QXYSeries>
#include <QtCharts/QAreaSeries>
#include <QtQuick/QQuickView>
#include <QtCore/QDebug>
#include <QtCore/QtMath>
#include <QValueAxis>
#include <QLibrary>
#include <QDateTime>
#include <math.h>
#include <string.h>

#include "DataSource.h"

QT_CHARTS_USE_NAMESPACE

Q_DECLARE_METATYPE(QAbstractSeries *)
Q_DECLARE_METATYPE(QAbstractAxis *)


DataSource::DataSource(QObject *parent, Settings *st)
    : QObject(parent)
    , m_spectrum()
    , m_fftCount(1024)
    , m_storeMedia(0)
    , m_nameMode(0)
    , m_captureSize(0)
    , m_isStoring(0)
    , m_pcieCard(NULL)
{
    qRegisterMetaType<QAbstractSeries*>();
    qRegisterMetaType<QAbstractAxis*>();


    m_pcieCard = NULL;

    m_pciDev = new PciDeviceAPI("spectrumAnalyzer", 0x1556, 0x1100);
    m_pciDev->scanCard();
    PcieCard *pcieObj = (PcieCard*)m_pciDev->getCard(1);
    if(pcieObj){
        m_pcieCard = new PcieCardAPI(pcieObj);
        PCI_DEVICE_INFO *cardInfo = m_pcieCard->cardInfo();
        qDebug() <<"CardInfo---" <<cardInfo->mainType<<cardInfo->subType;
        qDebug("CardInfo--- %#x %#x\n",cardInfo->vendorID, cardInfo->deviceID);
        if(m_pcieCard->selfCheck())
        {
            qDebug() <<"Pcie card softReset---" <<m_pcieCard->softReset();
            qDebug() <<"Pcie card hardReset---" <<m_pcieCard->hardReset();
            //qDebug() <<"Pcie card allReset---" << m_pcieCard->allReset();
        }
        else
        {
            qDebug() <<"Card selfcheck fail";
            m_pcieCard = NULL;
        }
    }
    else
    {
        qDebug() <<"Card Init Failed!";
        m_pcieCard = NULL;
    }

    for(int ch = 0; ch<CHNUM; ch++)
    {
        m_show_points[ch][0].clear();
        m_show_points[ch][1].clear();
        m_show_points[ch][2].clear();

        m_waterfall_points[ch].clear();
    }


    m_settings = st;
    m_filePath.clear();
    this->initHistoryFile();
}
DataSource::~DataSource(){
    if(m_pciDev)
    {
        qDebug()<<"delete pcie driver";
        delete m_pciDev;
    }
    if(m_pcieCard)
    {
        qDebug()<<"delete pcie card";
        delete m_pcieCard;
    }

    this->clearHistoryFile();
}
void DataSource::changeAxis(QAbstractAxis *axis){
    if (axis) {
        QPen pen=axis->gridLinePen();
        pen.setStyle(Qt::DotLine);
        axis->setGridLinePen(pen);

//        pen=axis->linePen();
//        pen.setStyle(Qt::SolidLine);
//        axis->setLinePen(pen);
    }
}
void DataSource::updateFreqDodminFromData(void)
{

    if(!m_pcieCard){
        //qDebug()<<"m_pcieCard error";
        return;
    }

    //1FFT点 = 1对IQ = 2个short类型 = 4 char类型，
    //对于多通道， 还要 x通道数

    qint64 fft_count = 10000 * 4 * 2;

    qint64 max_count = m_bandwidth*1000000/m_resolution * 8;
    max_count = max_count * CHNUM;

    max_count = fft_count;

    //qDebug()<<"1111111:"<<QDateTime::currentDateTime();
    uchar *sampleData = new uchar[max_count];
    int len = m_pcieCard->getSampleData(sampleData, max_count);
    if(len<=0){
        delete[] sampleData;
        qDebug()<<"getSampleData failed";
        return;
    }

    QVector<QVector<signed short>> orgdata;
    this->separateData(CHNUM, sampleData, len,  orgdata);
    for(int ch=0; ch<orgdata.size(); ch++)
    {
        QVector<signed short> vdata = orgdata.at(ch);
        QVector<double> fftData;
        if(vdata.size()>0){
            if(!m_spectrum.fftFromData(vdata.data(), vdata.size()/2, fftData)){
                qDebug()<<"fftFromData failed";
                return;
            }

        //qDebug()<<"3333333:"<<QDateTime::currentDateTime();
        QVector<QPointF> points;
        this->workAllPoint(fftData, points);

        fftlock.lockForWrite();//文件读写锁
        m_show_points[ch][0].clear();
        this->cutShowPoint(points, m_show_points[ch][0]);

        //this->smooth(m_show_points[0]);

        fftlock.unlock();

        //qDebug()<<"emit updateFFTPoints ch:"<<ch<<"idx:"<<0;
        emit updateFFTPoints(ch, 0);

        //this->smartUpdateSeries(series);

        }
    }
    delete[] sampleData;
}
void DataSource::updateFreqDodminFromFile(QAbstractSeries *series, QString fileName)
{
    if(!series)
        return;

    QVector<QPointF> t_show_point;

    t_show_point.clear();

    //QXYSeries *xySeries = static_cast<QXYSeries *>(series);

    //qDebug()<<"series->objectName()"<<series->objectName();



    QFile *file = this->getFile(series->objectName());
    qreal percent = filePercent.value(series->objectName());
    //qDebug()<<"updateFreqDodminFromFile percent:"<<percent;
    if(file == nullptr)
    {
        qDebug()<<"ERROR: file nullptr";
        return;
    }

    QVector<double> fftData;

    if(!m_spectrum.fftFromFile(file, m_fftCount, percent, fftData))
        return;


    QVector<QPointF> points;
    this->workAllPoint(fftData, points);
    this->cutShowPoint(points, t_show_point);


    //this->smooth(t_show_point);

    int series_idx = 0;
    if(series->objectName() == "series1")
        series_idx = 0;
    else if(series->objectName() == "series2")
        series_idx = 1;
    else if(series->objectName() == "series3")
        series_idx = 2;

    m_show_points[0][series_idx] = t_show_point;

    //emit updateFFTPoints(0, series_idx); //由SpectrumData类自行获取并刷新

    //qDebug()<<"--------------------updateFreqDodminFromFile--------------------";
    //qDebug()<<"Total Point="<<fftData.size();
    //qDebug()<<"Show  Point="<<t_show_point.size();
    //qDebug()<<"----------------------------------------------------------------";

}
void DataSource::setFFTParam(double centerFreq, double bandwidth, int resolution)
{
    if(m_centerFreq != centerFreq)
    {
        m_centerFreq = centerFreq;
    }
    if(m_bandwidth != bandwidth)
    {
        m_bandwidth = bandwidth;
    }
    if(m_resolution != resolution)
    {
        m_resolution = resolution;
    }
    m_fftCount   = 50 * 1000000.0 / m_resolution;

    //qDebug()<<"setFFTParam m_bandwidth:"<<m_bandwidth<<" m_resolution:"<<m_resolution<<" m_fftCount:"<<m_fftCount;

}

int DataSource::updateWaterfallPlotFromFile(int ch, QString fileName)
{
    Q_UNUSED(fileName)

    if(ch>CHNUM)
        ch = 0;
    //QVector<QVector<double>> &origData = m_waterfall_points[ch];
    QVector<double> &origData = m_waterfall_points[ch];
    bool readok = false;

    QFile *file = this->getFile("series1");
    if(file == nullptr)
        return 0;
    wtflock.lockForWrite();
    //qDebug()<<"update waterfall ch"<<ch<<"plot from file";
    if(m_spectrum.fftFromFile(file, m_fftCount, filePercent.value("series1"), origData))
    {
        readok = true;
    }
    wtflock.unlock();
    if(readok)
        emit updateWaterfallFile(ch, m_bandwidth, m_centerFreq);

    //qDebug()<<"updateWaterfallPlotFromFile  count line:"<<origData.count();

    return 0;
}

/*
void DataSource::openWaterfallRtCapture(WaterfallPlot *wf)
{
    m_waterfall = wf;
    m_start_wf  = true;
    m_wf_fps = 0;
    m_waterfall->clearPixelColor();
}
void DataSource::closeWaterfallRtCapture(void)
{
    m_waterfall = nullptr;
    m_start_wf  = false;
    m_wf_fps = 0;
}
*/



void DataSource::updateTimeDomainFromFile(QAbstractSeries *series1, QAbstractSeries *series2, QString fileName)
{
    QXYSeries *xySeries1 = static_cast<QXYSeries *>(series1);
    QXYSeries *xySeries2 = static_cast<QXYSeries *>(series2);

    if(!fileName.length())
        return;

    QFile *pf = this->getFile("series1");
    if(pf == nullptr)
        return;

    if(!pf->isOpen())
    {
        qDebug()<<"ERROR:  updateTimeDomainFromFile() file is not open"<<pf->fileName();
        return;
    }
    int colCount = 10000;
    int point_count = pf->size()/4;
    if(colCount%2)
        colCount -= 1;

    int start = 0;
    if((point_count-100) >= colCount){
        start = point_count - colCount;
        start = start * filePercent.value("series1");
    }
    else
        colCount = point_count;

    QByteArray d;
    pf->reset();
    pf->seek(start*4);
    d = pf->read(colCount*4);



    QVector<WaveInfo>::iterator itor;
    for(itor=m_waveInfo.begin();itor!=m_waveInfo.end();){
        if(itor->m_xySeries == xySeries1
                ||itor->m_xySeries == xySeries2)
        {
            itor->reset();
            m_waveInfo.erase(itor);
        }
    }

    //qDebug()<<"skip"<<skip<<" colCount"<<colCount;

    signed short *pData = (signed short *)d.data();
    QVector<QPointF> points1, points2;
    points1.reserve(colCount);
    points2.reserve(colCount);
    for (int i(0); i < colCount; i++) {
//        points1.append(QPointF(i, pData[i * 2]));
//        points2.append(QPointF(i, pData[i * 2 + 1]));


        points1.append(QPointF(i, pData[i*2]));
        points2.append(QPointF(i, pData[i*2 + 1]));

        //qDebug() << points1.last() << points2.last() ;
    }
//    qDebug() << points1.length();
    WaveInfo waveInfo1(xySeries1, points1);
    WaveInfo waveInfo2(xySeries2, points2);

    m_waveInfo.append(waveInfo1);
    m_waveInfo.append(waveInfo2);

    xySeries1->replace(points1);
    xySeries2->replace(points2);
}
QPointF DataSource::getWaveInfoBottomLeft(QAbstractSeries *series)
{
    QXYSeries *xySeries = static_cast<QXYSeries *>(series);
    QPointF point(0, 0);

    foreach (WaveInfo waveInfo, m_waveInfo) {
        if(waveInfo.m_xySeries == xySeries)
        {
            point.setX(waveInfo.m_xMin);
            point.setY(waveInfo.m_yMin);
            break;
        }
    }

//    qDebug("DataSource::getWaveInfoBottomLeft: (%f, %f)", point.x(), point.y());
    return point;
}
QPointF DataSource::getWaveInfoTopRight(QAbstractSeries *series)
{
    QXYSeries *xySeries = static_cast<QXYSeries *>(series);
    QPointF point(0, 0);

    foreach (WaveInfo waveInfo, m_waveInfo) {
        if(waveInfo.m_xySeries == xySeries)
        {
            point.setX(waveInfo.m_xMax);
            point.setY(waveInfo.m_yMax);
            break;
        }
    }

//    qDebug("DataSource::getWaveInfoTopRight: (%f, %f)", point.x(), point.y());
    return point;
}
void DataSource::setCaptureParam(int clkMode, double captureFreq, int triggerMode, int captureMode, int captureSize){
    if(!m_pcieCard)
        return;
    if( captureFreq <40 || captureFreq > 250 )
    {
        qDebug()<< "输入频率无效.\n范围:[40-250]";
        return ;
    }
    m_clkMode = clkMode;
    m_captureFreq = captureFreq;
    m_triggerMode = triggerMode;
    m_captureMode = captureMode;
    m_captureSize = captureSize;
    ClockTrigger clockTrigger;
    clockTrigger.m_clockType = (EnumClock)m_clkMode;
    clockTrigger.m_triggerType = (EnumTrigger)m_triggerMode;
    clockTrigger.m_adc_fs_set = m_captureFreq;

    //StoreParam &storeParam = m_pcieCard->getStoreParam();
    //storeParam.m_recordSource = DDCDataSource;

    m_pcieCard->setClockTrigger(clockTrigger);
    //m_pcieCard->setDDC();
}

/******************************************
 * PCIE 预处理参数设置， 必须在采集参数设置之后设置， CPCI无需设置
 * outMode  :输出模式            0=DDC模式(default)   1=ADC模式   2=测试模式
 * chCount  :通道个数设置         1=1通道    2=2通道  3=3通道  4=4通道
 * ddcFreq  :DDC载频            default = 70.000MHz
 * extractFactor:抽取因子        见文档
 * fsbCoe   :Fs/B系数           0=1.25B(default)  1=2.5B
*******************************************/
void DataSource::setPreConditionParam(int outMode, int chCount, double ddcFreq, int extractFactor, int fsbCoef)
{
    Q_UNUSED(outMode)
    if(!m_pcieCard)
        return;
    //EFsBType  type = FS_1_25B;

    DDCParam  &ddcParam = m_pcieCard->getDDC();
    //ddcParam.m_ddc_din_sel   = outMode;
    ddcParam.m_rcd_ch14_sel    = chCount;
    ddcParam.m_recvFreq        = ddcFreq;
    ddcParam.m_ddc_rate        = extractFactor;
    ddcParam.m_ddc_coef_type   = (EFsBType)fsbCoef;
    m_pcieCard->setDDC();

    m_settings->adjustMaxBandWidth();
}


#if 0
void AQN_StreamReader(void *pParam, uchar *pData, uint64 dataLen)
{
    qDebug("add you data deal logic here\n");
    qDebug("here is the dat callback func ,this time data length is :%d \n" ,dataLen);
}
#endif
void storeEndCallback(void *pData, FileStoreStatus status)
{
    DataSource *dataSorece = (DataSource *)pData;
    dataSorece->doStoreEnd(status.m_writedSize);
}
void DataSource::doStoreEnd(quint64 writedLen){
 //   m_pcieCard->stopStore();
    emit storeEnd(QString::number(writedLen));
}
void DataSource::setStorParam(int storeMedia, int nameMode, QString filePath){
    m_storeMedia = storeMedia;
    m_nameMode = nameMode;
    m_filePath = filePath.replace("/","\\");
    if(!m_pcieCard)
        return;

    StoreParam &storeParam = m_pcieCard->getStoreParam();
    storeParam.m_storeMode = (EFixedLengthType)m_captureMode;
    memset(storeParam.m_filePath, 0, sizeof(storeParam.m_filePath));
	m_filePath.toWCharArray(storeParam.m_filePath);
    //m_filePath = storeParam.m_filePath;
    storeParam.m_storeSize = m_captureSize;
    storeParam.m_isStream = false;
	storeParam.m_streamParam = NULL;
    storeParam.m_streamCallback = NULL;//storeParam.m_isStream ? AQN_StreamReader : NULL;
    storeParam.m_stoppedParam = this;
    storeParam.m_stoppedCallback = storeEndCallback;
    storeParam.m_recordSource = DDCDataSource;
}
QString DataSource::getStoreFilePath(){
    return m_filePath;
}
bool DataSource::startStopStore(bool startFlag){
    if(!m_pcieCard)
        return false;
    if(m_isStoring == startFlag)
        return true;

    //check file name
    if(startFlag && m_nameMode == 0){
        bool newFileName = true;
//        if(m_filePath.length()){//判断当前文件名对应文件是否存在，如果文件已经存在，则新建一个
//            QFile file(m_filePath);
//            newFileName = file.exists(); // new filename
//        }
        if(newFileName){//如果是自动命令，不判断文件是否存在，每次都重新创建新文件
            QDateTime curDateTime = QDateTime::currentDateTime();
            QString s_curDateTime = curDateTime.toString("yyyyMMdd_hhmmss");
            if(m_settings->filePath().isEmpty())
                m_filePath = "D:/Store/DDC_Short_Fs_" + s_curDateTime + ".dat";
            else
                m_filePath = m_settings->filePath()+ "/DDC_Short_Fs_" + s_curDateTime + ".dat";
            setStorParam(m_storeMedia, m_nameMode, m_filePath);
        }
    }
    else if(!m_filePath.length())
        return false;

    if(startFlag){
        m_isStoring = m_pcieCard->startStore();
        qDebug()<<"pcieCard startStore()";
        return m_isStoring;
    }
    else{
        m_isStoring = 0;
        qDebug()<<"pcieCard stopStore()";
        m_pcieCard->stopStore();
    }
    return true;
}
int DataSource::getPointIndexByX(qreal x, QAbstractSeries *series)
{

    if(!series)
        return 0;
    QXYSeries *xySeries = static_cast<QXYSeries *>(series);

    QList<QPointF> pointsList  = xySeries->points();

    //m_resolution
    int i=0, idx=0;
    double div = 1;
    double cur_min = 1;
    for(i = 0; i < pointsList.size(); ++i) {
        div = fabs(pointsList.at(i).x()-x);
        if (div < cur_min)
        {
            cur_min  = div;
            idx = i;
        }
        if ( (div > cur_min) && (cur_min < 1) )
            break;
    }
    //qDebug()<<"getPointYByX idx:"<<idx<<"size:"<<pointsList.size();
    return idx;

}
QVector<QPointF> DataSource::getFFTPoints(int ch, int idx)
{
    fftlock.lockForRead();//文件读写锁
    QVector<QPointF> temp;
    temp = m_show_points[ch][idx];
    fftlock.unlock();
    return temp;
}
QVector<double> DataSource::getWaterfallPoints(int ch)
{
    wtflock.lockForRead();
    QVector<double> temp;
    temp = m_waterfall_points[ch];
    wtflock.unlock();
    return temp;
}
void DataSource::settingHandle(Settings *st)
{
    m_settings = st;
}
void DataSource::setFileOffset(QString objname, qreal percent)
{
    filePercent.insert(objname, percent);
    //qDebug()<<"setFileOffset objname:"<<objname<<"percent:"<<percent<<filePercent.value(objname);
}
qreal DataSource::getFileOffset(int idx)
{
    if(0 == idx)
        return filePercent.value("series1");
    else if(1 == idx)
        return filePercent.value("series2");
    else if(2 == idx)
        return filePercent.value("series3");

    return 0.0;
}
bool DataSource::addHistoryFile(QString objname, QString filename)
{

    //qDebug()<<"--------------->addHistoryFile:"<<objname<<"filename:"<<filename;
    QFile *file = new QFile(filename);
    if(!file->open(QIODevice::ReadOnly))
    {
        qDebug()<<"ERR0R: addHistoryFile() Can't open file"<<filename<<endl;
        return false;
    }
    if(0 == file->size())
    {
        file->close();
        return false;
    }
    if(fileMap.contains(objname))
    {
        QFile *f = fileMap.value(objname);
        f->close();
        delete f;
        fileMap.remove(objname);
    }
    fileMap.insert(objname, file);
    return true;
}
bool DataSource::delHistoryFile(QString objname)
{
    if(fileMap.contains(objname))
    {
        QFile *f = fileMap.value(objname);
        f->close();
        delete f;
        fileMap.remove(objname);
    }
    return true;
}
void DataSource::initHistoryFile(void)
{
    if(!m_settings)
        return;
    if(m_settings->historyFile1().length()>0)
    {
        if (false == this->addHistoryFile("series1", m_settings->historyFile1()) )
            m_settings->historyFile1(Settings::Set, "");
    }
    if(m_settings->historyFile2().length()>0)
    {
        if (false == this->addHistoryFile("series2", m_settings->historyFile2()) )
            m_settings->historyFile2(Settings::Set, "");
    }
    if(m_settings->historyFile3().length()>0)
    {
        if (false == this->addHistoryFile("series3", m_settings->historyFile3()) )
            m_settings->historyFile3(Settings::Set, "");
    }

}
bool DataSource::clearHistoryFile(void)
{
    QMap<QString, QFile*>::iterator i = fileMap.begin();
    while (i != fileMap.end()) {
        if(i.value() != nullptr)
        {
            i.value()->close();
            delete i.value();
        }
        ++i;
    }
    qDebug()<<"close history file if exist";
    return true;
}


QFile *DataSource::getFile(QString objname)
{
    if(fileMap.contains(objname))
    {
        QFile *f = fileMap.value(objname);
        return f;
    }
    return nullptr;
}


bool DataSource::startSample()
{
    if(!m_pcieCard)
        return false;
    qDebug()<<"pcie card start sample";
    m_pcieCard->startSample();
    return true;
}
bool DataSource::stopSample()
{
    if(!m_pcieCard)
        return false;
    qDebug()<<"pcie card stop  sample";
    m_pcieCard->stopSample();
    return true;
}

void DataSource::clearFilter(void)
{
    QVector<QVector<QPointF>>::iterator i;
    for (i = filterData.begin(); i != filterData.end(); ++i) {
        i->clear();
    }
    filterData.clear();
}
void DataSource::smooth(QVector<QPointF> &dst_points)
{
    //QVector<QPointF>  data = filterData.
    filterData.append(dst_points);

    int size = filterData.size();

    if(size < 2)
        return;

    if(size > 5)
        filterData.removeFirst();

    int count = dst_points.size();
    dst_points.clear();
    for(int i = 0; i < count; i++){
        qreal y = 0, x = 0;
        for(int j = 0; j < size; j++){
            QVector<QPointF> points = filterData.at(j);
            y += points.at(i).y();
            x += points.at(i).x();
        }
        y = y/size;
        x = x/size;
        dst_points.append( QPointF(x, y));
    }
}
void DataSource::separateData(int ch_count, uchar *source, qint64 size, QVector<QVector<signed short>> &sampdata)
{
    if(nullptr == source || size%2)
        return;

    signed short *pdata = (signed short *)source;
    qint64 total = (size / 2);


    //截取整数
    total = (total/2)/ch_count;
    total = total*ch_count*2;

    if(total<ch_count)
        return;

    for(int ch_idx=0; ch_idx<ch_count; ch_idx++)
    {
        QVector<signed short> vdata;

        for(qint64 idx=0; idx<total;)
        {
            int I = idx+ch_idx*ch_count;
            int Q = I+1;
            vdata.append(pdata[I]);
            vdata.append(pdata[Q]);
            idx = idx+ch_count*2;
        }
        sampdata.append(vdata);
    }
}

void DataSource::cutShowPoint(QVector<QPointF> &source_points, QVector<QPointF> &show_points)
{
    //根据用户配置的参数截取点数
    if(m_bandwidth > 50)
        m_bandwidth = 30;
    int   capture_count = source_points.size();
    int   cut_count     = (50 - m_bandwidth) * capture_count / 50 ;
    int   show_count    = capture_count - cut_count;
    qreal offsetMHz     = 70 - m_centerFreq;
    if(fabs(offsetMHz) >= 25){
        offsetMHz = 0;
        //qDebug()<<"updateFreqDodminFromFile param error 001! ";
    }
    qreal startMHz = 25 - offsetMHz - qreal(m_bandwidth)/2;
    if(startMHz <= 0){
        startMHz = 0;
        //qDebug()<<"updateFreqDodminFromFile param error 002! ";
    }
    //qDebug()<<"startMHz:"<<startMHz<<" offsetMHz:"<<offsetMHz;
    int show_start = capture_count * startMHz / 50;

    //qDebug()<<"cut_count:"<<cut_count<<" show_start:"<<show_start<<" show_count:"<<show_count<<" capture_count:"<<capture_count;


    show_points.reserve(show_count);
    for (int i=0; i < show_count; i++) {
        show_points.append(source_points.at(show_start + i));
    }

    //qDebug()<<" "<<show_points.at(0)<<" "<<show_points.last();
}

void DataSource::workAllPoint(QVector<double> &fftData, QVector<QPointF> &points)
{
    int capture_count = fftData.count();

    qreal x(0), y(0.0);

    points.reserve(capture_count);
    for (int i=0; i < capture_count; i++) {
        x = qreal(45.0) + qreal(50.0) * i / capture_count;//采集卡固定70M中心频率和50M带宽,因此Start = 70-50/2 = 45
        y = fftData[i];
        points.append(QPointF(x, y));
    }
}
void DataSource::freeVVector(QVector<QVector<double>> &vvector)
{
    QVector<QVector<double>>::iterator i;
    for (i = vvector.begin(); i != vvector.end(); ++i) {
        i->clear();
    }
    vvector.clear();
}

int  DataSource::getPointIndexByX(qreal x, QVector<QPointF> &show_points)
{
    int idx = 0, i;
    double div = 1;

    double cur_min = 1;
    for(i = 0; i < show_points.size(); ++i) {
        div = fabs(show_points.at(i).x() - x);
        //qDebug()<<"getPointYByX x:"<<show_points.at(i).x()<<"y:"<<show_points.at(i).y()<<"index:"<<i;
        if (div < cur_min)
        {
            cur_min  = div;
            idx = i;
            //qDebug()<<"getPointYByX x:"<<show_points.at(i).x()<<"y:"<<show_points.at(i).y()<<"index:"<<i;
        }
        if ( (div > cur_min) && (cur_min < 1) )
            break;
    }
    return idx;
}






