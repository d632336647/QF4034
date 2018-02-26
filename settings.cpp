#include "settings.h"

Settings::Settings(QObject *parent) : QObject(parent)
{
    defaultParam();
    _settings = new QSettings("settings.ini", QSettings::IniFormat);
    _settings->setIniCodec("UTF8");

    _view = (QQuickView *)parent;
}
Settings::~Settings()
{
    delete _settings;
}
void Settings::defaultParam(void)
{
    //采集参数
    initArray(clk_mode,     1);    //时钟模式  0=外时钟     1=内时钟    2=外参考
    initArray(trigger_mode, 1);    //触发模式  0=外部触发   1=内部触发
    initArray(capture_mode, 0);    //采集模式  0=即采即停   1=时长采集   2=大小采集    3=分段采集
    initArray(capture_size, 300);  //采集大小   默认300秒(时长采集)   大小采集时，单位为MB
    initArray(capture_rate, 100);  //采样率， 单位MHz

    //分析参数
    initArray(analyze_mode, 0);      //分析模式   0=实时频谱  1=实时瀑图  2=历史频谱对比  3=历史瀑布  4=历史时域

    initArray(center_freq,  70.000); //中心频率  单位MHz
    //center_freq[0] = 70.000;
    //center_freq[1] = 70.000;

    initArray(bandwidth,    12.000); //观测带宽  单位MHz
    //bandwidth[0] = 12.000;
    //bandwidth[1] = 12.000;

    initArray(resolution,   10000);  //分编率  单位Hz ，即将停止使用此参数，改为fft点数代替
    initArray(fftpoints,    10000);  //fft点数
    initArray(reflevel_min, -120);   //参考电平最小值 -120
    initArray(reflevel_max, 10);     //参考电平最大值 10

    //存储参数
    save_mode    = 0;     //存储模式    0=内部存储    1=外部存储
    name_mode    = 0;     //命名模式    0=自动       1=手动输入
    path         = "D:/Store"; //存储路径
    history1     = "";//历史文件路径1
    history2     = "";//历史文件路径2
    history3     = "";//历史文件路径3

    //预处理参数
    out_mode = 0;        //输出模式            0=DDC模式(default)   1=ADC模式   2=测试模式
    ch_count = 2;        //通道个数设置         1=1通道    2=2通道  3=3通道  4=4通道
    ddc_freq = 70;       //DDC载频            default = 70.000MHz ,目前只有70和140 两个值
    extract_factor = 4;  //抽取因子           见文档
    fsb_coef = 0;        //Fs/B系数           0=1.25B(default)  1=2.5B
    base_bandwidth = 25.0;// 当前预处理参数下,内部计算实际的最大带宽值,如果要改变此参数,需要停止采集数据后再设置
    user_bandwidth = 20.0;// 当前预处理参数下,允许用户设置的最大带宽,如果要改变此参数,需要停止采集数据后再设置
    ad_sample = 100.0;    //AD采样率,目前只有100和200 两个值

    //暂时未用的参数
    mark_range      = -10;
    freq_resolution = 1;
    source_mode     = 0;


    //通道设置
    channel_mode = 0;  //通道模式  0 =双通道  1=通道1   2=通道2
    current_ch   = 0;  //当前设置参数的通道    0=通道1   1=通道2
}

int Settings::clkMode(option op, int val, int ch)
{
    Q_UNUSED(ch)
    //此参数所有通道一致
    if(op == Settings::Set){
        clk_mode[SAME] = val;
        _settings->beginGroup(keyString("capture", SAME));
        _settings->setValue("clk_mode",  clk_mode[SAME]);
        _settings->endGroup();
    }
    return clk_mode[SAME];
}
int Settings::triggerMode(option op, int val, int ch)
{
    Q_UNUSED(ch)
    //此参数所有通道一致
    if(op == Settings::Set){
        trigger_mode[SAME] = val;
        _settings->beginGroup(keyString("capture", SAME));
        _settings->setValue("trigger_mode", trigger_mode[SAME]);
        _settings->endGroup();
    }
    return trigger_mode[SAME];
}
int Settings::captureMode(option op, int val, int ch)
{
    Q_UNUSED(ch)
    //此参数所有通道一致
    if(op == Settings::Set){
        capture_mode[SAME] = val;
        _settings->beginGroup(keyString("capture", SAME));
        _settings->setValue("capture_mode", capture_mode[SAME]);
        _settings->endGroup();
    }
    return capture_mode[SAME];
}
int Settings::captureSize(option op, int val, int ch)
{
    Q_UNUSED(ch)
    //此参数所有通道一致
    if(op == Settings::Set){
        capture_size[SAME] = val;
        _settings->beginGroup(keyString("capture", SAME));
        _settings->setValue("capture_size", capture_size[SAME]);
        _settings->endGroup();
    }
    return capture_size[SAME];
}
qreal Settings::captureRate(option op, qreal val, int ch)
{
    Q_UNUSED(ch)
    //此参数所有通道一致
    if(op == Settings::Set){
        capture_rate[SAME] = val;
        _settings->beginGroup(keyString("capture", SAME));
        _settings->setValue("capture_rate", capture_rate[SAME]);
        _settings->endGroup();
    }
    return capture_rate[SAME];
}



