#include "udpServer.h"
#include <QDebug>

UdpServer::UdpServer(QObject *parent)
    : QObject(parent), udpSocket(this), m_currentIp("")
{
    udpSocket.bind(11078);
    qDebug() << "Udp Server running";
    connect(&udpSocket, SIGNAL(readyRead()), this, SLOT(readPendingDatagrams()));
}

UdpServer::~UdpServer()
{
}

bool UdpServer::isAddressExist(QString addr)
{
    QStringList result = clientList.filter(addr);
    qDebug() << "is Address Exsit" << result;
    if (result.count()) {
        return true;
    }
    return false;
}

void UdpServer::addAddressList(QString addr)
{
    if (isAddressExist(addr)) {
        return;
    }
    clientList.append(addr);
    qDebug() << addr << "add to list";
    return;
}

/*
 * 分析json message 返回 inf
 */
int UdpServer::jsonMessageParse(QByteArray msg, QJsonObject &jsonObj)
{
    QJsonParseError err;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(msg, &err);
    if (jsonDoc.isNull()) {
        qDebug() << err.errorString();
        qDebug() << "jsonMessageParse error json doc null";
        return -1;
    }
    jsonObj = jsonDoc.object();
    if (jsonObj.isEmpty()) {
        return -1;
    }
    QJsonValue infVal = jsonObj["inf"];
    int inf;
    if (infVal.isString()) {
        QString s = infVal.toString();
        inf = s.toInt();
    } else {
        inf = infVal.toInt(-1);
    }
    return inf;
}

QByteArray UdpServer::makeTickResponse(QJsonObject &jsonObj)
{
    jsonObj["type"] = "1";
    jsonObj["src"] = "0";
    jsonObj["auth"] = "nkty";
    jsonObj["inf"] = "5001";
    QJsonObject paramObj;
    paramObj.insert("ret", QJsonValue("0"));
    jsonObj["param"] = paramObj;
    QJsonDocument jsonDoc(jsonObj);
    return jsonDoc.toJson(QJsonDocument::Compact);
}

QByteArray UdpServer::makeJsonResponse(int inf, QString &param)
{
    QJsonParseError err;
    QJsonDocument paramDoc = QJsonDocument::fromJson(param.toUtf8(), &err);
    if (paramDoc.isNull()) {
        qDebug() << err.errorString();
        qDebug() << "makeJsonResponse error json doc null";
        return "";
    }
    QJsonObject paramObj = paramDoc.object();

    QJsonObject jsonObj;
    jsonObj["type"] = "1";
    jsonObj["src"] = "0";
    jsonObj["auth"] = "nkty";
    jsonObj["inf"] = QString::number(inf);
    jsonObj["param"] = paramObj;
    QJsonDocument jsonDoc(jsonObj);
    return jsonDoc.toJson(QJsonDocument::Compact);
}

void UdpServer::readPendingDatagrams()
{
    while (udpSocket.hasPendingDatagrams()) {
        QHostAddress sender;
        quint16 senderPort;
        QByteArray datagram;
        int inf;
        QJsonObject jsonObj;
        datagram.resize(udpSocket.pendingDatagramSize());
        udpSocket.readDatagram(datagram.data(), datagram.size(), &sender, &senderPort);
        if ((inf = jsonMessageParse(datagram, jsonObj)) < 0) {
            qDebug() << "json Parse inf failed.";
            continue;
        }
        QString addr = sender.toString() + ":" + QString::number(senderPort);
        if (inf == 5001) {
            qDebug() << "recv tick data " << addr;
            // 加入client list
            addAddressList(addr);
            // 回复心跳
            udpSocket.writeDatagram(makeTickResponse(jsonObj), sender, senderPort);
        } else {
            switch (inf) {
            case 1001:
                break;
            case 1003:
                break;
            case 1005:
                break;
            case 1007:
                break;
            case 19000:
                break;
            default:
                qDebug() << "unknown inf " + inf;
                break;
            }
        }
        // emit signals
        emitSignals(str2ip(addr), inf, jsonObj["param"].toObject());
//        str2ip(addr);
//        str2port(addr);
    }
    return;
}

void UdpServer::emitSignals(QString addr, int inf, QJsonObject &param)
{
    if (param.isEmpty()) {
        return;
    }
    if (!addr.contains(m_currentIp)) {
        return;
    }
    qDebug() << "emit signals " << addr << " " << param;
    QJsonDocument jsonDoc(param);
    QString s(jsonDoc.toJson());
    emit agvStatusChanged(inf, s);
    return;
}

/*
 * inf + json string
 */
void UdpServer::SendCommand(int inf, QString &cmd)
{
    QStringList result = clientList.filter(m_currentIp);
    if (!result.count()) {
        qDebug() << "SendCommand " << m_currentIp << " is not exist";
    }
    QString &addr = result[0];
    QHostAddress sender(str2ip(addr));
    quint16 senderPort = str2port(addr).toInt();
    udpSocket.writeDatagram(makeJsonResponse(inf, cmd), sender, senderPort);
    return;
}
