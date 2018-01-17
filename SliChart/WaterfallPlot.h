#ifndef WATERFALLPLOT_H
#define WATERFALLPLOT_H

#include <QtCore/QObject>
#include <QQuickPaintedItem>
#include <QPainterPath>
#include <QPainter>
#include <QPointF>
#include <QImage>
#include <QPen>
#include <QBrush>
#include <QColor>
#include <QQuickPaintedItem>
#include <QDebug>
#include <QReadWriteLock>
#include <QtCharts/QAbstractSeries>
#include <QtCharts/QScatterSeries>

#include "spectrum.h"
#include "DataSource.h"
#include "settings.h"

QT_BEGIN_NAMESPACE
class QQuickView;
QT_END_NAMESPACE

QT_CHARTS_USE_NAMESPACE

class WaterfallPlot: public QQuickPaintedItem{
    Q_OBJECT

    Q_PROPERTY(double referMax    READ  referMax      WRITE setReferMax)
    Q_PROPERTY(double referMin    READ  referMin      WRITE setReferMin)
    Q_PROPERTY(double minHPixel   READ  minHPixel     WRITE setMinHPixel)
    Q_PROPERTY(int    lineCount   READ  getlineCount  WRITE setlineCount   NOTIFY lineCountChanged())

    Q_PROPERTY(int     channelIdx READ  getChannelIdx WRITE setChannelIdx  NOTIFY channelIdxChanged())
    Q_PROPERTY(DataSource* source READ  getSource     WRITE setSource      NOTIFY sourceChanged())

public:

    WaterfallPlot(QQuickItem *parent = 0);
    ~WaterfallPlot();


    void paint(QPainter *painter);
    QRgb calcColor(float val);
    QRgb getColor(float val);
    void initRgbMap();

    int minHPixel();
    void setMinHPixel(int count);
    double referMax();
    double referMin();
    void setReferMax(double val);
    void setReferMin(double val);
    int  updateData(qreal bandwidth, qreal centerFreq, QVector<double> &dataLine);
    void updateDataRT(QVector<QPointF> &dataLine);
    void clearPixelColor(void);

    int  getChannelIdx(void);
    void setChannelIdx(int ch);
    int  getlineCount(void);
    void setlineCount(int count);
    DataSource* getSource(void);
    void setSource(DataSource *ds);

    Q_INVOKABLE void zoomHorizontal(float min, float max, float cur);
    Q_INVOKABLE void zoomReset(void);
    Q_INVOKABLE void setRtMode(void);
    Q_INVOKABLE void setFileMode(void);
    Q_INVOKABLE void safeUpdate(void);
    Q_INVOKABLE void updateRefLebel(float min, float max);
    Q_INVOKABLE void setAxisXData(float cur_min, float cur_max, float min, float max);

    Q_INVOKABLE void openWaterfallRtCapture(void);//clearPixelColor
    Q_INVOKABLE void closeWaterfallRtCapture(void);

signals:
    void sourceChanged(void);
    void channelIdxChanged(void);
    void lineCountChanged(void);
public slots:
    void refreshWaterfallData(int ch, int idx);
    void refreshWaterfallFile(int ch, qreal bw, qreal cfreq);
private:

    void cutShowPoint(qreal bandwidth, qreal centerFreq, QVector<double> &source_points, QVector<double> &show_points);

    QPixmap pixmap;
    QVector<QImage> image_lines;


    int m_xCountOrig;
    int m_yCountOrig;
    int m_xCount;
    int m_yCount;
    int m_xStart;
    int m_minHPixel;

    QVector<QRgb> colorPoor;
    double m_referMax;
    double m_referMin;
    double m_referDiv;

    void updateCoefficent();

    QVector<QRgb> rgbMap;
    bool  m_rt_mode;    //实时模式
    int   m_rt_times;   //记录的次数
    float m_max_dbm;
    float m_min_dbm;
    float m_color_step;

    //实时频谱图缩放使用
    float m_cur_axisx_min;
    float m_cur_axisx_max;
    float m_axisx_min;
    float m_axisx_max;

    QReadWriteLock lock;//文件读写锁

    //数据相关
    int  channel_idx;
    int  line_count;
    bool m_refresh;
    DataSource *data_source;


    //参数变量
    Settings *m_settings;
};



#endif // WATERFALLPLOT_H