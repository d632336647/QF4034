#include "WaterfallPlot.h"

WaterfallPlot::WaterfallPlot(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
    int i;
    QRgb color;

    colorPoor.reserve(1024);
    for(i=0; i< 1024; i++)
    {
        if(i<0x100)
            color = 0xff0000ff + (i << 8);
        else if(i<0x200)
            color = 0xff00ffff - (i & 0xff);
        else if(i<0x300)
            color = 0xff00ff00 + ((i & 0xff) << 16);
        else
            color = 0xffffff00 - ((i & 0xff) << 8);
        colorPoor.append(color);
    }
    m_referMax = 150;
    m_referMin = 90;
    updateCoefficent();

    m_xCountOrig = 0;
    m_yCountOrig = 0;
    m_xCount = 0;
    m_yCount = 0;
    m_xStart = 0;
    m_minHPixel = 20;

    initRgbMap();
    m_rt_times = 50;
    m_rt_mode = false;

    channel_idx = 0;
    m_refresh = false;
}
WaterfallPlot::~WaterfallPlot(){

}
void WaterfallPlot::updateCoefficent(){
    if(m_referMax > m_referMin)
        m_referDiv = colorPoor.count() * 1.0 / (m_referMax - m_referMin);
    else
        m_referDiv = 1;
}
double WaterfallPlot::referMax(){
    return m_referMax;
}
double WaterfallPlot::referMin(){
    return m_referMin;
}
void WaterfallPlot::setReferMax(double val){
    if(val >= m_referMin)
    {
        m_referMax = val;
        updateCoefficent();
    }
}
void WaterfallPlot::setReferMin(double val){
    if(val <= m_referMax)
    {
        m_referMin = val;
        updateCoefficent();
    }
}
int WaterfallPlot::getChannelIdx(void)
{
    return channel_idx;
}
void WaterfallPlot::setChannelIdx(int ch)
{
    channel_idx = ch;
}
int  WaterfallPlot::getlineCount(void)
{
    return line_count;
}
void WaterfallPlot::setlineCount(int count)
{
    line_count = count;
}
int WaterfallPlot::minHPixel(){
    return m_minHPixel;
}
void WaterfallPlot::setMinHPixel(int count){
    if(count)
        m_minHPixel = count;
}
DataSource* WaterfallPlot::getSource(void)
{
    return data_source;
}
void WaterfallPlot::setSource(DataSource *ds)
{
    data_source = ds;
    connect(data_source, SIGNAL(updateFFTPoints(int, int)), this, SLOT(refreshWaterfallData(int, int)) );
    connect(data_source, SIGNAL(updateWaterfallFile(int, qreal, qreal)),  this, SLOT(refreshWaterfallFile(int, qreal, qreal)) );
}

