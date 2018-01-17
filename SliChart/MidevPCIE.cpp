#include "MidevPCIE.h"

MidevPCIE::MidevPCIE()
{
    m_pcieCard = NULL;
    m_pciDev = new PciDeviceAPI("spectrumAnalyzer", 0x1556, 0x1100);
    m_pciDev->scanCard();
    PcieCard *pcieObj = (PcieCard*)m_pciDev->getCard(1);
    if(pcieObj){
        m_pcieCard = new PcieCardAPI(pcieObj);
        PCI_DEVICE_INFO *cardInfo = m_pcieCard->cardInfo();
        qDebug() <<"CardInfo---" <<cardInfo->mainType<<cardInfo->subType;
        qDebug("CardInfo--- %#x %#x\n",cardInfo->vendorID, cardInfo->deviceID);
        if(m_pcieCard->selfCheck())
        {
            qDebug() <<"Pcie card softReset---" <<m_pcieCard->softReset();
            qDebug() <<"Pcie card hardReset---" <<m_pcieCard->hardReset();
            //qDebug() <<"Pcie card allReset---" << m_pcieCard->allReset();
        }
        else
        {
            qDebug() <<"Card selfcheck fail";
            m_pcieCard = NULL;
        }
    }
    else
    {
        qDebug() <<"Card Init Failed!";
        m_pcieCard = NULL;
    }

}
MidevPCIE::~MidevPCIE()
{
    if(m_pciDev)
    {
        qDebug()<<"delete pcie driver";
        delete m_pciDev;
    }
    if(m_pcieCard)
    {
        qDebug()<<"delete pcie card";
        delete m_pcieCard;
    }
}

bool MidevPCIE::startSample(void)
{
    if(!m_pcieCard)
        return false;
    qDebug()<<"pcie card start sample";
    m_pcieCard->startSample();
    return true;
}
bool MidevPCIE::stopSample(void)
{
    if(!m_pcieCard)
        return false;
    qDebug()<<"pcie card stop  sample";
    m_pcieCard->stopSample();
    return true;
}

void MidevPCIE::setStorParam(int storeMedia, int nameMode, QString filePath){
    m_storeMedia = storeMedia;
    m_nameMode = nameMode;
    m_filePath = filePath.replace("/","\\");
    if(!m_pcieCard)
        return;

    StoreParam &storeParam = m_pcieCard->getStoreParam();
    storeParam.m_storeMode = (EFixedLengthType)m_captureMode;
    memset(storeParam.m_filePath, 0, sizeof(storeParam.m_filePath));
    m_filePath.toWCharArray(storeParam.m_filePath);
    //m_filePath = storeParam.m_filePath;
    storeParam.m_storeSize = m_captureSize;
    storeParam.m_isStream = false;
    storeParam.m_streamParam = NULL;
    storeParam.m_streamCallback = NULL;//storeParam.m_isStream ? AQN_StreamReader : NULL;
    storeParam.m_stoppedParam = this;
    storeParam.m_stoppedCallback = NULL;
    storeParam.m_recordSource = DDCDataSource;
}
QString MidevPCIE::getStoreFilePath(){
    return m_filePath;
}
bool MidevPCIE::startStopStore(bool startFlag){
    if(!m_pcieCard)
        return false;
    if(m_isStoring == startFlag)
        return true;

    //check file name
    if(startFlag && m_nameMode == 0){
        bool newFileName = true;
//        if(m_filePath.length()){//判断当前文件名对应文件是否存在，如果文件已经存在，则新建一个
//            QFile file(m_filePath);
//            newFileName = file.exists(); // new filename
//        }
        if(newFileName){//如果是自动命令，不判断文件是否存在，每次都重新创建新文件
            QDateTime curDateTime = QDateTime::currentDateTime();
            QString s_curDateTime = curDateTime.toString("yyyyMMdd_hhmmss");
            //if(m_settings->filePath().isEmpty())
                m_filePath = "D:/Store/DDC_Short_Fs_" + s_curDateTime + ".dat";
            //else
            //    m_filePath = m_settings->filePath()+ "/DDC_Short_Fs_" + s_curDateTime + ".dat";
            setStorParam(m_storeMedia, m_nameMode, m_filePath);
        }
    }
    else if(!m_filePath.length())
        return false;

    if(startFlag){
        m_isStoring = m_pcieCard->startStore();
        qDebug()<<"pcieCard startStore()";
        return m_isStoring;
    }
    else{
        m_isStoring = 0;
        qDebug()<<"pcieCard stopStore()";
        m_pcieCard->stopStore();
    }
    return true;
}
void MidevPCIE::setCaptureParam(int clkMode, double captureFreq, int triggerMode, int captureMode, int captureSize){
    if(!m_pcieCard)
        return;
    if( captureFreq <40 || captureFreq > 250 )
    {
        qDebug()<< "输入频率无效.\n范围:[40-250]";
        return ;
    }
    m_clkMode = clkMode;
    m_captureFreq = captureFreq;
    m_triggerMode = triggerMode;
    m_captureMode = captureMode;
    m_captureSize = captureSize;
    ClockTrigger clockTrigger;
    clockTrigger.m_clockType = (EnumClock)m_clkMode;
    clockTrigger.m_triggerType = (EnumTrigger)m_triggerMode;
    clockTrigger.m_adc_fs_set = m_captureFreq;

    //StoreParam &storeParam = m_pcieCard->getStoreParam();
    //storeParam.m_recordSource = DDCDataSource;

    m_pcieCard->setClockTrigger(clockTrigger);
    //m_pcieCard->setDDC();
}

/******************************************var outMode = 0;
 * PCIE 预处理参数设置， 必须在采集参数设置之后设置， CPCI无需设置
 * outMode  :输出模式            0=DDC模式(default)   1=ADC模式   2=测试模式
 * chCount  :通道个数设置         1=1通道    2=2通道  3=3通道  4=4通道
 * ddcFreq  :DDC载频             default = 70.000MHz
 * extractFactor:抽取因子        见文档
 * fsbCoe   :Fs/B系数           0=1.25B(default)  1=2.5B
*******************************************/
void MidevPCIE::setPreConditionParam(int outMode, int chCount, double ddcFreq, int extractFactor, int fsbCoef)
{
    Q_UNUSED(outMode)
    if(!m_pcieCard)
        return;
    //EFsBType  type = FS_1_25B;

    DDCParam  ddcParam = m_pcieCard->getDDC();
    //ddcParam.m_ddc_din_sel   = outMode;
    ddcParam.m_rcd_ch14_sel    = chCount;
    ddcParam.m_recvFreq        = ddcFreq;
    ddcParam.m_ddc_rate        = extractFactor;
    ddcParam.m_ddc_coef_type   = (EFsBType)fsbCoef;
    m_pcieCard->setDDC();
}


