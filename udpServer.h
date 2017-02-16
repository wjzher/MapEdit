#ifndef UDPSERVER_H
#define UDPSERVER_H

#include <QObject>
#include <QUdpSocket>
#include <QJsonValue>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>

class UdpServer : public QObject
{
    Q_OBJECT
public:
    explicit UdpServer(QObject *parent = 0);
    ~UdpServer();
private:
    QString str2ip(QString s)
    {
        QString r = "";
        int n = s.lastIndexOf(':');
        if (n < 0) {
            return r;
        }
        qDebug() << "ip " << n << " " << s.length();
        r = s.left(n);
        qDebug() << r;
        return r;
    }

    QString str2port(QString s)
    {
        QString r = "";
        int n = s.lastIndexOf(':');
        if (n < 0) {
            return r;
        }
        n = s.length() - n;
        r = s.right(n - 1);
        qDebug() << r;
        return r;
    }

    void addAddressList(QString addr);
    bool isAddressExist(QString addr);

    int jsonMessageParse(QByteArray msg, QJsonObject &jsonObj);
    QByteArray makeTickResponse(QJsonObject &jsonObj);
signals:

public slots:
    void readPendingDatagrams();
private:
    QUdpSocket udpSocket;
    QStringList clientList;
};

#endif // UDPSERVER_H
