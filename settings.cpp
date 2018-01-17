#include "settings.h"

Settings::Settings(QObject *parent) : QObject(parent)
{
    //采集参数
    initArray(clk_mode,     1);    //时钟模式  0=外时钟     1=内时钟    2=外参考
    initArray(trigger_mode, 1);    //触发模式  0=外部触发   1=内部触发
    initArray(capture_mode, 0);    //采集模式  0=即采即停   1=时长采集   2=大小采集    3=分段采集
    initArray(capture_size, 300);  //采集大小   默认300秒(时长采集)   大小采集时，单位为MB
    initArray(capture_rate, 100);  //采样率， 单位MHz

    //分析参数
    initArray(analyze_mode, 0);      //分析模式   0=实时频谱  1=实时瀑图  2=历史频谱对比  3=历史瀑布  4=历史时域

    //initArray(center_freq,  70.000); //中心频率  单位MHz
    center_freq[0] = 70.000;
    center_freq[1] = 14.000;

    //initArray(bandwidth,    25.000); //观测带宽  单位MHz
    bandwidth[0] = 25.000;
    bandwidth[1] = 50.000;

    initArray(resolution,   10000);  //分编率  单位Hz
    initArray(reflevel_min, -120);   //参考电平最小值 -120
    initArray(reflevel_max, 10);     //参考电平最大值 10

    //存储参数
    save_mode    = 0;     //存储模式    0=内部存储    1=外部存储
    name_mode    = 0;     //命名模式    0=自动       1=手动输入
    path         = "D:/Store"; //存储路径
    history1     = "";//历史文件路径1
    history2     = "";//历史文件路径2
    history3     = "";//历史文件路径3


    //暂时未用的参数
    mark_range      = -10;
    freq_resolution = 1;
    source_mode     = 0;


    //通道设置
    channel_mode = 1;  //通道模式  0 =双通道  1=通道1   2=通道2
    current_ch   = 0;  //当前设置参数的通道    0=通道1   1=通道2

    _settings = new QSettings("settings.ini", QSettings::IniFormat);
    _settings->setIniCodec("UTF8");

    _view = (QQuickView *)parent;
}
Settings::~Settings()
{
    delete _settings;
}


int Settings::clkMode(option op, int val, int ch)
{
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
    if(ch>=MAXCH)
        ch = current_ch;
    if(op == Settings::Set){
        capture_rate[ch] = val;
        _settings->beginGroup(keyString("capture", ch));
        _settings->setValue("capture_rate", capture_rate[ch]);
        _settings->endGroup();
    }
    return capture_rate[ch];
}



int Settings::analyzeMode(option op,int val,  int ch)
{
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
        if(0 == ch){
            if(val>84.5)
                val = 84.5;
            if(val<55.5)
                val = 55.5;
            qreal right = 85 - val;
            qreal left  = val - 55;
            qreal maxbw = (right>left ? left :right)*2;

            if( bandwidth[ch] > maxbw )
            {
                this->bandWidth(Settings::Set, maxbw);
            }
        }
        else{

        }
        center_freq[ch] = val;
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
        //参数校正
        if(0 == current_ch){
            qreal right = 85 - center_freq[ch];
            qreal left  = center_freq[ch] - 55;
            qreal maxbw = (right>left ? left :right)*2;
            if( val > maxbw )
                val = maxbw;

            if( val > 30 )
                val = 30;

            int min_res = val * 10;
            if( val > 3 )
                min_res = val * 40;
            if( val > 10 )
                min_res = val * 80;
            if( val > 15 )
                min_res = val * 100;

            //只限定实时模式
            //if( analyze_mode < 2)
            {
                if(resolution[ch] != min_res)
                    resolutionSize(Settings::Set, min_res);
            }
        }
        else{

        }
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







