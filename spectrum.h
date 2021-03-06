#ifndef SPECTRUM_H
#define SPECTRUM_H

#include <QtCore/QObject>
#include <QLibrary>
#include <QDateTime>
#include <QFile>
//********************************************************************************************//
//函数功能：计算一个信号向量的频谱，支持实信号和复信号
//作者：
//接口说明：
//----signed short* Data_Input：输入信号数据，实信号顺次存储，复信号存储格式为Ipp16sc格式
//----double* Data_Output：输出幅度谱数据，内存空间由外部定义，内存空间大小：复数为输入数据长度的一半，实数与输入数据长度一致
//----__int64 nDatalen：输入数据Data_Input的长度，复数的情况下该数值为信号点数的两倍
//----int flag：输入信号的类型，0表示复数，1表示实数
//********************************************************************************************//
typedef bool (*DLL_API_SpectrumCalc)(signed short* Data_Input, double* Data_Output, __int64 nFFT_Size, int flag);


class Spectrum
{
public:
    Spectrum();
    ~Spectrum();

    bool fftFromData(signed short *dataIn, int fftInCount, QVector<double> &pData);
    bool fftFromData(signed short *dataIn, double *&dataOut, int fftInCount, int &fftOutCount);

    bool fftFromFile(QFile *pf, qint64 fftInCount, qreal percent, QVector<double> &pData);
    bool fftFromFile(QString fileName, double *&dataOut, int fftInCount, int &fftOutCount);

private:
    QLibrary fftLib;
    DLL_API_SpectrumCalc specCalc;

};


#endif // SPECTRUM_H
