#ifndef CARDSTATUS_H
#define CARDSTATUS_H

#include "wdc_lib.h"
#include "typedef.h"

struct CardStatus
{
	int DDR3_A;	// 表示DDR3_A初始化状态
	int DDR3_B;	//表示DDR3_B初始化状态
	int AD9520;	//表示AD9520锁定状态
};

struct FileStoreStatus{
	uint64 m_needSize;			/* 需要存储总大小 */
	uint64 m_writedSize;		/* 实际存储大小 */
	uint64 m_left;				/* 剩余大小 */
	double m_timePass;			/* 耗时 */
	double m_speed;				/* 速度 */
};

struct DAMStatus{
	uint64 m_dmaBufferSize;		/* DMA每次传输大小 */
	uint64 m_dmaNeedTransCount;	/* DMA需要的总次数 */
	uint64 m_dmaTransedCount;		/* DMA实际传输次数 */
	uint64 m_dmaTansTotalSize;	/* DMA实际传输总大小 */
	double m_timePass;			/* DMA当前传输时间 */
	double m_speed;				/* 速度MB/Sec. */
};

#endif
