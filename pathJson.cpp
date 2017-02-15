#include "pathJson.h"
#include <QDebug>
#include <QAbstractListModel>
#include <QJSValue>

PathJson::PathJson(QObject *parent) : QObject(parent), m_mode(QJsonDocument::Compact), m_file("")
{

}

PathJson::~PathJson()
{

}

int PathJson::saveJsonFile(QVariant var)
{
    QString s = var.toString();
    if (s == "") {
        qDebug() << "save Json var is empty";
        if (m_file == "") {
            qDebug() << "m_file is empty";
            return 0;
        } else {
            s = m_file;
        }
    }
    QFile file(s);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "saveJsonFile: Can not open " + s + "!";
        return -1;
    }
    QJsonObject rootJsonObj;
    rootJsonObj["type"] = "0";
    rootJsonObj["flag"] = 1;
    rootJsonObj["src"] = 0;
    rootJsonObj["auth"] = "nkty";
    rootJsonObj["inf"] = 1007;
    QJsonObject paramObj;
    paramObj["agvid"] = 1;
    paramObj["handle"] = 0;
    paramObj["path"] = m_pathArray;
    rootJsonObj["param"] = paramObj;
    QJsonDocument jsonDoc(rootJsonObj);
    file.write(jsonDoc.toJson(m_mode));
    file.close();
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
    m_file = fileName;
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
    return var;
}

void PathJson::modifyItem(int index, QVariant var)
{
    if (index < 0 || index >= m_pathArray.count()) {
        return;
    }
    QString s = var.toString();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(s.toUtf8());
    QJsonObject pathObj = jsonDoc.object();
    if (pathObj.isEmpty()) {
        qDebug() << "modifyItem empty";
        return;
    }
    QJsonValue pathVal(pathObj);
    m_pathArray[index] = pathVal;
    qDebug() << m_pathArray;
    return;
}

void PathJson::deleteItem(int index)
{
    if (index < 0 || index >= m_pathArray.count()) {
        return;
    }
    m_pathArray.removeAt(index);
    return;
}

void PathJson::insertItem(int index, QVariant var)
{
    qDebug() << "insert Item " << index << " " << var << " " << m_pathArray.count();
    if (index < 0 || index > m_pathArray.count()) {
        return;
    }
    QString s = var.toString();
    qDebug() << "var: " << s;
    QJsonDocument jsonDoc = QJsonDocument::fromJson(s.toUtf8());
    QJsonObject pathObj = jsonDoc.object();
    if (pathObj.isEmpty()) {
        qDebug() << "insertItem empty";
        return;
    }
    QJsonValue pathVal(pathObj);
    m_pathArray.insert(index, pathVal);
    qDebug() << m_pathArray;
    return;
}

void PathJson::moveItem(int from, int to)
{
    if (from < 0 || from >= m_pathArray.count()) {
        return;
    }
    if (to < 0 || to >= m_pathArray.count()) {
        return;
    }
    QJsonValue tmp = m_pathArray[from];
    m_pathArray[from] = m_pathArray[to];
    m_pathArray[to] = tmp;
    return;
}
