#include "mapData.h"
#include <QDebug>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>

MapData::MapData(QObject *parent)
    : QObject(parent)
{
    m_rows = 0;
    m_cols = 0;
    m_itemN = 0;
    m_items = NULL;
}

MapData::~MapData()
{
    if (m_items) {
        delete [] m_items;
    }
}

void MapData::initItems(int rows, int cols)
{
    m_rows = rows;
    m_cols = cols;
    emit rowsChanged(m_rows);
    emit colsChanged(m_cols);
    initItems();
}

void MapData::initItems()
{
    if (m_items) {
        delete [] m_items;
    }
    if (m_rows > 0 && m_cols > 0) {
        qDebug() << "Init Items: " <<  m_rows << " " << m_cols;
        m_itemN = m_rows * m_cols;
        m_items = new MapItem[m_itemN];
        int i;
        memset(m_items, 0, sizeof(*m_items) * m_itemN);
        for (i = 0; i < m_itemN; i++) {
            m_items[i].index = i;
            m_items[i].pos[0] = i / m_cols;
            m_items[i].pos[1] = i % m_cols;
        }
  }
}

void MapData::setRows(int arg)
{
    if (m_rows != arg) {
        m_rows = arg;
        initItems();
        emit rowsChanged(arg);
    }
}

int MapData::rows() const
{
    return m_rows;
}

void MapData::setCols(int arg)
{
    if (m_cols != arg) {
        m_cols = arg;
        initItems();
        emit colsChanged(arg);
    }
}

int MapData::cols() const
{
    return m_cols;
}

int MapData::resize(int rows, int cols)
{
    qDebug() << "resize " << rows << " " << cols << " " << m_rows << " " << m_cols;
    if (rows == m_rows && cols == m_cols) {
        qDebug() << "resize no change";
        return 0;
    }
    MapItem *old = m_items;
    int /*oldn = m_itemN, */oldr = m_rows, oldc = m_cols;
    m_items = NULL;
    initItems(rows, cols);
    for (int i = 0; i < m_itemN; i++) {
        int x = m_items[i].pos[0];
        int y = m_items[i].pos[1];
        if (x < oldr && y < oldc) {
            int idx = y + x * oldc;
            if (x != old[idx].pos[0] || y != old[idx].pos[1]) {
                qDebug() << "resize bug " << i << ", " << x << " " << y << " " << idx <<
                            " " << old[idx].pos[0] << " " << old[idx].pos[1];
            }
//            qDebug() << "resize " << i << ", " << x << " " << y << " " << idx << " " << old[idx].index;
            m_items[i] = old[idx];
            m_items[i].index = i;
            m_items[i].pos[0] = x;
            m_items[i].pos[1] = y;
//            qDebug() << "old is " << old[idx].type;
//            qDebug() << "new is " << m_items[i].type;
        }
    }
    delete [] old;
    return 0;
}

MapItem *MapData::getMapItem(int index)
{
    MapItem *item;
    if (index < 0 ||index >= m_itemN) {
        return NULL;
    }
    item = &m_items[index];
    return item;
}

void MapData::setItemCardId(int index, bool isCard, int cardID)
{
    MapItem *item = getMapItem(index);
    if (item) {
        item->isCard = isCard;
        item->cardId = cardID;
//        qDebug() << "set Item Card id: " <<  isCard << " " << cardID;
    }
    return;
}

void MapData::setItemCardPos(int index, QVariantList pos)
{
    QVariant var;
    MapItem *item = getMapItem(index);
    int count = pos.count();
    if (count != 2) {
        qDebug() << "Bug: set " << index << " Item Card pos " << pos.count();
        return;
    }
    var = pos.at(0);
    item->cardPos[0] = var.toInt();
    var = pos.at(1);
    item->cardPos[1] = var.toInt();
//    qDebug() << "set Item Card Pos: " << index << " " << pos
//             << " " << item->cardPos[0] << " " << item->cardPos[1];
    return;
}
void MapData::setItemArc(int index, int isArc, QVariantList neighbourPos)
{
    QVariant var;
    MapItem *item = getMapItem(index);
    int i, count;
    count = neighbourPos.count();
    if (count > 4) {
        count = 4;
    }
    item->arcN = count;
    for (i = 0; i < count; i++) {
        var = neighbourPos.at(i);
        qDebug() << var.typeName() << " " << var;
        QVariantList vl;
        QVariant v;
        vl = var.toList();
        v = vl.at(0);
        item->arcNeighbour[i][0] = v.toInt();
        v = vl.at(1);
        item->arcNeighbour[i][1] = v.toInt();
    }
    item->isArc = isArc;
//    qDebug() << "set Item Arc: " << index << " " << neighbourPos
//             << " " << item->arcNeighbour[0][0] << " " << item->arcNeighbour[0][1]
//             << " " << item->arcNeighbour[1][0] << " " << item->arcNeighbour[1][1]
//             << " " << item->arcNeighbour[2][0] << " " << item->arcNeighbour[2][1]
//             << " " << item->arcNeighbour[3][0] << " " << item->arcNeighbour[3][1];
    return;
}
void MapData::setItemType(int index, int type)
{
    MapItem *item = getMapItem(index);
    if (item) {
        item->type = type;
    }
    return;
}