int Settings::analyzeMode(option op,int val,  int ch)
{
    Q_UNUSED(ch)
    //此参数所有通道一致
    //qDebug()<<"analyzeMode op:"<<op<<"ch:"<<ch<<"val:"<<val;
    if(op == Settings::Set){
        analyze_mode[SAME] = val;
        _settings->beginGroup(keyString("analyze", SAME));
        _settings->setValue("analyze_mode", analyze_mode[SAME]);
        _settings->endGroup();
    }
    return analyze_mode[SAME];
}
qreal Settings::centerFreq(option op, qreal val, int ch)
{
    if(ch>=MAXCH)
        ch = current_ch;
    if(op == Settings::Set){
        //参数校正
        qreal max = (ddc_freq + user_bandwidth/2);
        qreal min = (ddc_freq - user_bandwidth/2);

        qreal offset = user_bandwidth*0.1;

        if(val > (max - offset) )
            val = max - offset;
        if(val < (min + offset) )
            val = min + offset;

        qreal right = max - val;
        qreal left  = val - min;

        qreal maxbw = (right>left ? left :right)*2;

        center_freq[ch] = val;

        this->bandWidth(Settings::Set, maxbw);

        _settings->beginGroup(keyString("analyze", ch));
        _settings->setValue("center_freq", center_freq[ch]);
        _settings->endGroup();
    }
    return center_freq[ch];
}
qreal Settings::bandWidth(option op, qreal val, int ch)
{
    if(ch>=MAXCH)
        ch = current_ch;
    if(op == Settings::Set){
        if(val > user_bandwidth)
            val = user_bandwidth;
        //参数校正
        qreal max = (ddc_freq + user_bandwidth/2);
        qreal maxbw = (max - center_freq[ch])*2;
        if(val > maxbw)
           val = maxbw;

        //fix to %.2f
        qint64 ival = (qint64)(val * 100);
        val = (qreal)ival/100;

        bandwidth[ch] = val;
        _settings->beginGroup(keyString("analyze", ch));
        _settings->setValue("bandwidth", bandwidth[ch]);
        _settings->endGroup();

    }
    return bandwidth[ch];
}
int Settings::resolutionSize(option op, int val, int ch)
{
    if(ch>=MAXCH)
        ch = current_ch;
    if(op == Settings::Set){
        if(0 == current_ch){
            int min_res = bandwidth[ch] * 10;
            if( bandwidth[ch] > 3 )
                min_res = bandwidth[ch] * 40;
            if( bandwidth[ch] > 10 )
                min_res = bandwidth[ch] * 80;
            if( bandwidth[ch] > 15 )
                min_res = bandwidth[ch] * 100;

            if(val < min_res)
                val = min_res;
            if( val < 30 )
                val = 30;
        }
        else{

        }
        resolution[ch] = val;
        _settings->beginGroup(keyString("analyze", ch));
        _settings->setValue("resolution", resolution[ch]);
        _settings->endGroup();
    }
    return resolution[ch];
}
int Settings::fftPoints(option op, int val, int ch)
{
    Q_UNUSED(ch)
    //此参数所有通道一致
    if(op == Settings::Set){
        fftpoints[SAME] = val;
        _settings->beginGroup(keyString("analyze", SAME));
        _settings->setValue("fftpoints", fftpoints[SAME]);
        _settings->endGroup();
    }
    return fftpoints[SAME];
}
qreal Settings::reflevelMin(option op, qreal val, int ch)
{
    //qDebug()<<"reflevelMin op:"<<((op == Settings::Set)?"set":"get")<<"val:"<<val<<"ch:"<<ch;
    if(ch>=MAXCH)
        ch = current_ch;
    if(op == Settings::Set){
        if( val > reflevel_max[ch] )
            return reflevel_min[ch];
        reflevel_min[ch] = val;
        _settings->beginGroup(keyString("analyze", ch));
        _settings->setValue("reflevel_min", reflevel_min[ch]);
        _settings->endGroup();
    }
    //qDebug()<<"reflevel_min[ch]:"<<reflevel_min[ch]<<"ch:"<<ch;
    return reflevel_min[ch];
}
qreal Settings::reflevelMax(option op, qreal val, int ch)
{
    if(ch>=MAXCH)
        ch = current_ch;
    if(op == Settings::Set){
        if( val < reflevel_min[ch] )
            return reflevel_max[ch];
        reflevel_max[ch] = val;
        _settings->beginGroup(keyString("analyze", ch));
        _settings->setValue("reflevel_max", reflevel_max[ch]);
        _settings->endGroup();
    }
    return reflevel_max[ch];
}


