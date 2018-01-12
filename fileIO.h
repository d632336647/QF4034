#ifndef FILEIO_H
#define FILEIO_H

#include <QObject>
#include <QFile>
#include <QFileInfo>
#include <QString>

class FileIO : public QObject{
    Q_OBJECT

public:
    FileIO(QObject *parent = 0);
    ~FileIO();

public slots:
    bool write(QString fileName, QString s);
    QString read(QString fileName);

private:
    bool check_error(QString fileName, QFile &file, bool truncateFlag);
};

#endif // FILEIO_H
