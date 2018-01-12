#ifndef PCIECARDAPI_H
#define PCIECARDAPI_H

#include "typedef.h"
#include "cardparam.h"
#include "cardStatus.h"

class PcieCard;
class PCIECARD_API PcieCardAPI {
public:
	PcieCardAPI(PcieCard *pcieCard);
	~PcieCardAPI();

	PCI_DEVICE_INFO *cardInfo();

	bool softReset();
	bool hardReset();
	bool selfCheck();

	bool testBarAddr(int barIndex, int addrOffset, int val);
	bool testBarAddrRang(int barIndex, int addrOffset, int regCount, int randFlag);

	ClockTrigger& getClockTrigger();
	void setClockTrigger(ClockTrigger clockTrigger);

	DDCParam& getDDC();
	void setDDC();

	StoreParam &getStoreParam();
	bool startStore();
	bool stopStore();
	bool isStoring();
	
	void startSample();
	void stopSample();
	int getSampleData(uchar *dataBuf, int dataLen);

	void getCardStatus(CardStatus& status);
	void getStoreStatus(FileStoreStatus& status);
	void getDMAStatus(DAMStatus& status);

private:
	PcieCard *m_pcieCard;
};

#endif