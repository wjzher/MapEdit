#ifndef MAPITEMTYPE_H
#define MAPITEMTYPE_H

#include <QObject>

class MapItemType : public QObject
{
    Q_OBJECT
    Q_ENUMS(ItemType)
public:
    explicit MapItemType(QObject *parent = 0);
    ~MapItemType();
    enum ItemType {
        MapItemNULL,
        MapItemXLine,
        MapItemYLine,
        MapItemCross,
        MapItemStop
    };

signals:

public slots:
};

#endif // MAPITEMTYPE_H
