#include "udpServer.h"
#include <QDebug>

UdpServer::UdpServer(QObject *parent) : QObject(parent)
{
    udpSocket = new QUdpSocket(this);
    udpSocket->bind(11078);
    qDebug() << "Udp Server running";
    connect(udpSocket, SIGNAL(readyRead()), this, SLOT(readPendingDatagrams()));
}

UdpServer::~UdpServer()
{

}

void UdpServer::readPendingDatagrams()
{
//    QHostAddress sender;
//    quint16 senderPort;
//    while (udpSocket->hasPendingDatagrams()) {
//        QByteArray datagram;
//        datagram.resize(udpSocket->pendingDatagramSize());
//        udpSocket->readDatagram(datagram.data(), datagram.size(),&sender, &senderPort);
//        string strMes(datagram);
//        std::cout<<strMes<<endl;
//    }
//    QString text = "hello ...";
//    QByteArray datagram = text.toLocal8Bit();
//    udpSocket->writeDatagram(datagram.data(),datagram.size(),sender, senderPort);
    return;
}

