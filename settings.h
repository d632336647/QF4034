#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QSettings>
#include <QVariant>
#include <QQuickView>
#include <QQuickItem>


#define MAXCH (2)
#define SAME  (0)

class Settings : public QObject
{
    Q_OBJECT
    Q_ENUMS(option)
public:
    explicit Settings(QObject *parent = nullptr);
    ~Settings();
    enum option{
        Set = 0,
        Get = 1,
    };

    Q_INVOKABLE void save(void);
    Q_INVOKABLE void load(void);

    Q_INVOKABLE int   clkMode(option     op=Get, int   val=0, int ch=MAXCH);
    Q_INVOKABLE int   triggerMode(option op=Get, int   val=0, int ch=MAXCH);
    Q_INVOKABLE int   captureMode(option op=Get, int   val=0, int ch=MAXCH);
    Q_INVOKABLE int   captureSize(option op=Get, int   val=0, int ch=MAXCH);
    Q_INVOKABLE qreal captureRate(option op=Get, qreal val=0, int ch=MAXCH);

    Q_INVOKABLE int   analyzeMode(option op=Get, int   val=0, int ch=MAXCH);
    Q_INVOKABLE qreal centerFreq(option  op=Get, qreal val=0, int ch=MAXCH);
    Q_INVOKABLE qreal bandWidth(option   op=Get, qreal val=0, int ch=MAXCH);
    Q_INVOKABLE int   resolutionSize(option op=Get,int val=0, int ch=MAXCH);
    Q_INVOKABLE int   fftPoints(option op=Get,     int val=0, int ch=MAXCH);
    Q_INVOKABLE qreal reflevelMin(option op=Get, qreal val=0, int ch=MAXCH);
    Q_INVOKABLE qreal reflevelMax(option op=Get, qreal val=0, int ch=MAXCH);

    Q_INVOKABLE int   outMode(option op=Get, int val=0);
    Q_INVOKABLE int   chCount(option op=Get, int val=0);
    Q_INVOKABLE qreal ddcFreq(option op=Get, qreal val=0);
    Q_INVOKABLE int   extractFactor(option op=Get, int val=0);
    Q_INVOKABLE int   fsbCoef(option op=Get, int val=0);
    Q_INVOKABLE qreal baseBandwidth(option op=Get, qreal val=0);
    Q_INVOKABLE qreal userBandwidth(option op=Get, qreal val=0);
    Q_INVOKABLE qreal adSample(option op=Get, qreal val=0);

    Q_INVOKABLE int   saveMode(option op=Get, int val=0);
    Q_INVOKABLE int   nameMode(option op=Get, int val=0);
    Q_INVOKABLE QString filePath(option op=Get, QString val="");
    Q_INVOKABLE QString historyFile1(option op=Get, QString val="");
    Q_INVOKABLE QString historyFile2(option op=Get, QString val="");
    Q_INVOKABLE QString historyFile3(option op=Get, QString val="");


    Q_INVOKABLE int markRange(option op=Get, int val=0);
    Q_INVOKABLE int freqResolution(option op=Get, int val=0);
    Q_INVOKABLE int sourceMode(option op=Get, int val=0);

    Q_INVOKABLE int channelMode(option op=Get, int val=0);
    Q_INVOKABLE int paramsSetCh(option op=Get, int val=0);

    Q_INVOKABLE QQuickItem *findQuickItem(QString objctName);
    QString keyString(QString group, int ch=-1);
    void    initArray(int   array[], int   val);
    void    initArray(qreal array[], qreal val);
    qreal   adjustMaxBandWidth(void);
signals:

public slots:

private:
    int     clk_mode[MAXCH];
    int     trigger_mode[MAXCH];
    int     capture_mode[MAXCH];
    int     capture_size[MAXCH];
    qreal   capture_rate[MAXCH];

    int     analyze_mode[MAXCH];
    qreal   center_freq[MAXCH];
    qreal   bandwidth[MAXCH];
    int     resolution[MAXCH];
    int     fftpoints[MAXCH];
    qreal   reflevel_min[MAXCH];
    qreal   reflevel_max[MAXCH];


    int     save_mode;
    int     name_mode;
    QString path;
    QString history1;
    QString history2;
    QString history3;

    //预处理参数
    int out_mode;
    int ch_count;
    qreal ddc_freq;
    int extract_factor;
    int fsb_coef;
    qreal base_bandwidth;
    qreal user_bandwidth;
    qreal ad_sample;

    int     mark_range;
    int     freq_resolution;
    int     source_mode;

    int     channel_mode;
    int     current_ch;



    QSettings  *_settings;
    QQuickView *_view;
};

#endif // SETTINGS_H