void MapData::setItemIsNeighbour(int index, bool isNeighbour)
{
    MapItem *item = getMapItem(index);
    if (item) {
        item->isNeighbour = isNeighbour;
    }
    return;
}

bool MapData::getItemIsNeighbour(int index)
{
    MapItem *item = getMapItem(index);
    if (item) {
        return item->isNeighbour;
    }
    return false;
}

int MapData::getItemCardId(int index)
{
    MapItem *item = getMapItem(index);
    if (item) {
        return item->cardId;
    }
    return 0;
}

int MapData::getItemIndexByCardId(int cardId)
{
    int index = -1;
    for (int i = 0; i < m_itemN; i++) {
        MapItem *item = getMapItem(i);
//        if (item == NULL) {
//            qDebug() << "BUG";
//        }
//        qDebug() << "index item " << item << " " << cardId;
        if (item->isCard && cardId == item->cardId) {
            index = i;
            break;
        }
    }
    return index;
}

bool MapData::getItemIsCard(int index)
{
    MapItem *item = getMapItem(index);
    if (item) {
        return item->isCard;
    }
    return false;
}

QVariantList MapData::getItemCardPos(int index)
{
    MapItem *item = getMapItem(index);
    QVariantList pos;
    QVariant var;
    if (item) {
        var = item->cardPos[0];
        pos.append(var);
        var = item->cardPos[1];
        pos.append(var);
    }
    return pos;
}

int MapData::getItemIsArc(int index)
{
    MapItem *item = getMapItem(index);
    if (item) {
        return item->isArc;
    }
    return 0;
}

QVariantList MapData::getItemArcNeighbour(int index)
{
    QVariantList a;
    return a;
}

int MapData::getItemType(int index)
{
    MapItem *item = getMapItem(index);
    if (item) {
        return item->type;
    }
    return 0;
}


int MapData::saveMapData(QString str)
{
    QFile file(str);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "saveMapData: Can not open " + str + "!";
        return -1;
    }
    QJsonObject rootJsonObj;
    QJsonArray itemArray;
    for (int i = 0; i < m_itemN; i++) {
        QJsonObject itemObj;
        itemObj["index"] = m_items[i].index;
        itemObj["cardId"] = m_items[i].cardId;
        itemObj["arcN"] = m_items[i].arcN;
        itemObj["type"] = m_items[i].type;
        itemObj["isCard"] = m_items[i].isCard;
        itemObj["isArc"] = m_items[i].isArc;
        itemObj["isNeighbour"] = m_items[i].isNeighbour;
        {
            QJsonArray posArray;
            posArray.append(m_items[i].pos[0]);
            posArray.append(m_items[i].pos[1]);
            itemObj["pos"] = posArray;
        }
        {
            QJsonArray neighbourArray;
            for (int j = 0; j < 4; j++) {
                QJsonArray childArray;
                childArray.append(m_items[i].arcNeighbour[j][0]);
                childArray.append(m_items[i].arcNeighbour[j][1]);
                neighbourArray.append(childArray);
            }
            itemObj["arcNeighbour"] = neighbourArray;
        }
        {
            QJsonArray posArray;
            posArray.append(m_items[i].cardPos[0]);
            posArray.append(m_items[i].cardPos[1]);
            itemObj["cardPos"] = posArray;
        }
        itemArray.append(itemObj);
    }
    rootJsonObj["items"] = itemArray;
    rootJsonObj["rows"] = m_rows;
    rootJsonObj["cols"] = m_cols;
    QJsonDocument jsonDoc(rootJsonObj);
    file.write(jsonDoc.toJson());
    file.close();
    return 0;
}

