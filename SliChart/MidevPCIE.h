#ifndef MIDEVPCIE_H
#define MIDEVPCIE_H
#include <QObject>
#include <QDebug>
#include <QDateTime>
#include "pcieCardAPI.h"
#include "pciDeviceAPI.h"

class MidevPCIE : public QObject
{
    Q_OBJECT

public:
    MidevPCIE();
    ~MidevPCIE();

    bool stopSample(void);
    bool startSample(void);

    //采集参数
    void setCaptureParam(int clkMode, double captureRate, int triggerMode, int captureMode, int captureSize);

    //预处理参数,必须在采集参数设置后设置预处理参数(PCIE)  CPCI无此设置
    void setPreConditionParam(int outMode, int chCount, double ddcFreq, int extractFactor, int fsbCoef);

    //存储参数
    void setStorParam(int saveMode, int nameMode, QString filePath);
    QString getStoreFilePath();
    bool startStopStore(bool startFlag);

private:
    //pcie device
    PciDeviceAPI *m_pciDev;
    PcieCardAPI  *m_pcieCard;


    //采集参数
    int m_clkMode;
    double m_captureFreq;
    int m_triggerMode;
    int m_captureMode;
    int m_captureSize;  //存储文件大小或者时长

    //储存设置
    int m_storeMedia; //0: 内部存储  1: 外部存储
    int m_nameMode; //0: 自动命名  1: 手动命名
    QString m_filePath;
    bool m_isStoring;  //0: 停止.  1:正在采集
};

#endif // MIDEVPCIE_H
