#ifndef TYPEDEF_H
#define TYPEDEF_H

#include <string>
#include <iostream>
#include <Windows.h>

#include "wdc_lib.h"
#include "samples/shared/pci_regs.h"
#include "samples/shared/bits.h"
#include "wdc_defs.h"

using namespace std;

typedef unsigned char byte;
typedef unsigned char uchar;
typedef unsigned short ushort;
typedef unsigned int uint;
typedef unsigned long ulong;
typedef unsigned __int64 uint64;  /* 64 bit unsigned */

#define ISBITSET(num,bit)		(((num)>>(bit))&0x1)
#define ISBITCLR(num,bit)		(0==(((num)>>(bit))&0x1))
#define SETBIT(num,bit)  		((num) |=(1<<(bit)))
#define CLRBIT(num,bit)   		((num) &=(~(1<<(bit))))
#define REVERTBIT(num,bit)		{if(ISBITSET((num),(bit))){CLRBIT((num),(bit));}else{SETBIT((num),(bit));}}
#define GETBIT(num,bit)		(((num)>>(bit))&0x1)
#define SETBITVAL(num,bit,val)	{if(val){SETBIT((num),(bit));}else{CLRBIT((num),(bit));}}


typedef struct {
	WDC_DEVICE_HANDLE hDev;
	int vendorID;
	int deviceID;
	bool enabled;
	int cardID;
	int mainType;
	int subType;
	int cardVer;
	int verDate;
	void *cardHandle;
}PCI_DEVICE_INFO;


#define LOG_LEVEL_NULL 0
#define LOG_LEVEL_QUIET    1
#define LOG_LEVEL_PANIC     2
#define LOG_LEVEL_FATAL     3
#define LOG_LEVEL_ERROR    4
#define LOG_LEVEL_WARNING  5
#define LOG_LEVEL_INFO	6
#define LOG_LEVEL_VERBOSE  7
#define LOG_LEVEL_DEBUG    8
#define LOG_LEVEL_MAX    9
typedef void(*LogCallback) (void *pParam, int level, const wchar_t *logMsg);


#define PCIE_CARD 1

#ifdef PCIECARD_EXPORTS
#define PCIECARD_API __declspec(dllexport)
#else
#define PCIECARD_API __declspec(dllimport)
#endif

#endif // TYPEDEF_H