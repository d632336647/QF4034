#include "fileIO.h"
#include <QDebug>
#include <QJsonObject>

FileIO::FileIO(QObject *parent)
    : QObject(parent){
}
FileIO::~FileIO(){

}

bool FileIO::check_error(QString fileName, QFile &file, bool truncateFlag){
    QIODevice::OpenMode mode = QIODevice::ReadWrite | QIODevice::Text;
    if(truncateFlag)
        mode |= QIODevice::Truncate;

    if (fileName.isEmpty())
    {
        qDebug()<<"file name is null";
        return false;
    }
    file.setFileName(fileName);

//    QFileInfo fileInfo(file);
//    qDebug() << "file path: " << fileInfo.absoluteFilePath();

    if(!file.open((mode))) {
        qDebug()<<"Can't open the file!";
        return false;
    }

    return true;
}
bool FileIO::write(QString fileName, QString s){
    QFile file;
    if(!check_error(fileName, file, true))
        return false;

    QTextStream out(&file);
    out.setCodec("utf-8");
    out << s;
    //file.write(s.toLatin1());

    file.close();
    return true;
}
QString FileIO::read(QString fileName){
    QFile file;
    if(!check_error(fileName, file, false))
        return NULL;

    QByteArray a = file.readAll();
    QString s(a);

    file.close();
    return s;
}
