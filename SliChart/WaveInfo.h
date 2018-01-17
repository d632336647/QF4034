#ifndef WAVEINFO_H
#define WAVEINFO_H
#include <QObject>
#include <QtCharts/QAbstractSeries>
#include <QtCharts/QScatterSeries>
#include <QtCharts/QXYSeries>
#include <QReadWriteLock>
#include <QFile>

QT_BEGIN_NAMESPACE
class QQuickView;
QT_END_NAMESPACE

QT_CHARTS_USE_NAMESPACE

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

#endif // WAVEINFO_H
