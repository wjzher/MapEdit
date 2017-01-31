#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include "MapItemType.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    qmlRegisterType<MapItemType>("Qt.MapItemType", 1, 0, "MapItemType");

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    return app.exec();
}
