#ifndef SPECTRUMDATA_H
#define SPECTRUMDATA_H

#include <QtCore/QObject>
#include <QtCharts/QAbstractSeries>
#include <QtCharts/QScatterSeries>

#include "DataSource.h"

QT_BEGIN_NAMESPACE
class QQuickView;
QT_END_NAMESPACE

QT_CHARTS_USE_NAMESPACE
class SpectrumData : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QPointF peakPoint0 READ getPeakPoint0 NOTIFY peakPointChanged(0))
    Q_PROPERTY(QPointF peakPoint1 READ getPeakPoint1 NOTIFY peakPointChanged(1))
    Q_PROPERTY(QPointF peakPoint2 READ getPeakPoint2 NOTIFY peakPointChanged(2))

    Q_PROPERTY(QAbstractSeries *seriesHandle0 READ getSeries0 WRITE setSeries0)
    Q_PROPERTY(QAbstractSeries *seriesHandle1 READ getSeries1 WRITE setSeries1)
    Q_PROPERTY(QAbstractSeries *seriesHandle2 READ getSeries2 WRITE setSeries2)

    Q_PROPERTY(int     channelIdx READ getChannelIdx WRITE  setChannelIdx NOTIFY channelIdxChanged())
    Q_PROPERTY(DataSource* source READ getSource     WRITE  setSource     NOTIFY sourceChanged())
public:
    explicit SpectrumData(QObject *parent = 0);

    //Peak相关
    QPointF getPeakPoint0(void);
    QPointF getPeakPoint1(void);
    QPointF getPeakPoint2(void);

    QAbstractSeries *getSeries0(void);
    QAbstractSeries *getSeries1(void);
    QAbstractSeries *getSeries2(void);
    void setSeries0(QAbstractSeries *s);
    void setSeries1(QAbstractSeries *s);
    void setSeries2(QAbstractSeries *s);

    int     getChannelIdx(void);
    void    setChannelIdx(int ch);

    DataSource* getSource(void);
    void    setSource(DataSource *ds);
signals:
    void    peakPointChanged(int idx);
    void    channelIdxChanged(void);
    void    sourceChanged(void);
public slots:
    void    refreshPeakPoint(int ch, int idx);
    bool    updateCurMinMax(int ch, double min, double max);
    void    setCurrentPeakX(int ch, int series_idx, qreal x);


    void    setForceRefresh(int ch);
    void    smartUpdateSeries(QAbstractSeries *series);//智能抽点显示

    //获取点在容器/Series中的索引, 重载函数
    int     getPointIndexByX(qreal x, QAbstractSeries  *series);
    int     getPointIndexByX(qreal x, QVector<QPointF> &show_points);


    //fft数据相关
    void    refreshSeriesPoints(int ch, int idx);
private:
    int     max_ch;
    int     channel_idx;
    bool    rt_mode;

    //计算mark点及切点参数
    QPointF m_peakpoint[3];
    qreal   m_peak_x[3];
    bool    refresh_peak[3];
    double  cur_axis_min;
    double  cur_axis_max;

    //强制刷新series,用以解决分析参数变更后serise没有立即刷新的问题
    bool    m_force_refresh;

    //暂存数据，0=series1  1=series2  2=series3
    QVector<QPointF> m_show_points[3];

    //截点使用的中间变量
    int    sidx = 0;
    int    eidx = 0;
    double smin = 0;
    double smax = 0;

    //数据相关
    DataSource      *data_source;
    QAbstractSeries *m_series[3];
};

#endif // SPECTRUMDATA_H