/*
 * RGB    0,   0, 250
 *
 *        0, 250, 250
 *
 *        0, 250,   0
 *
 *      250, 250,   0
 *
 *      250,   0,   0
*/
void WaterfallPlot::initRgbMap()
{
    QColor color;
    rgbMap.clear();
#if 0
    for(int idx=0; idx<=1000; idx++){
        if(idx <= 250)
            color.setRgb(0, idx, 250);
        else if(idx <= 500)
            color.setRgb(0, 250, 500-idx);
        else if(idx <= 750)
            color.setRgb(idx-500, 250,  0);
        else
            color.setRgb(250, 1000-idx, 0);
        rgbMap.append(color.rgb());
    }
#else
    QImage   color_img(1000, 10, QImage::Format_RGB888);
    QPainter painter(&color_img);


    QLinearGradient linearGradient(QPointF(0, 0), QPointF(1000, 0));
    linearGradient.setColorAt(0.00, QColor("#000090"));
    linearGradient.setColorAt(0.25, QColor("#2A5FFF"));
    linearGradient.setColorAt(0.50, QColor("#7FFE84"));
    linearGradient.setColorAt(0.75, QColor("#FFB302"));
    linearGradient.setColorAt(1.00, QColor("#FF0000"));

    QBrush brush(linearGradient);
    painter.setBrush(brush);
    painter.drawRect(QRect(0, 0, 1000, 10));

    for(int idx=0; idx<1000; idx++){
        rgbMap.append(color_img.pixel(idx, 1));
    }

    //color_img.save("color_img.bmp");

#endif
    m_max_dbm = 10.0;
    m_min_dbm = -120.0;
    m_color_step = (m_max_dbm - m_min_dbm) / 1000;
}
QRgb WaterfallPlot::getColor(float val)
{
    QColor color;

    int idx = (val-m_min_dbm)/m_color_step;

    //qDebug()<<"idx:"<<idx<<"val:"<<val<<"step:"<<step;

    if(idx < 1)
        return rgbMap.at(1);
    else if(idx>999)
        return rgbMap.at(999);
    else
        return rgbMap.at(idx);

    return rgbMap.first();
}
QRgb WaterfallPlot::calcColor(float val){
    int idx = (val - m_referMin) * m_referDiv;
    int count = colorPoor.count();
    if(idx >= count || idx < 0)
    {
        //qDebug()<< "WaterfallPlot::calcColor: index error: "<< idx<< ". val: "<< val<<" m_referMin:"<<m_referMin;
        if(idx >= count)
            idx = count;
        else
            idx = 0;
    }
    return colorPoor.at(idx);
}
void WaterfallPlot::cutShowPoint(qreal bandwidth, qreal centerFreq, QVector<double> &source_points, QVector<double> &show_points)
{
    //根据用户配置的参数截取点数
    if(bandwidth > 50)
        bandwidth = 30;
    int capture_count = source_points.size();
    int cut_count     = (50 - bandwidth) * capture_count / 50 ;
    int show_count    = capture_count - cut_count;
    int offsetMHz     = 70 - centerFreq;
    if(abs(offsetMHz) >= 25){
        offsetMHz = 0;
        //qDebug()<<"updateFreqDodminFromFile param error 001! ";
    }
    qreal startMHz = 25 - offsetMHz - qreal(bandwidth)/2;
    if(startMHz <= 0){
        startMHz = 0;
        //qDebug()<<"updateFreqDodminFromFile param error 002! ";
    }
    //qDebug()<<"startMHz:"<<startMHz<<" offsetMHz:"<<offsetMHz;
    int show_start = capture_count * startMHz / 50;

    //qDebug()<<"cut_count:"<<cut_count<<" show_start:"<<show_start<<" show_count:"<<show_count<<" capture_count:"<<capture_count;
#if 1
    qreal rate = 1;
    int   reduce_cnt = 10000, cidx = 0, sidx = -1;
    if(show_count > reduce_cnt)
    {
        rate = (qreal)reduce_cnt/show_count;
        //qDebug()<<"cut rate"<<rate;
    }
    else
        reduce_cnt = show_count;

    show_points.reserve(reduce_cnt);
    for (int i=0; i < show_count; i++) {
        cidx = (int)(i*rate);
        if(cidx > sidx)
        {
            sidx = cidx;
            show_points.append(source_points.at(show_start + i));
        }
        //show_points.append(source_points.at(show_start + i));
    }
    //qDebug()<<"sidx"<<sidx<<"show_points size:"<<show_points.size();
#else
    show_points.reserve(show_count);
    for (int i=0; i < show_count; i++) {
        show_points.append(source_points.at(show_start + i));

    }
#endif
    //qDebug()<<"reduce_cnt"<<reduce_cnt;
    //qDebug()<<" "<<show_points.at(0)<<" "<<show_points.last();
}
void WaterfallPlot::refreshWaterfallData(int ch, int idx)
{
    if(ch == channel_idx){
        QVector<QPointF> show_points;
        //qDebug()<<"refreshWaterfallData: ch:"<<ch<<"idx:"<<idx;
        show_points.clear();
        show_points = data_source->getFFTPoints(ch, idx);
        if(!show_points.isEmpty())
            this->updateDataRT(show_points);
    }
}
void WaterfallPlot::refreshWaterfallFile(int ch, qreal bw, qreal cfreq)
{
    if(ch == channel_idx){
        //qDebug()<<"refreshWaterfallFile: ch:"<<ch<<"bw:"<<bw<<"cfreq:"<<cfreq;
        QVector<double> show_points;
        show_points.clear();
        show_points = data_source->getWaterfallPoints(ch);
        if(!show_points.isEmpty()){
            line_count  = this->updateData(bw, cfreq, show_points);
            emit lineCountChanged();
        }
    }
}
int WaterfallPlot::updateData(qreal bandwidth, qreal centerFreq, QVector<double> &dataLine){
    m_xCountOrig = 0;
    m_yCountOrig = 0;
    m_xCount = 0;
    m_yCount = 0;
    m_xStart = 0;

    QVector<QRgb> colorLine;
    colorLine.reserve(dataLine.count());
    QVector<double> show_points;
    this->cutShowPoint(bandwidth, centerFreq, dataLine, show_points);
    foreach (double point, show_points) {

        colorLine.append(getColor(point));
    }
    int img_w = colorLine.size();
    QImage img(img_w, 1, QImage::Format_RGB888);
    for(int x=0; x<img_w; x++)
    {
        img.setPixel(x, 0, colorLine[x]);
    }
    if(!img.isNull())
    {
        if(image_lines.size() >= m_rt_times)
        {
            image_lines.removeLast();
        }
        image_lines.insert(0, img);

        m_yCountOrig = image_lines.count();
        m_yCount = m_yCountOrig;
        if(m_yCount)
            m_xCountOrig = colorLine.count();
        m_xCount = m_xCountOrig;
    }

    //qDebug()<<"WaterfallPlot  m_xStart:"<<m_xStart<<"m_xCount:"<<m_xCount<<"m_yCount:"<<m_yCount<<"size:"<<image_lines.size()<<"count:"<<image_lines.count();
    update();
    return image_lines.count();
}


