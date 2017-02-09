#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "MapItemType.h"
#include "mapData.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    qmlRegisterType<MapItemType>("Qt.MapItemType", 1, 0, "MapItemType");
    qmlRegisterType<MapData>("Qt.MapData", 1, 0, "MapData");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