int Settings::outMode(option op, int val)
{
    if(op == Settings::Set){
        out_mode = val;
        _settings->setValue("pre/out_mode", out_mode);
    }
    return out_mode;
}
int Settings::chCount(option op, int val)
{
    if(op == Settings::Set){
        ch_count = val;
        _settings->setValue("pre/ch_count", ch_count);
    }
    return ch_count;
}
qreal Settings::ddcFreq(option op, qreal val)
{
    if(op == Settings::Set){
        ddc_freq = val;
        this->centerFreq(Settings::Set, val);
        _settings->setValue("pre/ddc_freq", ddc_freq);
    }
    return ddc_freq;
}
int Settings::extractFactor(option op, int val)
{
    if(op == Settings::Set){
        extract_factor = val;
        _settings->setValue("pre/extract_factor", extract_factor);
    }
    return extract_factor;
}
int Settings::fsbCoef(option op, int val)
{
    if(op == Settings::Set){
        fsb_coef = val;
        _settings->setValue("pre/fsb_coef", fsb_coef);
    }
    return fsb_coef;
}
qreal Settings::baseBandwidth(option op, qreal val)
{
    if(op == Settings::Set){
        base_bandwidth = val;
        _settings->setValue("pre/base_bandwidth", base_bandwidth);
    }
    return base_bandwidth;
}
qreal Settings::userBandwidth(option op, qreal val)
{
    if(op == Settings::Set){
        user_bandwidth = val;
        _settings->setValue("pre/user_bandwidth", user_bandwidth);
    }
    return user_bandwidth;
}
qreal Settings::adSample(option op, qreal val)
{
    if(op == Settings::Set){
        ad_sample = val;
        _settings->setValue("pre/ad_sample", ad_sample);
    }
    return ad_sample;
}


int Settings::saveMode(option op, int val)
{
    if(op == Settings::Set){
        save_mode = val;
        _settings->setValue("store/save_mode", save_mode);
    }
    return save_mode;
}
int Settings::nameMode(option op, int val)
{
    if(op == Settings::Set){
        name_mode = val;
        _settings->setValue("store/name_mode", name_mode);
    }
    return name_mode;
}
QString Settings::filePath(option op, QString val)
{
    if(op == Settings::Set){
        path = val;
        _settings->setValue("store/path", path);
    }
    return path;
}
QString Settings::historyFile1(option op, QString val)
{
    if(op == Settings::Set){
        history1 = val;
        _settings->setValue("store/history1", history1);
    }
    return history1;
}
QString Settings::historyFile2(option op, QString val)
{
    if(op == Settings::Set){
        history2 = val;
        _settings->setValue("store/history2", history2);
    }
    return history2;
}
QString Settings::historyFile3(option op, QString val)
{
    if(op == Settings::Set){
        history3 = val;
        _settings->setValue("store/history3", history3);
    }
    return history3;
}

