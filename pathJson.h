﻿#ifndef PATHJSON_H
#define PATHJSON_H

#include <QObject>
#include <qvariant.h>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>

class PathJson : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int mode READ mode WRITE setMode)
public:
    explicit PathJson(QObject *parent = 0);
    ~PathJson();
    int mode()
    {
        return m_mode;
    }
    void setMode(int mode)
    {
        if (mode) {
            m_mode = QJsonDocument::Indented;
        } else {
            m_mode = QJsonDocument::Compact;
        }
    }
    Q_INVOKABLE int saveJsonFile(QVariant var);
    Q_INVOKABLE QVariant openJsonFile(QString fileName);
private:
    QVariant exportList();
signals:

public slots:
private:
    QJsonDocument::JsonFormat m_mode;
    QString m_file;
    QJsonArray m_pathArray;
};

#endif // PATHJSON_H
