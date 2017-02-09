#ifndef MAPITEMTYPE_H
#define MAPITEMTYPE_H

#include <QObject>

class MapItemType : public QObject
{
    Q_OBJECT
    Q_ENUMS(ItemType)
    Q_ENUMS(ArcType)
    Q_ENUMS(ActType)
public:
    explicit MapItemType(QObject *parent = 0);
    ~MapItemType();
    enum ItemType {
        MapItemNULL,
        MapItemXLine,
        MapItemYLine,
        MapItemCross,
        MapItemXLStop,
        MapItemXRStop,
        MapItemYUStop,
        MapItemYDStop,
        MapItemXLMStop,
        MapItemXRMStop,
        MapItemYUMStop,
        MapItemYDMStop
    };
    enum ArcType {
        ArcNULL,
        ArcXLU,
        ArcXLD,
        ArcXRU,
        ArcXRD,
        ArcYLU,
        ArcYLD,
        ArcYRU,
        ArcYRD
    };
    enum ActType {
        ActNULL,
        ActAStop,
        ActMF,
        ActMB,
        ActRCW,
        ActRCCW,
        ActPlatform,
        ActOA,
        ActCharge
    };

signals:

public slots:
};

#endif // MAPITEMTYPE_H
