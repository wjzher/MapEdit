#include "mapData.h"
#include <QDebug>
#include <QFile>

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

void MapData::initItems()
{
    if (m_items) {
        delete [] m_items;
    }
    if (m_rows != 0 && m_cols != 0) {
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
        qDebug() << "set Item Card id: " <<  isCard << " " << cardID;
    }
    return;
}

void MapData::setItemCardPos(int index, QVariantList pos)
{
    QVariant var;
    MapItem *item = getMapItem(index);
    var = pos.at(0);
    item->cardPos[0] = var.toInt();
    var = pos.at(1);
    item->cardPos[1] = var.toInt();
    qDebug() << "set Item Card Pos: " << index << " " << pos
             << " " << item->cardPos[0] << " " << item->cardPos[1];
    return;
}
void MapData::setItemArc(int index, bool isArc, QVariantList neighbourPos)
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
    qDebug() << "set Item Arc: " << index << " " << neighbourPos
             << " " << item->arcNeighbour[0][0] << " " << item->arcNeighbour[0][1]
             << " " << item->arcNeighbour[1][0] << " " << item->arcNeighbour[1][1]
             << " " << item->arcNeighbour[2][0] << " " << item->arcNeighbour[2][1]
             << " " << item->arcNeighbour[3][0] << " " << item->arcNeighbour[3][1];
    return;
}
void MapData::setItemType(int index, int type)
{
    MapItem *item = getMapItem(index);
    if (item) {
        item->type = type;
        qDebug() << "set Item type: " <<  type;
    }
    return;
}

void MapData::saveMapData(QString str)
{
    QFile file(str);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qDebug() << "Can not open " + str + "!";
        return;
    }
    //file.write();
    file.close();
    return;
}
