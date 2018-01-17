#include "WaveInfo.h"


/*
 * WaveInfo
*/
void WaveInfo::reset()
{
    m_points.clear();
    m_dx.clear();
    m_dy.clear();
}
WaveInfo::WaveInfo()
{

}
WaveInfo::WaveInfo(QXYSeries *xySeries, QVector<QPointF> points)
{
    m_xySeries = xySeries;
    m_points = points;
    m_dx.reserve(m_points.count());
    m_dy.reserve(m_points.count());
    foreach (QPointF point, m_points) {
        m_dx.append(point.x());
        m_dy.append(point.y());
    }

    QVector<qreal> dyShort = m_dy;
    qSort(dyShort.begin(), dyShort.end());

    m_xMin = m_dx.first();
    m_xMax = m_dx.last();
    m_yMin = dyShort.first();
    m_yMax = dyShort.last();
    m_peakPoint.setX(m_dx.at(m_dy.indexOf(m_yMax)));
    m_peakPoint.setY(m_yMax);
//    qDebug("WaveInfo: min: (%f, %f).    max(%f, %f", m_xMin, m_yMin, m_xMax, m_yMax);
}
WaveInfo::~WaveInfo()
{
    reset();
}
