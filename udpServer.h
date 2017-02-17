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
    Q_PROPERTY(QString currentIp READ currentIp WRITE setCurrentIp)
public:
    explicit UdpServer(QObject *parent = 0);
    ~UdpServer();
    QString currentIp() const
    {
        return m_currentIp;
    }
    void setCurrentIp(const QString &s)
    {
        m_currentIp = s;
    }
    Q_INVOKABLE void sendCommand(int inf, QString cmd);
private:
    QString str2ip(QString s)
    {
        QString r = "";
        int n = s.lastIndexOf(':');
        if (n < 0) {
            return r;
        }
        r = s.left(n);
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
        return r;
    }

    void addAddressList(QString &addr);
    bool isAddressExist(QString &addr);

    QByteArray makeJsonResponse(int inf, QString &param);
    int jsonMessageParse(QByteArray msg, QJsonObject &jsonObj);
    QByteArray makeTickResponse(QJsonObject &jsonObj);
    void emitSignals(QString &ip, int inf, QJsonObject &param);
signals:
    void agvStatusChanged(int inf, const QString &status);
    // 信号参数类型QString需要用const引用类型，否则qml不识别
    void agvAddressChanged(const QString &ip);
public slots:
    void readPendingDatagrams();
private:
    QUdpSocket udpSocket;
    QStringList clientList;
    QString m_currentIp;
    int m_flag;
};

#endif // UDPSERVER_H
