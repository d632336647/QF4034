/****************************************************************************
**
**
****************************************************************************/

#ifndef CHARTCTRL_H
#define CHARTCTRL_H

#include <QtCore/QObject>
#include <QtCharts/QAbstractSeries>
#include <QtCharts/QScatterSeries>
#include <QPainterPath>
#include <QPainter>

QT_BEGIN_NAMESPACE
class QQuickView;
QT_END_NAMESPACE

QT_CHARTS_USE_NAMESPACE

class ChartCtrl : public QObject
{
    Q_OBJECT
public:
    explicit ChartCtrl(QQuickView *appViewer, QObject *parent = 0);

Q_SIGNALS:

public slots:
    void generateData(int type, int rowCount, int colCount);
    void update(QAbstractSeries *series);


    void setAxisGridLinePenStyle(QAbstractAxis *axis,   Qt::PenStyle style);
    void setLineSeriesPenWidth(QAbstractSeries *series, int width);

    void setScatterPointStyle(QScatterSeries *series, QColor color, int w, int h);


private:
    QQuickView *m_appViewer;
    QList<QVector<QPointF> > m_data;
    int m_index;
};

#endif // CHARTCTRL_H

