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
    Q_INVOKABLE QVariant getAgvIpByCardId(int cardId);
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
    int addressIndex(QString &addr);

    QByteArray makeJsonResponse(int inf, QString &param);
    int jsonMessageParse(QByteArray msg, QJsonObject &jsonObj);
    QByteArray makeTickResponse(QJsonObject &jsonObj);
    void emitSignals(QString &ip, int inf, QJsonObject &param);
    void emitCardIdSignal(QString &addr, QJsonObject &param);
    void emitStatus(QString &ip, QJsonObject &param);
signals:
    void agvStatusChanged(int inf, const QString &status);
    void agvStatusChanged2(const QString &ip, const QString &status);
    // 信号参数类型QString需要用const引用类型，否则qml不识别
    void agvAddressChanged(const QString &ip);
    void agvCardIdChanged(const QString &ip, int lastId, int cardId);
public slots:
    void readPendingDatagrams();
private:
    QUdpSocket udpSocket;
    QStringList clientList;
    QList<int> cardIdList;      // agv cardIdList, agv所在的pre点
    QString m_currentIp;
    int m_flag;
};

#endif // UDPSERVER_H
