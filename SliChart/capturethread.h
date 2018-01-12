#ifndef CAPTURETHREAD_H
#define CAPTURETHREAD_H

#include <QObject>
#include <QThread>
#include <QDebug>
#include <QByteArray>
#include <QString>
#include <QtCharts/QAbstractSeries>
#include <QtCharts/QScatterSeries>
#include <QtCharts/QXYSeries>
#include "spectrum.h"
#include "waterfallplot.h"
#include "datasource.h"

QT_BEGIN_NAMESPACE
class QQuickView;
QT_END_NAMESPACE

QT_CHARTS_USE_NAMESPACE



class CaptureThread : public QThread
{
    Q_OBJECT
public:
    CaptureThread(DataSource *ds);

    Q_INVOKABLE void setSeries(QAbstractSeries *s);
    Q_INVOKABLE void startCapture(void);
    Q_INVOKABLE void stopCapture(void);
    Q_INVOKABLE bool isRunning(void);
public slots:
    void exit(void);
private:
    void run();
    bool run_state;
    QAbstractSeries *series;
    DataSource *data_source;
    WaterfallPlot *waterfall;
};

#endif // CAPTURETHREAD_H
