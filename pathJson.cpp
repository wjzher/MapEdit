#include "pathJson.h"
#include <QDebug>
#include <QAbstractListModel>

PathJson::PathJson(QObject *parent) : QObject(parent), m_mode(QJsonDocument::Compact), m_file("")
{

}

PathJson::~PathJson()
{

}

int PathJson::saveJsonFile(QVariant var)
{
    qDebug() << var;
    qDebug() << var.typeName();
    return 0;
}

QVariant PathJson::openJsonFile(QString fileName)
{
    QVariant var;
    QFile file(fileName);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "openJsonFile: Can not open " + fileName + "!";
        return var;
    }
    QTextStream in(&file);
    QString strJson = in.readAll();
    file.close();
    QByteArray byteArray = strJson.toUtf8();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(byteArray);
    if (jsonDoc.isNull()) {
        qDebug() << "load Json Doc error";
        return var;
    }
    QJsonObject rootJsonObj = jsonDoc.object();
    if (rootJsonObj.empty()) {
        qDebug() << "root Json Object empty";
        return var;
    }
    QJsonValue paramVal = rootJsonObj["param"];
    if (paramVal.isObject() == false) {
        qDebug() << "param Json Object is not Object";
        return var;
    }
    QJsonObject paramObj = paramVal.toObject();
    QJsonValue pathVal = paramObj["path"];
    if (pathVal.isArray() == false) {
        qDebug() << "path Json Object is not Array";
        return var;
    }
    m_pathArray = pathVal.toArray();
    return exportList();
}

QVariant PathJson::exportList()
{
    QJsonDocument jDoc(m_pathArray);
    QVariant var(jDoc.toJson(QJsonDocument::Compact));
//    qDebug() << "pathVal: " << jDoc.toJson(QJsonDocument::Compact);
    return var;
}