int MapData::loadMapData(QString str)
{
    QFile file(str);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "loadMapData: Can not open " + str + "!";
        return -1;
    }
    QTextStream in(&file);
    QString strJson = in.readAll();
    file.close();
    QByteArray byteArray = strJson.toUtf8();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(byteArray);
    if (jsonDoc.isNull()) {
        qDebug() << "load Json Doc error";
        return -2;
    }
    QJsonObject rootJsonObj = jsonDoc.object();
    if (rootJsonObj.empty()) {
        qDebug() << "root Json Object empty";
        return -3;
    }
    int rows, cols;
    QJsonValue jVal = rootJsonObj["rows"];
    if (jVal.isUndefined()) {
        qDebug() << "mapFile: undefine rows";
        rows = 20;
    } else {
        rows = jVal.toInt(20);
    }
    jVal = rootJsonObj["cols"];
    if (jVal.isUndefined()) {
        cols = 20;
    } else {
        cols = jVal.toInt(20);
    }
    if (cols <= 0 || rows <= 0) {
        return -4;
    }
    qDebug() << cols << " " << rows << " " << m_cols << " " << m_rows;
    if (cols > m_cols || rows > m_rows) {
        int r = (rows < m_rows) ? m_rows : rows;
        int c = (cols < m_cols) ? m_cols : cols;
        initItems(r, c);
        qDebug() << "load map data: " << c << " " << r;
    }
    QJsonValue itemsVal = rootJsonObj["items"];
    if (!itemsVal.isArray()) {
        qDebug() << "Error itemsVal is not array";
        return -4;
    }
    QJsonArray itemsArray = itemsVal.toArray();
    if (itemsArray.isEmpty()) {
        return -5;
    }
    int itemsCount = itemsArray.count();
    for (int i = 0; i < itemsCount; i++) {
        QJsonObject itemObj = itemsArray.at(i).toObject();
//        int index = itemObj["index"].toInt(-1);
//        if (index < 0 || index >= m_itemN) {
//            qDebug() << "Bug Index out range.";
//            return -6;
//        }
        QJsonValue posVal = itemObj["pos"];
        if (posVal.isArray() == false) {
            continue;
        }
        QJsonArray posArray = posVal.toArray();
        int x = posArray[0].toInt();
        int y = posArray[1].toInt();
        int index = x * m_cols + y;
        MapItem *mItem = &m_items[index];
//        mItem->index = index;
//        mItem->pos[0] = x;
//        mItem->pos[1] = y;
        mItem->cardId = itemObj["cardId"].toInt();
        mItem->cardPos[0] = itemObj["cardPos"].toArray().at(0).toInt();
        mItem->cardPos[1] = itemObj["cardPos"].toArray().at(1).toInt();
        mItem->type = itemObj["type"].toInt();
        mItem->arcN = itemObj["arcN"].toInt();
        mItem->isNeighbour = itemObj["isNeighbour"].toBool();
        mItem->arcNeighbour[0][0] = itemObj["arcNeighbour"].toArray().at(0).toArray().at(0).toInt();
        mItem->arcNeighbour[0][1] = itemObj["arcNeighbour"].toArray().at(0).toArray().at(1).toInt();
        mItem->arcNeighbour[1][0] = itemObj["arcNeighbour"].toArray().at(1).toArray().at(0).toInt();
        mItem->arcNeighbour[1][1] = itemObj["arcNeighbour"].toArray().at(1).toArray().at(1).toInt();
        mItem->arcNeighbour[2][0] = itemObj["arcNeighbour"].toArray().at(2).toArray().at(0).toInt();
        mItem->arcNeighbour[2][1] = itemObj["arcNeighbour"].toArray().at(2).toArray().at(1).toInt();
        mItem->arcNeighbour[3][0] = itemObj["arcNeighbour"].toArray().at(3).toArray().at(0).toInt();
        mItem->arcNeighbour[3][1] = itemObj["arcNeighbour"].toArray().at(3).toArray().at(1).toInt();
        mItem->isCard = itemObj["isCard"].toBool();
        mItem->isArc = itemObj["isArc"].toInt();
    }
    return 0;
}
