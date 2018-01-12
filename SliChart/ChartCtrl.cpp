/****************************************************************************
****************************************************************************/

#include "ChartCtrl.h"
#include <QtCharts/QXYSeries>
#include <QtCharts/QAreaSeries>
#include <QtQuick/QQuickView>
#include <QtQuick/QQuickItem>
#include <QtCore/QDebug>
#include <QtCore/QtMath>

QT_CHARTS_USE_NAMESPACE

Q_DECLARE_METATYPE(QAbstractSeries *)
Q_DECLARE_METATYPE(QAbstractAxis *)

ChartCtrl::ChartCtrl(QQuickView *appViewer, QObject *parent) :
    QObject(parent),
    m_appViewer(appViewer),
    m_index(-1)
{
    qRegisterMetaType<QAbstractSeries*>();
    qRegisterMetaType<QAbstractAxis*>();

    generateData(0, 5, 1024);
}

void ChartCtrl::update(QAbstractSeries *series)
{
    if (series) {
        QXYSeries *xySeries = static_cast<QXYSeries *>(series);
        m_index++;
        if (m_index > m_data.count() - 1)
            m_index = 0;

        QVector<QPointF> points = m_data.at(m_index);
        // Use replace instead of clear + append, it's optimized for performance
        xySeries->replace(points);
    }
}


void ChartCtrl::setAxisGridLinePenStyle(QAbstractAxis *axis, Qt::PenStyle style)
{
    if (axis) {
        QPen pen=axis->gridLinePen();
        pen.setStyle(style);//Qt::DotLine
        axis->setGridLinePen(pen);
    }
}
void ChartCtrl::setLineSeriesPenWidth(QAbstractSeries *series, int width)
{
    if (series) {
        QXYSeries *xySeries = static_cast<QXYSeries *>(series);
        if(xySeries){
            QPen pen = xySeries->pen();
            pen.setWidth(width);
            xySeries->setPen(pen);
        }
    }
}

void ChartCtrl::setScatterPointStyle(QScatterSeries* series, QColor color, int w, int h)
{
    if (series) {
        int max_l = (w>h)?w:h;
        series->setMarkerSize(max_l);
        QPainterPath starPath;
        if(w > h)
            starPath.addRect(0, (w-h)/2, w, h);
        else
            starPath.addRect((h-w)/2, 0, w, h);
        starPath.closeSubpath();

        QImage wrect(max_l, max_l, QImage::Format_ARGB32);
        wrect.fill(Qt::transparent);

        QPainter painter(&wrect);
        //painter.setRenderHint(QPainter::Antialiasing);
        painter.setPen(color);
        painter.setBrush(painter.pen().color());
        painter.drawPath(starPath);

        series->setBrush(wrect);

        //series->setPen(QColor(Qt::red));
    }
}



void ChartCtrl::generateData(int type, int rowCount, int colCount)
{
    // Remove previous data
    m_data.clear();

    // Append the new data depending on the type
    for (int i(0); i < rowCount; i++) {
        QVector<QPointF> points;
        points.reserve(colCount);
        for (int j(0); j < colCount; j++) {
            qreal x(0);
            qreal y(0);
            switch (type) {
            case 0:
                // data with sin + random component
                y = qSin(3.14159265358979 / 50 * j) + 0.5 + (qreal) rand() / (qreal) RAND_MAX;
                x = j;
                break;
            case 1:
                // linear data
                x = j;
                y = (qreal) i / 10;
                break;
            default:
                // unknown, do nothing
                break;
            }
            points.append(QPointF(x, y));
        }
        m_data.append(points);
    }
}