int Settings::markRange(option op, int val)
{
    if(op == Settings::Set){
        mark_range = val;
        _settings->setValue("other/mark_range", mark_range);
    }
    return mark_range;
}
int Settings::freqResolution(option op, int val)
{
    if(op == Settings::Set){
        freq_resolution = val;
        _settings->setValue("other/freq_resolution", freq_resolution);
    }
    return freq_resolution;
}
int Settings::sourceMode(option op, int val)
{
    if(op == Settings::Set){
        source_mode = val;
        _settings->setValue("other/source_mode", source_mode);
    }
    return source_mode;
}
int Settings::channelMode(option op, int val)
{
    if(op == Settings::Set){
        channel_mode = val;
        _settings->setValue("other/channel_mode", channel_mode);
    }
    return channel_mode;
}
int Settings::paramsSetCh(option op, int val)
{
    if(op == Settings::Set){
        if(val<MAXCH)
            current_ch = val;
        //_settings->setValue("other/channel_mode", channel_mode);
    }
    return current_ch;
}


QQuickItem *Settings::findQuickItem(QString objctName)
{
    if(_view){
        QQuickItem *item = _view->rootObject()->findChild<QQuickItem*>(objctName);
        if(item)
            return item;
    }
    return nullptr;
}
QQuickItem *Settings::findQuickItemFocused(void)
{
    QQuickItem *item = _view->activeFocusItem();
    if(item)
        return item;
    return nullptr;
}
void Settings::executeCommand(QString cmd)
{
    QProcess p(0);
    p.start("cmd", QStringList()<<"/c"<<cmd);
    p.waitForStarted();
    p.waitForFinished();

    //QString strTmp = QString::fromLocal8Bit(p.readAllStandardOutput());
    qDebug()<<"executeCommand:"<<cmd;
}


QString Settings::keyString(QString group, int ch)
{
    QString key;
    if(ch<0)
        key = group;
    else
        key = group+QString::number(ch);
    return key;
}
void Settings::initArray(int   array[], int   val)
{
    for(int i=0; i<MAXCH; i++)
    {
        array[i] = val;
    }
}
void Settings::initArray(qreal array[], qreal val)
{
    for(int i=0; i<MAXCH; i++)
    {
        array[i] = val;
    }
}


bool Settings::adjustMaxBandWidth(void)
{
    bool rtn = false;
    //DDC Freq=70   Fs/B=1.25  AD Sample = 100M
    if(ddc_freq == 70 && fsb_coef==0 && ad_sample == 100)
    {
        base_bandwidth = ad_sample/extract_factor;
        if(2 == extract_factor)
            user_bandwidth = 36;
        else
            user_bandwidth = base_bandwidth * 0.8;
    }
    if(ddc_freq == 140 && fsb_coef==0 && ad_sample == 200)
    {
        base_bandwidth = ad_sample/extract_factor;
        if(2 == extract_factor)
            user_bandwidth = 72;
        else
            user_bandwidth = base_bandwidth * 0.8;
    }

    for(int ch=0; ch<MAXCH; ch++){
        if(user_bandwidth != bandwidth[ch])
        {
            bandwidth[ch] = user_bandwidth;
            rtn = true;
        }
    }
    return rtn;
}

