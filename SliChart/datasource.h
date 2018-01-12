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

#ifndef DATASOURCE_H
#define DATASOURCE_H

#include <QObject>
#include <QtCharts/QAbstractSeries>
#include <QtCharts/QScatterSeries>
#include <QtCharts/QXYSeries>
#include <QReadWriteLock>
#include <QFile>

#include "settings.h"
#include "spectrum.h"
#include "waterfallplot.h"
#include "pcieCardAPI.h"
#include "pciDeviceAPI.h"

QT_BEGIN_NAMESPACE
class QQuickView;
QT_END_NAMESPACE

QT_CHARTS_USE_NAMESPACE

#define NATIVE_DEBUG 1

class WaveInfo
{
public:    
    WaveInfo();
    WaveInfo(QXYSeries *xySeries, QVector<QPointF> points);
    ~WaveInfo();

    void reset();
//    QVector<QPointF> &points();

    QXYSeries *m_xySeries;
    QVector<QPointF> m_points;
    QPointF m_peakPoint;
    QVector<qreal> m_dx;
    QVector<qreal> m_dy;
    qreal m_xMax;
    qreal m_xMin;
    qreal m_yMax;
    qreal m_yMin;
};
class DataSource : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QPointF peakPoint0 READ getPeakPoint0() NOTIFY peakPointChanged(0))
    Q_PROPERTY(QPointF peakPoint1 READ getPeakPoint1() NOTIFY peakPointChanged(1))
    Q_PROPERTY(QPointF peakPoint2 READ getPeakPoint2() NOTIFY peakPointChanged(2))

public:
    explicit DataSource(QObject *parent = 0, Settings *st = nullptr);
    ~DataSource();
    void doStoreEnd(quint64 writedLen);

    void settingHandle(Settings *st);

signals:
    void storeEnd(QString writedLen);
    void peakPointChanged(int idx);
Q_SIGNALS:

public slots:
    void changeAxis(QAbstractAxis *axis);

    //分析参数--fft
    void updateFreqDodminFromData(QAbstractSeries *series);
    void updateFreqDodminFromFile(QAbstractSeries *series, QString fileName);
    void setFFTParam(double centerFreq, double bandwidth, int resolution);
    int  getWaterfallLineCount(QString fileName);
    void openWaterfallRtCapture(WaterfallPlot *wf);
    void closeWaterfallRtCapture(void);
    int  updateWaterfallPlotFromFile(WaterfallPlot *waterfallPlot, QString fileName);
    void updateTimeDomainFromFile(QAbstractSeries *series1, QAbstractSeries *series2, QString fileName);
    QPointF getWaveInfoBottomLeft(QAbstractSeries *series);
    QPointF getWaveInfoTopRight(QAbstractSeries *series);

    //采集参数
    void setCaptureParam(int clkMode, double captureRate, int triggerMode, int captureMode, int captureSize);

    //预处理参数,必须在采集参数设置后设置预处理参数(PCIE)  CPCI无此设置
    void setPreConditionParam(int outMode, int chCount, double ddcFreq, int extractFactor, int fsbCoef);

    //存储参数
    void setStorParam(int saveMode, int nameMode, QString filePath);
    QString getStoreFilePath();
    bool startStopStore(bool startFlag);    

    //获取点在容器/Series中的索引, 重载函数
    int getPointIndexByX(qreal x, QAbstractSeries  *series);
    int getPointIndexByX(qreal x, QVector<QPointF> &show_points);

    bool startSample();
    bool stopSample();

    QPointF getPeakPoint0(void);
    QPointF getPeakPoint1(void);
    QPointF getPeakPoint2(void);
    void    refreshPeakPoint(int idx);
    bool    updateCurMinMax(double min, double max);
    void    setCurrentPeakX(int series_idx, qreal x);


    void    setForceRefresh(void);
    //智能抽点显示
    void    smartUpdateSeries(QAbstractSeries *series);

    //历史文件相关函数
    void    setFileOffset(QString objname, qreal percent);
    qreal   getFileOffset(int idx);
    bool    addHistoryFile(QString objname, QString filename);
    bool    delHistoryFile(QString objname);
    void    initHistoryFile(void);
    bool    clearHistoryFile(void);

    void    clearFilter(void);
private:
    void cutShowPoint(QVector<QPointF> &source_points, QVector<QPointF> &show_points);
    void workAllPoint(QVector<double> &fftData, QVector<QPointF> &points);
    void freeVVector(QVector<QVector<double>> &vvector);
    QFile *getFile(QString objname);
    void smooth(QVector<QPointF> &dst_points);


    //计算mark点及切点参数
    QPointF maxPoint;
    QPointF m_peakpoint[3];
    qreal   m_peak_x[3];
    bool    refresh_peak[3];
    double  cur_axis_min;
    double  cur_axis_max;


    //pcie device
    PciDeviceAPI *m_pciDev;
    PcieCardAPI  *m_pcieCard;



    //采集参数
    int m_clkMode;
    double m_captureFreq;
    int m_triggerMode;
    int m_captureMode;
    int m_captureSize;  //存储文件大小或者时长

    //瀑布图采集的相关参数
    bool m_start_wf;
    WaterfallPlot *m_waterfall;
    int m_wf_fps;


    //分析参数--fft
    QVector<WaveInfo> m_waveInfo;
    int m_fftCount;
    double m_centerFreq;//MHz
    double m_bandwidth;//MHz
    int m_resolution;//Hz
    Spectrum m_spectrum;
    bool m_force_refresh;//强制刷新series,用以解决分析参数变更后serise没有立即刷新的问题

    //储存设置    
    int m_storeMedia; //0: 内部存储  1: 外部存储
    int m_nameMode; //0: 自动命名  1: 手动命名
    QString m_filePath;
    bool m_isStoring;  //0: 停止.  1:正在采集

    QReadWriteLock lock;//文件读写锁

    QVector<QPointF> m_show_points[3];//暂存数据，0=series1  1=series2  2=series3

    //历史文件分析相关参数
    QMap<QString, QFile*>    fileMap;
    QMap<QString, qreal>     filePercent;//filePercent.value(series->objectName());


    //参数变量
    Settings *m_settings;

    //滑动滤波
    QVector<QVector<QPointF>> filterData;
};

#endif // DATASOURCE_H
