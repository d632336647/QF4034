#ifndef PCIDEVICEAPI_H
#define PCIDEVICEAPI_H

#include "typedef.h"

class PciDevice;

class PCIECARD_API PciDeviceAPI{
public:
	PciDeviceAPI(const char *appName, uint vendorID = 0x10B5, uint deviceID = 0x9656);
	~PciDeviceAPI();

	void* getCard(int cardID);
        int   scanCard();
        void  setLogMsgCallback(LogCallback callback, void *pParam);

private:
	PciDevice *m_pciDev;
};

#endif
