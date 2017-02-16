#include "udpServer.h"
#include <QDebug>

UdpServer::UdpServer(QObject *parent) : QObject(parent), udpSocket(this)
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
            case 1002:
                break;
            case 1004:
                break;
            case 1006:
                break;
            case 1008:
                break;
            case 19000:
                break;
            default:
                qDebug() << "unknown inf " + inf;
                break;
            }
        }
//        str2ip(addr);
//        str2port(addr);
    }
    return;
}

