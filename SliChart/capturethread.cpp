#include "capturethread.h"

CaptureThread::CaptureThread(DataSource *ds)
{
    run_state = false;
    data_source = ds;

    waterfall = nullptr;
    series = nullptr;
}

void CaptureThread::setSeries(QAbstractSeries *s)
{
    qDebug()<<"CaptureThread setSeries";
    series = s;
}

void CaptureThread::startCapture(void)
{
    run_state  = true;
}
void CaptureThread::stopCapture(void)
{
    run_state = false;
}
bool CaptureThread::isRunning(void)
{
    return run_state;
}
void CaptureThread::exit(void)
{
    requestInterruption();
    this->quit();
    this->wait();
}

void CaptureThread::run()
{

    //QPointF DataSource::updateFreqDodminFromData(QAbstractSeries *series)
    while(!isInterruptionRequested())
    {
        usleep(100*1000);
        //sleep(1);
        if(run_state)
        {
            data_source->updateFreqDodminFromData(series);
            //qDebug()<<"Capture running";
        }
    }
}
