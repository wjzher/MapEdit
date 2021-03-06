﻿#ifndef MAPDATA_H
#define MAPDATA_H

#include <QObject>
#include <qvariant.h>
#include "MapItemType.h"

struct MapItem {
    int index;      // 元素索引
    int pos[2];     // 元素位置, [0] 行 [1] 列
    int cardId;     // ID卡号
    int cardPos[2]; // ID卡在图形中的位置
    bool isCard;    // 是否存在ID卡
    int type;       // 图形类型
    int isArc;      // 是否存在弧线
    int arcNeighbour[4][2]; // 弧线相邻元素相对坐标
    int arcN;
    bool isNeighbour;
    bool cutLeftUp;     // 是否去掉左/上半条线
    bool cutRightDown;  // 是否去掉右/下半条线
    bool cutMagStop;  // 是否去掉精确停止时多余的线段
};

class MapData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int rows READ rows WRITE setRows NOTIFY rowsChanged)
    Q_PROPERTY(int cols READ cols WRITE setCols NOTIFY colsChanged)
public:
    explicit MapData(QObject *parent = 0);
    ~MapData();
    int rows() const;
    int cols() const;
    Q_INVOKABLE void setItemCardId(int index, bool isCard, int cardID);
    Q_INVOKABLE void setItemCardPos(int index, QVariantList pos);
    Q_INVOKABLE void setItemArc(int index, int isArc, QVariantList neighbourPos);
    Q_INVOKABLE void setItemType(int index, int type);
    Q_INVOKABLE void setItemCutLeftUp(int index, bool isChecked);
    Q_INVOKABLE void setItemCutRightDown(int index, bool isChecked);
    Q_INVOKABLE void setItemCutMagStop(int index, bool isChecked);
    Q_INVOKABLE void setItemIsNeighbour(int index, bool isNeighbour);
    Q_INVOKABLE int getItemCardId(int index);
    Q_INVOKABLE bool getItemIsCard(int index);
    Q_INVOKABLE bool getItemIsNeighbour(int index);
    Q_INVOKABLE QVariantList getItemCardPos(int index);
    Q_INVOKABLE int getItemIsArc(int index);
    Q_INVOKABLE QVariantList getItemArcNeighbour(int index);
    Q_INVOKABLE int getItemType(int index);
    Q_INVOKABLE bool getItemCutLeftUp(int index);
    Q_INVOKABLE bool getItemCutRightDown(int index);
    Q_INVOKABLE bool getItemCutMagStop(int index);
    Q_INVOKABLE int saveMapData(QString str);
    Q_INVOKABLE int loadMapData(QString str);
    Q_INVOKABLE void initItems();
    Q_INVOKABLE int getItemIndexByCardId(int cardId);
    Q_INVOKABLE int resize(int rows, int cols);
    Q_INVOKABLE int leftmove();
    Q_INVOKABLE int rightmove();
    Q_INVOKABLE int upmove();
    Q_INVOKABLE int downmove();
private:
    MapItem *getMapItem(int index);
    void initItems(int rows, int cols);

signals:
    void rowsChanged(int arg);
    void colsChanged(int arg);

public slots:
    void setRows(int arg);
    void setCols(int arg);

private:
    int m_rows;
    int m_cols;
    int m_itemN;
    MapItem *m_items;
};

#endif // MAPDATA_H
