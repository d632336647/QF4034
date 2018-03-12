#include <QGuiApplication>
#include <QtWidgets/QApplication>
#include <QQmlApplicationEngine>
#include <QtQuick/QQuickView>
#include <QtQml>
#include <QFontDatabase>


#include "fileIO.h"
#include "settings.h"
#include "SliChart/WaterfallPlot.h"
#include "SliChart/ChartCtrl.h"
#include "SliChart/DataSource.h"
#include "SliChart/CaptureThread.h"
#include "SliChart/SpectrumData.h"


QT_CHARTS_USE_NAMESPACE

void clearLog(){
    QFile file("log.txt");
    file.open(QIODevice::WriteOnly | QIODevice::Truncate);
    file.close();
}
void outputMessage(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{
    Q_UNUSED(context)
    static QMutex mutex;
    mutex.lock();

    QString text;
    switch(type)
    {
    case QtDebugMsg:
        text = QString("Debug:");
        break;

    case QtWarningMsg:
        text = QString("Warning:");
        break;

    case QtCriticalMsg:
        text = QString("Critical:");
        break;

    case QtFatalMsg:
        text = QString("Fatal:");
    }

//    QString context_info = QString("File:(%1) Line:(%2)").arg(QString(context.file)).arg(context.line);
//    QString current_date_time = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss ddd");
    QString current_date_time = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
    QString current_date = QString("(%1)").arg(current_date_time);
//    QString message = QString("%1 %2 %3 %4").arg(text).arg(context_info).arg(msg).arg(current_date);
    QString message = QString("%1 %2 %3").arg(text).arg(msg).arg(current_date);

    QFile file("log.txt");
    file.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream text_stream(&file);
    text_stream.setCodec("utf-8");
    text_stream << message << "\r\n";
    file.flush();
    file.close();

    mutex.unlock();
}

/*
void testCPCI(){
    PciDevice pciDev;
    pciDev.scanCard();
    CpciCard *cpciCard = (CpciCard*)pciDev.getCard(1);
    if(cpciCard){
        PCI_DEVICE_INFO *cardInfo = cpciCard->cardInfo();
        qDebug() <<"scanCard---cardInfo---" <<cardInfo->mainType<<cardInfo->subType;
        qDebug() <<"scanCard---selfCheck---" << cpciCard->selfCheck();

//        qDebug() <<"scanCard---softReset---" <<cpciCard->softReset();
//        qDebug() <<"scanCard---hardReset---" <<cpciCard->hardReset();
//        qDebug() <<"scanCard---allReset---" << cpciCard->allReset();

        cpciCard->setClockTrigger();
        cpciCard->setDDC();
//      Sleep(3000);
        StoreParam &storeParam = cpciCard->getStoreParam();
        storeParam.m_storeMode = SizeFixedType;
        storeParam.m_recordSource = TestDataSource;
        storeParam.m_storeSize = 10;
        cpciCard->startStore();
    }
}
*/

#ifdef Q_OS_WIN
#include <Windows.h>
#include "DbgHelp.h"
static LONG ApplicationCrashHandler(EXCEPTION_POINTERS *pException)
{
    //And output crash information
    EXCEPTION_RECORD *record = pException->ExceptionRecord;
    QString errCode(QString::number(record->ExceptionCode, 16));
    QString errAddr(QString::number((uint)record->ExceptionAddress, 16));
    QString errFlag(QString::number(record->ExceptionFlags, 16));
    QString errPara(QString::number(record->NumberParameters, 16));
    qDebug()<<"errCode: "<<errCode;
    qDebug()<<"errAddr: "<<errAddr;
    qDebug()<<"errFlag: "<<errFlag;
    qDebug()<<"errPara: "<<errPara;

    //Create the dump file
    HANDLE hDumpFile = CreateFile((LPCWSTR)QString("crash.dmp").utf16(),
             GENERIC_WRITE, 0, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if(hDumpFile != INVALID_HANDLE_VALUE) {
        MINIDUMP_EXCEPTION_INFORMATION dumpInfo;
        dumpInfo.ExceptionPointers = pException;
        dumpInfo.ThreadId = GetCurrentThreadId();
        dumpInfo.ClientPointers = TRUE;
        MiniDumpWriteDump(GetCurrentProcess(), GetCurrentProcessId(),hDumpFile, MiniDumpNormal, &dumpInfo, NULL, NULL);
        CloseHandle(hDumpFile);
    }

    return EXCEPTION_EXECUTE_HANDLER;
}
#endif



//#include "secureprotect.h"

int main(int argc, char *argv[])
{

    QApplication app(argc, argv);



    QDir::setCurrent(app.applicationDirPath());
    qDebug()<<QDir::currentPath();

    //QString ss = app.applicationDirPath()+"/qf4034.exe";

    //SecureProtect sp(ss.toStdString());

#if (NATIVE_DEBUG == 1)
    //注册MessageHandler
    clearLog();
    qInstallMessageHandler(outputMessage);
#ifdef Q_OS_WIN
    SetUnhandledExceptionFilter((LPTOP_LEVEL_EXCEPTION_FILTER)ApplicationCrashHandler);
#endif
    qDebug() << "\r\n+++++++++app start++++++++++++";
#endif

    //载入字体资源文件
    QFontDatabase::addApplicationFont("://rc/font/fontawesome-webfont.ttf");


    QQuickView viewer;
    Settings settings(&viewer);
    qDebug()<<"main";
    settings.load();

    QObject::connect(viewer.engine(), &QQmlEngine::quit, &viewer, &QWindow::close);
    //QObject::connect(viewer.engine(), SIGNAL(quit()), qApp, SLOT(quit()));


    viewer.setTitle(QStringLiteral("Spectrum Analyzer"));

    //qDebug()<<app.applicationDirPath()+"/QMLPlugin";
    //viewer.engine()->addImportPath(app.applicationDirPath()+"/QMLPlugin");
    viewer.engine()->addImportPath("D:/QMLPlugin");

    DataSource dataSource(&viewer, &settings);
    ChartCtrl  chartCtrl(&viewer);

    CaptureThread captureThread(&dataSource);
    captureThread.start();
    viewer.rootContext()->setContextProperty("dataSource", &dataSource);
    viewer.rootContext()->setContextProperty("chartCtrl",  &chartCtrl);
    viewer.rootContext()->setContextProperty("fileIO", new FileIO);
    viewer.rootContext()->setContextProperty("Settings", &settings);
    viewer.rootContext()->setContextProperty("captureThread", &captureThread);
    qmlRegisterType<WaterfallPlot>("WaterfallPlot", 1, 0, "WaterfallPlot");
    qmlRegisterType<SpectrumData>("SpectrumData", 1, 0, "SpectrumData");

    //QObject::connect(viewer.engine(), SIGNAL(quit()), &captureThread, SLOT(exit()));

    viewer.setSource(QUrl("qrc:/qml/main.qml"));
    viewer.setResizeMode(QQuickView::SizeRootObjectToView);
    viewer.setColor(QColor("#404040"));


    viewer.setFlags(Qt::Window | Qt::FramelessWindowHint);

    //将viewer注册为mainWindow对象
    viewer.rootContext()->setContextProperty("mainWindow",&viewer);

    viewer.show();

    return app.exec();
}
