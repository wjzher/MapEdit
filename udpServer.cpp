#include "udpServer.h"
#include <QDebug>
#include <QDateTime>

UdpServer::UdpServer(QObject *parent)
    : QObject(parent), udpSocket(this), m_currentIp("")
{
    udpSocket.bind(11078);
    qDebug() << "Udp Server running";
    connect(&udpSocket, SIGNAL(readyRead()), this, SLOT(readPendingDatagrams()));
    m_flag = 1;
}

UdpServer::~UdpServer()
{
}

bool UdpServer::isAddressExist(QString &addr)
{
    QStringList result = clientList.filter(addr);
//    qDebug() << "is Address Exsit" << result;
    if (result.count()) {
        return true;
    }
    return false;
}

int UdpServer::addressIndex(QString &addr)
{
    return clientList.indexOf(addr);
}

void UdpServer::addAddressList(QString &addr)
{
    if (isAddressExist(addr)) {
        return;
    }
    clientList.append(addr);
    cardIdList.append(-1);
    qDebug() << addr << "add to list";
    emit agvAddressChanged(addr);
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
        qDebug() << param;
        return "";
    }
    QJsonObject paramObj = paramDoc.object();

    QJsonObject jsonObj;
    jsonObj["type"] = "0";
    jsonObj["flag"] = QString::number(m_flag++);
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
            QDateTime time = QDateTime::currentDateTime();//获取系统现在的时间
            QString str = time.toString("hh:mm:ss.z"); //设置显示格式
//            qDebug() << "recv tick data " << addr << "[" << str << "]" << " " << jsonObj["param"];
            // 加入client list
            addAddressList(addr);
            // emit signals
            QJsonObject paramObj = jsonObj["param"].toObject();
            emitSignals(addr, inf, paramObj);
            emitCardIdSignal(addr, paramObj);
            emitStatus(addr, paramObj);
            // 回复心跳
            udpSocket.writeDatagram(makeTickResponse(jsonObj), sender, senderPort);
        } else {
            switch (inf) {
            case 1001:
            case 1003:
            case 1005:
            case 1007:
            case 19000:
                // emit signals
                emitSignals(addr, inf, jsonObj["param"].toObject());
                break;
            default:
                qDebug() << "unknown inf " + inf;
                break;
            }
        }
    }
    return;
}

QVariant UdpServer::getAgvIpByCardId(int cardId)
{
    QVariant val("");
    int i;
    for (i = 0; i < cardIdList.count(); i++) {
        if (cardId == cardIdList[i]) {
            val = QVariant(clientList[i]);
            break;
        }
    }
    return val;
}

void UdpServer::emitCardIdSignal(QString &addr, QJsonObject &param)
{
    int i;
    i = addressIndex(addr);
    if (i < 0) {
        qDebug() << "Bug: can not find addr " << addr;
        return;
    }
    QJsonValue jVal = param["infos"];
    if (jVal.isObject() == false) {
        qDebug() << "emitCardIdSignal Bug: can not find infos";
        return;
    }
    QJsonObject jObj = jVal.toObject();
    if (jObj["prepos"].isString() == false) {
        qDebug() << "emitCardIdSignal Bug: can not find prepos";
        return;
    }
    int id = jObj["prepos"].toString().toInt();
    if (id <= 0) {
//        qDebug() << "emitCardIdSignal Bug: can not find prepos 2";
        return;
    }
    if (cardIdList[i] != id) {
        qDebug() << id << " emit to " << addr;
        emit agvCardIdChanged(addr, cardIdList[i], id);
        cardIdList[i] = id;
    }
}

void UdpServer::emitSignals(QString &ip, int inf, QJsonObject &param)
{
    if (param.isEmpty()) {
        return;
    }
    if (ip != m_currentIp) {
        qDebug() << "filter signal from " + ip + ", current " + m_currentIp;
        return;
    }
//    qDebug() << "emit signals " << ip << " " << param;
    QJsonDocument jsonDoc(param);
    QString s(jsonDoc.toJson(QJsonDocument::Compact));
    emit agvStatusChanged(inf, s);
    return;
}

void UdpServer::emitStatus(QString &ip, QJsonObject &param)
{
    if (param.isEmpty()) {
        return;
    }
//    qDebug() << "emit Status " << ip << " " << param;
    QJsonDocument jsonDoc(param);
    QString s(jsonDoc.toJson(QJsonDocument::Compact));
    emit agvStatusChanged2(ip, s);
    return;
}

/*
 * inf + json string
 */
void UdpServer::sendCommand(int inf, QString cmd)
{
    QStringList result = clientList.filter(m_currentIp);
    if (!result.count()) {
        qDebug() << "SendCommand " << m_currentIp << " is not exist";
        return;
    }
    QString &addr = result[0];
    QHostAddress sender(str2ip(addr));
    quint16 senderPort = str2port(addr).toInt();
//    qDebug() << "send Command " << sender.toString() << " " << senderPort;
    QByteArray byteArray = makeJsonResponse(inf, cmd);
//    qDebug() << QString(byteArray);
    udpSocket.writeDatagram(byteArray, sender, senderPort);
    return;
}
