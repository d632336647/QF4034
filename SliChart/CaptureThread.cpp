#include "CaptureThread.h"

CaptureThread::CaptureThread(DataSource *ds)
{
    run_state = false;
    data_source = ds;
    waterfall = nullptr;
}

void CaptureThread::startCapture(void)
{
    if(!isRunning())
    {
        pause.lock();
        run_state  = true;
        pause.unlock();
        qDebug()<<"start capture thread";
    }
}
void CaptureThread::stopCapture(void)
{
    if(isRunning())
    {
        pause.lock();
        run_state = false;
        pause.unlock();
        qDebug()<<"stop  capture thread";
    }
}
bool CaptureThread::isRunning(void)
{
    return run_state;
}
void CaptureThread::exit(void)
{
    this->stopCapture();
    qDebug()<<"exit  capture thread";
    requestInterruption();
    this->quit();
    this->wait();
}

void CaptureThread::run()
{
    //QPointF DataSource::updateFreqDodminFromData(QAbstractSeries *series)
    while(!isInterruptionRequested())
    {
        pause.lock();
        if(run_state){
            data_source->updateFreqDodminFromData();
            //qDebug()<<"Capture running";
            usleep(200*1000);
        }else
            usleep(1);
        pause.unlock();
    }
}
