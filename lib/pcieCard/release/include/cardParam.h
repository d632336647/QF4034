#ifndef CARDPARAM_H
#define CARDPARAM_H

#include "wdc_lib.h"
#include "typedef.h"
#include "cardStatus.h"

enum EFixedLengthType   //工作模式
{
    UnlimitedType,					//无限模式
    TimeFixedType,					//时间定长模式
    SizeFixedType,					//大小定长模式
};
enum EFsBType   //滤波器类型
{
    FS_1_25B = 0,
    FS_2_5B = 1,
};
enum EDataSourceType    //数据源类型
{
    DDCDataSource  = 0x0,						//DDC源
    TestDataSource = 0x1,						//测试源
    ADCDataSource  = 0x2,						//ADC源
};
enum EnumTrigger	//触发模式
{
    EnumTrigger_OutSide,	//外触发
    EnumTrigger_InSide,		//内触发
};
enum EnumClock		//时钟
{
    EnumClock_OutSide,	//外时钟
    EnumClock_Inner,	//内时钟
	EnumClock_OutRef,	//外参考
    EnumClock_DDS,		//dds
};
struct ClockTrigger{
    EnumClock m_clockType;	//时钟
    EnumTrigger m_triggerType;	//触发
	double m_adc_fs_set;    //adc采样率设置	
    ClockTrigger(){
        m_clockType = EnumClock_Inner;
        m_triggerType = EnumTrigger_InSide;
		m_adc_fs_set = 200;		
    }
};
struct DDCParam{
    int m_sig_cen_freq_sel;     //中频信号中心频率选择
    int m_rcd_ch14_sel;        // 通道模式；1:1通道；2:2通道；3：3通道；4:4通道
    int m_ddc_din_sel;      //ddc输入选择
    double m_recvFreq;		// ddc接收载频,单位MHz,默认值为70
    uint m_adc_dds_fin;     //dds频率控制字
    int m_ddc_rate;         //ddc抽取率	
    EFsBType m_ddc_coef_type;    //ddc系数类型

    int m_cfir_coef_count;  //CFIR系数
    int *m_cfir_coef_data;
    int m_lpf2_coef_count;  //PFIR系数
    int *m_lpf2_coef_data;

    DDCParam(){
        m_sig_cen_freq_sel = 0;
        m_rcd_ch14_sel = 1;
        m_ddc_din_sel = 0;

		m_recvFreq = 70.0;
		m_adc_dds_fin = (uint)(m_recvFreq / 200 * pow(2, 32));	// 200 === m_adcFs
        m_ddc_rate = 4;//2;
        m_ddc_coef_type = FS_1_25B;

        m_cfir_coef_count = 0;
		m_cfir_coef_data = new int[1024];
        m_lpf2_coef_count = 0;
		m_lpf2_coef_data = new int[1024];
    }
	~DDCParam(){
		delete[] m_cfir_coef_data;
		delete[] m_lpf2_coef_data;
	}
};
struct StoreParam{
    EFixedLengthType m_storeMode;
    double m_storeSize;						//时长采集是的时间长度（单位为秒），定长采集时的文件大小（MB）
	wchar_t m_filePath[MAX_PATH];			// 文件路径
	bool m_IQSplite;
	bool m_channelSplite;
    EDataSourceType m_recordSource;  //数据源选择
	bool m_isStream;									//是否基于流的方式
	void *m_streamParam;
	void(*m_streamCallback)(void *pParam, uchar *pData, uint64 dataLen);
	void *m_stoppedParam;
	void(*m_stoppedCallback)(void *pParam, FileStoreStatus status);

    StoreParam(){
        m_storeMode = SizeFixedType;
        m_storeSize = 10.0;        
		swprintf_s(m_filePath, L"E:\\Store\\test.dat");
		m_IQSplite = false;
		m_channelSplite = false;
		m_recordSource = DDCDataSource;
		m_isStream = false;
		m_streamParam = NULL;
		m_streamCallback = NULL;
		m_stoppedParam = NULL;
		m_stoppedCallback = NULL;
    }
};

struct CardParam{
    ClockTrigger m_clkTrigger;
    DDCParam m_ddc;
    StoreParam m_store;
};

#endif // CARDPARAM_H