void WaterfallPlot::updateDataRT(QVector<QPointF> &dataLine)
{
    if(!m_refresh)
        return;

    m_xCountOrig = 0;
    m_yCountOrig = 0;
    m_xCount = 0;
    m_yCount = 0;
    m_xStart = 0;

    QVector<QRgb> colorLine;
    colorLine.reserve(dataLine.count());
    foreach (QPointF point, dataLine) {
        colorLine.append(getColor(point.y()));
    }
    int img_w = colorLine.size();

    QImage img(img_w, 1, QImage::Format_RGB888);

    for(int x=0; x<img_w; x++)
    {
        img.setPixel(x, 0, colorLine[x]);
    }
    //qDebug()<<"one line size:"<<img.bytesPerLine()<<"img_w"<<img_w<<"fix_height"<<fix_height;

    if(!img.isNull())
    {
        if(image_lines.size() >= m_rt_times)
            image_lines.removeLast();
        image_lines.insert(0, img);

        m_yCountOrig = image_lines.count();
        m_yCount = m_yCountOrig;
        if(m_yCount)
            m_xCountOrig = colorLine.count();
        m_xCount = m_xCountOrig;
    }
}
void WaterfallPlot::clearPixelColor(void)
{
    m_xCount = 0;
    m_yCount = 0;
    image_lines.clear();
}



