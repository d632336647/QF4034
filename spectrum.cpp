#include <QtCore/QtMath>
#include <QtCore/QDebug>
#include <QFile>
#include <QDir>
#include "spectrum.h"

#if 1
Spectrum::Spectrum()
    : fftLib("")
{
    //E:/QtProject/QF/Release/specShow.dll
    //qDebug()<<QDir::currentPath()+"/specShow.dll";

    fftLib.setFileName("specShow.dll");
    if(!fftLib.load())
    {
        qDebug()<<fftLib.errorString();
        return;
    }
    specCalc = (DLL_API_SpectrumCalc)fftLib.resolve("SpectrumCalc_D2FreqMagn");
    if(!specCalc)
    {
        qDebug() << "Spectrum::Spectrum: specCalc not found";
        return;
    }

}

Spectrum::~Spectrum(){
}

bool Spectrum::fftFromData(signed short *dataIn,int fftInCount, QVector<double> &pData){
    if(fftInCount%2)
        fftInCount -= 1;
    double *fftArray = new double[fftInCount];

    if(!specCalc(dataIn, fftArray, fftInCount, 0))
    {
        qDebug() << "Spectrum::fftFromData: FFT error";
        delete[] fftArray;
        return false;
    }

    for (int i = 0; i < fftInCount; i += 2)
    {
        pData.append(fftArray[i]);
    }

    delete[] fftArray;
    return true;
}
bool Spectrum::fftFromData(signed short *dataIn, double *&dataOut, int fftInCount, int &fftOutCount){
    if(fftInCount%2)
        fftInCount -= 1;
    fftOutCount = fftInCount;
    double *fftArray = new double[fftInCount];
    if(!specCalc(dataIn, fftArray, fftInCount, 0))
    {
        qDebug() << "Spectrum::fftFromData: FFT error";
        delete[] fftArray;
        return false;
    }

    // 10*Math.Log10(取模的平方)
    fftOutCount /= 2;
    dataOut = new double[fftOutCount];
    int index = 0;
    for (int i = 0; i < fftInCount; i += 2)
    {
        dataOut[index++] = 10 * log10(pow(fftArray[i], 2) + pow(fftArray[i + 1], 2));
    }
    delete[] fftArray;
    return true;
}
bool Spectrum::fftFromFile(QString fileName, double *&dataOut, int fftInCount, int &fftOutCount){
    QFile file(fileName);
    if(!file.open(QIODevice::ReadWrite))
    {
        qDebug()<<"Spectrum::fftFromFile:1 Can't open file "<<fileName<<endl;
        return false;
    }
    QByteArray d = file.readAll();
    file.close();

    if(d.size() < fftInCount * 4)
    {
        qDebug() << "Spectrum::fftFromFile: File size error: " << d.size();
        return false;
    }
    return fftFromData((signed short *)d.data(), dataOut, fftInCount, fftOutCount);
}

bool Spectrum::fftFromFile(QFile *pf, qint64 fftInCount, qreal percent, QVector<double> &pData)
{


    if(pf == nullptr)
        return false;

    if(!pf->isOpen())
    {
        qDebug()<<"ERROR:  Spectrum::fftFromFile() file is not open"<<pf->fileName()<<endl;
        return false;
    }
    qint64 point_count = pf->size()/4;
    if(fftInCount%2)
        fftInCount -= 1;

    qint64 start = 0;
    if((point_count-100) >= fftInCount){
        start = point_count - fftInCount;
        start = start * percent;
    }
    else
        fftInCount = point_count;
    //qDebug()<<"Spectrum::fftFromFile: fftInCount:"<<fftInCount<<"point_count:"<<point_count;

    QByteArray d;// = pf->readAll();
    pf->reset();
    pf->seek(start*4);
    d = pf->read(fftInCount*4);

    pData.clear();
    if(!fftFromData((signed short *)(d.data()), fftInCount, pData))
        return false;

    //qDebug()<<"fftFromFile start:"<<start<<" fftInCount:"<<fftInCount<<"point_count:"<<pf->size()/4<<point_count<<"   fftData:"<<fftData.size();

    return true;

}
#endif


