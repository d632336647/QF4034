#include "SpectrumData.h"

SpectrumData::SpectrumData(QObject *parent) : QObject(parent)
{
    sidx = 0;
    eidx = 0;
    smin = 0;
    smax = 0;

    m_force_refresh = false;

    refresh_peak[0] = true;
    refresh_peak[1] = true;
    refresh_peak[2] = true;
    m_peak_x[0]   = 0.0;
    m_peak_x[1]   = 0.0;
    m_peak_x[2]   = 0.0;
    m_peakpoint[0] = QPointF(0.0, 0.0);
    m_peakpoint[1] = QPointF(0.0, 0.0);
    m_peakpoint[2] = QPointF(0.0, 0.0);

    m_show_points[0].clear();
    m_show_points[1].clear();
    m_show_points[2].clear();

    channel_idx = 0;
}
int SpectrumData::getChannelIdx(void)
{
    return channel_idx;
}
void SpectrumData::setChannelIdx(int ch)
{
    channel_idx = ch;
    //qDebug()<<"SpectrumData channel_idx:"<<channel_idx;
}
DataSource* SpectrumData::getSource(void)
{
    return data_source;
}
void SpectrumData::setSource(DataSource *ds)
{
    data_source = ds;
    connect(data_source, SIGNAL(updateFFTPoints(int, int)), this, SLOT(refreshSeriesPoints(int, int)) );
    connect(data_source, SIGNAL(forceUpdateSeries(int)),    this, SLOT(setForceRefresh(int)) );
}

QPointF SpectrumData::getPeakPoint0(void)
{
    return m_peakpoint[0];
}
QPointF SpectrumData::getPeakPoint1(void)
{
    return m_peakpoint[1];
}
QPointF SpectrumData::getPeakPoint2(void)
{
    return m_peakpoint[2];
}
QAbstractSeries *SpectrumData::getSeries0(void)
{
    return m_series[0];
}
QAbstractSeries *SpectrumData::getSeries1(void)
{
    return m_series[1];
}
QAbstractSeries *SpectrumData::getSeries2(void)
{
    return m_series[2];
}
void SpectrumData::setSeries0(QAbstractSeries *s)
{
    m_series[0] = s;
}
void SpectrumData::setSeries1(QAbstractSeries *s)
{
    m_series[1] = s;
}
void SpectrumData::setSeries2(QAbstractSeries *s)
{
    m_series[2] = s;
}

void SpectrumData::refreshPeakPoint(int ch, int idx)
{
    if(ch == channel_idx){
        refresh_peak[idx] = true;
    }
}
bool SpectrumData::updateCurMinMax(int ch, double min, double max)
{
    if(ch == channel_idx)
    {
        cur_axis_min = min;
        cur_axis_max = max;
        return true;
    }
    //qreal bandwidth = max - min;
    //int cap_count   = bandwidth * 1000000 / m_resolution ;
    //qDebug()<<"updateCurMinMax min:"<<min<<" max:"<<max;
    return false;
}
void SpectrumData::setCurrentPeakX(int ch, int series_idx, qreal x)
{
    //qDebug()<<"setCurrentPeakX"<<"ch:"<<ch<<"series_idx:"<<series_idx<<"x:"<<x;
    if(ch == channel_idx){
        m_peak_x[series_idx] = x;
    }
}
void SpectrumData::setForceRefresh(int ch)
{
    if(ch == channel_idx){
        sidx = 0;
        eidx = 0;
        smin = 0;
        smax = 0;
        m_force_refresh = true;
    }
}
void SpectrumData::smartUpdateSeries(QAbstractSeries *series)
{

    if(!series){
        qDebug()<<"Error: series is null";
        return;
    }
    if(!series->isVisible())
    {
        //qDebug()<<"Error: series is not visible";
        return;
    }

    int idx = 0;

    if(series->objectName() == "series1")
        idx = 0;
    else if(series->objectName() == "series2")
        idx = 1;
    else if(series->objectName() == "series3")
        idx = 2;

    QVector<QPointF> &t_show_point = m_show_points[idx];

    //qDebug()<<"t_show_point size:"<<t_show_point.size()<<cur_axis_min<<cur_axis_max;
    QXYSeries *xySeries = static_cast<QXYSeries *>(series);

    //获取到起始点和结束点
    if( (smin != cur_axis_min) || (sidx == eidx) || m_force_refresh)
    {
        sidx = getPointIndexByX(cur_axis_min, t_show_point);
        smin = cur_axis_min;
    }
    if( (smax != cur_axis_max) || (sidx == eidx) || m_force_refresh)
    {
        eidx = getPointIndexByX(cur_axis_max, t_show_point);
        smax = cur_axis_max;
    }

    if(m_force_refresh)
        m_force_refresh = false;

    int total = eidx-sidx;
    if(total<=0)
        return;
    //qDebug()<<"sidx:"<<sidx<<" eidx:"<<eidx<<" total:"<<total+1<< "idx:"<<idx<<"refresh_peak:"<<refresh_peak[idx];

    QVector<QPointF> new_show_point;

    new_show_point.clear();

    //从容器中拿出需要显示的点
    for(int i = 0; i<total; i++){
        new_show_point.append(t_show_point.at(i+sidx));
    }

    //peak点处理
    if(refresh_peak[idx])
    {
        QPointF max_point(0.0, -200);
        QPointF point( 0.0, -200);
        int i = 0;
        foreach (point, new_show_point) {
            if(point.y() > max_point.y())
            {
                max_point  = point;
                m_peak_x[idx] = point.x();
            }
            i++;
        }
        m_peakpoint[idx] = max_point;
        emit peakPointChanged(idx);
        refresh_peak[idx] = false;
    }else if(m_peak_x[idx] >= cur_axis_min && m_peak_x[idx] <= cur_axis_max){
        int peak_idx = getPointIndexByX(m_peak_x[idx], new_show_point);
        m_peakpoint[idx] = new_show_point.at(peak_idx);
        emit peakPointChanged(idx);
    }

    xySeries->replace(new_show_point);
    //qDebug()<<"m_peakpoint:"<<m_peakpoint[idx]<<"idx:"<<idx;

}


int SpectrumData::getPointIndexByX(qreal x, QAbstractSeries *series)
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

int SpectrumData::getPointIndexByX(qreal x, QVector<QPointF> &show_points)
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

void SpectrumData::refreshSeriesPoints(int ch, int idx)
{
    if(ch == channel_idx){
        //qDebug()<<"refreshSeriesPoints: series:"<<m_series[idx]<<"ch:"<<ch<<"channel_idx:"<<channel_idx<<"idx:"<<idx;
        m_show_points[idx].clear();
        m_show_points[idx] = data_source->getFFTPoints(ch, idx);
        if(!m_show_points[idx].isEmpty())
            this->smartUpdateSeries(m_series[idx]);
    }
}





