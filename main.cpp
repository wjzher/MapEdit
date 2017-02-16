#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "MapItemType.h"
#include "mapData.h"
#include "pathJson.h"
#include "udpServer.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    qmlRegisterType<MapItemType>("Qt.MapItemType", 1, 0, "MapItemType");
    qmlRegisterType<MapData>("Qt.MapData", 1, 0, "MapData");
    qmlRegisterType<PathJson>("Qt.PathJson", 1, 0, "PathJson");
    qmlRegisterType<UdpServer>("Qt.UdpServer", 1, 0, "UdpServer");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