void Settings::save(void)
{
    for(int ch=0; ch<MAXCH; ch++){
        _settings->beginGroup(keyString("capture", ch));
        _settings->setValue("clk_mode",     clk_mode[ch]);
        _settings->setValue("trigger_mode", trigger_mode[ch]);
        _settings->setValue("capture_mode", capture_mode[ch]);
        _settings->setValue("capture_size", capture_size[ch]);
        _settings->setValue("capture_rate", capture_rate[ch]);
        _settings->endGroup();
    }

    for(int ch=0; ch<MAXCH; ch++){
        _settings->beginGroup(keyString("analyze", ch));
        _settings->setValue("analyze_mode", analyze_mode[ch]);
        _settings->setValue("center_freq",  center_freq[ch]);
        _settings->setValue("bandwidth",    bandwidth[ch]);
        _settings->setValue("resolution",   resolution[ch]);
        _settings->setValue("reflevel_min", reflevel_min[ch]);
        _settings->setValue("reflevel_max", reflevel_max[ch]);
        _settings->endGroup();
    }

    //预处理参数
    _settings->setValue("pre/out_mode",        out_mode);
    _settings->setValue("pre/ch_count",        ch_count);
    _settings->setValue("pre/ddc_freq",        ddc_freq);
    _settings->setValue("pre/extract_factor",  extract_factor);
    _settings->setValue("pre/fsb_coef",        fsb_coef);
    _settings->setValue("pre/base_bandwidth",  base_bandwidth);
    _settings->setValue("pre/user_bandwidth",  user_bandwidth);
    _settings->setValue("pre/ad_sample",       ad_sample);

    _settings->setValue("store/save_mode",      save_mode);
    _settings->setValue("store/name_mode",      name_mode);
    _settings->setValue("store/path",           path);
    _settings->setValue("store/history1",       history1);
    _settings->setValue("store/history2",       history2);
    _settings->setValue("store/history3",       history3);

    _settings->setValue("other/mark_range",     mark_range);
    _settings->setValue("other/freq_resolution",freq_resolution);
    _settings->setValue("other/source_mode",    source_mode);
    _settings->setValue("other/channel_mode",   channel_mode);
}
void Settings::load(void)
{
    bool ok;
    int tempi;
    qreal tempf;

    for(int ch=0; ch<MAXCH; ch++)
    {
        _settings->beginGroup(keyString("capture", ch));
        tempi = _settings->value("clk_mode").toInt(&ok);
        if(ok)clk_mode[ch] = tempi;

        tempi = _settings->value("trigger_mode").toInt(&ok);
        if(ok)trigger_mode[ch] = tempi;

        tempi = _settings->value("capture_mode").toInt(&ok);
        if(ok)capture_mode[ch] = tempi;

        tempi = _settings->value("capture_size").toInt(&ok);
        if(ok)capture_size[ch] = tempi;

        tempf = _settings->value("capture_rate").toReal(&ok);
        if(ok)capture_rate[ch] = tempf;
        _settings->endGroup();
    }

    //-----------------------------------------------------------
    for(int ch=0; ch<MAXCH; ch++)
    {
         _settings->beginGroup(keyString("analyze", ch));
        tempi = _settings->value("analyze_mode").toInt(&ok);
        if(ok)analyze_mode[ch] = tempi;

        tempf = _settings->value("center_freq").toReal(&ok);
        if(ok)center_freq[ch] = tempf;

        tempf = _settings->value("bandwidth").toReal(&ok);
        if(ok)bandwidth[ch] = tempf;

        tempi = _settings->value("resolution").toInt(&ok);
        if(ok)resolution[ch] = tempi;

        tempf = _settings->value("reflevel_min").toReal(&ok);
        if(ok)reflevel_min[ch] = tempf;

        tempf = _settings->value("reflevel_max").toReal(&ok);
        if(ok)reflevel_max[ch] = tempf;
        _settings->endGroup();
    }


    //-----------------------------------------------------------
    tempi = _settings->value("pre/out_mode").toInt(&ok);
    if(ok)out_mode = tempi;
    tempi = _settings->value("pre/ch_count").toInt(&ok);
    if(ok)ch_count = tempi;
    tempf = _settings->value("pre/ddc_freq").toReal(&ok);
    if(ok)ddc_freq = tempf;
    tempi = _settings->value("pre/extract_factor").toInt(&ok);
    if(ok)extract_factor = tempi;
    tempi = _settings->value("pre/fsb_coef").toInt(&ok);
    if(ok)fsb_coef = tempi;
    tempf = _settings->value("pre/base_bandwidth").toReal(&ok);
    if(ok)base_bandwidth = tempf;
    tempf = _settings->value("pre/user_bandwidth").toReal(&ok);
    if(ok)user_bandwidth = tempf;
    tempf = _settings->value("pre/ad_sample").toReal(&ok);
    if(ok)ad_sample = tempf;
    tempi = _settings->value("store/save_mode").toInt(&ok);
    if(ok)save_mode = tempi;

    tempi = _settings->value("store/name_mode").toInt(&ok);
    if(ok)name_mode = tempi;

    path     = _settings->value("store/path").toString();
    history1 = _settings->value("store/history1").toString();
    history2 = _settings->value("store/history2").toString();
    history3 = _settings->value("store/history3").toString();

    //-----------------------------------------------------------
    tempi = _settings->value("other/mark_range").toInt(&ok);
    if(ok)mark_range = tempi;

    tempi = _settings->value("other/freq_resolution").toInt(&ok);
    if(ok)freq_resolution = tempi;

    tempi = _settings->value("other/source_mode").toInt(&ok);
    if(ok)source_mode = tempi;

    tempi = _settings->value("other/channel_mode").toInt(&ok);
    if(ok)channel_mode = tempi;

}
void Settings::loadDefault(void)
{
    QString t_path         = path;
    QString t_history1     = history1;
    QString t_history2     = history2;
    QString t_history3     = history3;
    defaultParam();
    path         = t_path;
    history1     = t_history1;
    history2     = t_history2;
    history3     = t_history3;
}



