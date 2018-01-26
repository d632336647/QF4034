#include "WaterfallPlot.h"

WaterfallPlot::WaterfallPlot(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{

    m_referMax = 150;
    m_referMin = 90;


    initRgbMap();
    m_rt_times = 50;
    m_rt_mode = false;

    channel_idx = 0;
    m_refresh = false;
}
WaterfallPlot::~WaterfallPlot(){

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
    }
}
void WaterfallPlot::setReferMin(double val){
    if(val <= m_referMax)
    {
        m_referMin = val;
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
DataSource* WaterfallPlot::getSource(void)
{
    return data_source;
}
void WaterfallPlot::setSource(DataSource *ds)
{
    data_source = ds;
    connect(data_source, SIGNAL(updateFFTPoints(int, int)), this, SLOT(refreshWaterfallData(int, int)) );
    connect(data_source, SIGNAL(updateWaterfallFile(int)),  this, SLOT(refreshWaterfallFile(int)) );
    connect(data_source, SIGNAL(forceUpdateSeries(int)),    this, SLOT(setClearWaterfall(int)) );
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
void WaterfallPlot::reducePoint(QVector<double> &source_points, QVector<double> &show_points)
{

    qreal rate = 1;
    int   reduce_cnt = 10000, cidx = 0, sidx = -1;
    int   show_count = source_points.size();
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
            show_points.append(source_points.at(i));
        }
        //show_points.append(source_points.at(show_start + i));
    }
    //qDebug()<<"sidx"<<sidx<<"show_points size:"<<show_points.size();
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
void WaterfallPlot::refreshWaterfallFile(int ch)
{
    if(ch == channel_idx){
        //qDebug()<<"refreshWaterfallFile: ch:"<<ch<<"bw:"<<bw<<"cfreq:"<<cfreq;
        QVector<double> show_points;
        show_points.clear();
        show_points = data_source->getWaterfallPoints(ch);
        if(!show_points.isEmpty()){
            line_count  = this->updateData(show_points);
            emit lineCountChanged();
        }
    }
}
void WaterfallPlot::setClearWaterfall(int ch)
{
    if(ch == channel_idx)
        this->clearPixelColor();
}
int WaterfallPlot::updateData(QVector<double> &dataLine){


    QVector<QRgb> colorLine;
    colorLine.reserve(dataLine.count());
    QVector<double> show_points;

    //this->reducePoint(dataLine, show_points);

    foreach (double point, dataLine) {

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
    }

    //qDebug()<<"WaterfallPlot  m_xStart:"<<m_xStart<<"m_xCount:"<<m_xCount<<"m_yCount:"<<m_yCount<<"size:"<<image_lines.size()<<"count:"<<image_lines.count();
    update();
    return image_lines.count();
}


void WaterfallPlot::updateDataRT(QVector<QPointF> &dataLine)
{
    if(!m_refresh)
        return;

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
    }
}
void WaterfallPlot::clearPixelColor(void)
{
    image_lines.clear();
}



void WaterfallPlot::paint(QPainter *painter){

    if(image_lines.size()<1)
        return;
    //采用缓冲绘制,避免画面闪烁
    QImage   img;
    qreal    fix_height = height()/m_rt_times;
    QImage   show_image(width(), image_lines.size(), QImage::Format_RGB888);
    QPainter sub_painter(&show_image);
    int i=0;

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

    sub_painter.end();

    if(m_rt_mode)
        show_image = show_image.scaled(width(), fix_height*i);
    else
        show_image = show_image.scaled(width(), height());
    painter->drawImage(0, 0, show_image, 0, 0);
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
    if(!m_rt_mode)//文件模式时,立即刷新
        safeUpdate();
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