void WaterfallPlot::paint(QPainter *painter){
    if(!m_xCount || !m_yCount)
        return;

    //采用缓冲绘制,避免画面闪烁
    QImage   img;
    qreal    fix_height = height()/m_rt_times;
    QImage   show_image(width(), image_lines.size(), QImage::Format_RGB888);
    QPainter sub_painter(&show_image);
    int i=0;

    if(m_rt_mode){

        qreal cur_s = (qreal)(m_cur_axisx_min-m_axisx_min)/(m_axisx_max-m_axisx_min);
        qreal cur_e = (qreal)(m_cur_axisx_max-m_axisx_min)/(m_axisx_max-m_axisx_min);
        //qDebug()<<"cur_s:"<<cur_s<<"cur_e:"<<cur_e;
        //计算缩放倍数
        int line_count = image_lines.last().bytesPerLine()/3;
        int line_start = line_count*cur_s;
        int line_end   = line_count*cur_e;
        foreach (img, image_lines) {
            //根据缩放系数抽取显示
            QImage new_img = img.copy(line_start, 0, line_end-line_start, img.height());
            new_img = new_img.scaled(width(), 1);
            sub_painter.drawImage(0, i, new_img, 0, 0);//缓存绘制
            i++;
        }
    }
    else{

        //qDebug()<<"paint  m_xCountOrig:"<<m_xCountOrig<<"m_xStart:"<<m_xStart<<"m_xCount:"<<m_xCount<<"size:"<<image_lines.last().bytesPerLine()/3;
        //计算缩放倍数
        qreal cur_s = (qreal)m_xStart/m_xCountOrig;
        qreal cur_e = (qreal)(m_xStart+m_xCount)/m_xCountOrig;
        //qDebug()<<"cur_s:"<<cur_s<<"cur_e:"<<cur_e;

        int line_count = m_xCountOrig;
        int line_start = line_count*cur_s;
        int line_end   = line_count*cur_e;

        foreach (img, image_lines) {
            //根据缩放系数抽取显示
            line_count = img.bytesPerLine()/3;
            line_start = line_count*cur_s;
            line_end = line_count*cur_e;
            QImage new_img = img.copy(line_start, 0, line_end-line_start, img.height());
            //img = img.scaled(width(), 1);
            new_img = new_img.scaled(width(), 1);
            sub_painter.drawImage(0, i, new_img, 0, 0);//缓存绘制
            i++;
        }

    }
    sub_painter.end();

    if(m_rt_mode)
        show_image = show_image.scaled(width(), fix_height*i);
    else
        show_image = show_image.scaled(width(), height());
    painter->drawImage(0, 0, show_image, 0, 0);
}
void WaterfallPlot::zoomHorizontal(float min, float max, float cur)
{
    Q_UNUSED(cur)
    if(!m_xCount || !m_yCount)
        return;

    int xStart = m_xCountOrig * min;
    int xCount = m_xCountOrig * (max-min);
    if(xCount < m_minHPixel)
        xCount = m_minHPixel;

    m_xCount = xCount;
    m_xStart = xStart;

//    qDebug() <<m_xStart << m_xCount;

    update();
}

void WaterfallPlot::zoomReset(void)
{
    if(!m_xCount || !m_yCount)
        return;

    m_xCount = m_xCountOrig;
    m_xStart = m_minHPixel;

    update();
}

void WaterfallPlot::setRtMode(void)
{
    m_rt_mode = true;
}
void WaterfallPlot::setFileMode(void)
{
    m_rt_mode = false;
}
void WaterfallPlot::updateRefLebel(float min, float max)
{
    if(max < min)
        return;
    m_max_dbm = max;
    m_min_dbm = min;
    //qDebug()<<"updateRefLebel"<<m_min_dbm<<m_max_dbm;
    m_color_step = (m_max_dbm - m_min_dbm) / 1000;
}
void WaterfallPlot::setAxisXData(float cur_min, float cur_max, float min, float max)
{
    //专门用于实时缩放瀑布图使用， 文件方式使用另外的方式
    if(cur_min>cur_max)
        return;
    if(min>max)
        return;
    if(cur_max>max)
        return;
    if(cur_min<min)
        return;
    m_cur_axisx_min = cur_min;
    m_cur_axisx_max = cur_max;
    m_axisx_min = min;
    m_axisx_max = max;
    //qDebug()<<"cur_min:"<<cur_min<<"cur_max:"<<cur_max<<"min:"<<min<<"max:"<<max;
}
void WaterfallPlot::openWaterfallRtCapture(void)//clearPixelColor
{
    this->clearPixelColor();
    m_refresh = true;
}
void WaterfallPlot::closeWaterfallRtCapture(void)
{
    m_refresh = false;
}

void WaterfallPlot::safeUpdate(void)
{
    if(lock.tryLockForRead())
    {
        update();
        lock.unlock();
    }
    else
        qDebug()<<"WaterfallPlot safeUpdate busy!";
}

