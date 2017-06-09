#ifndef PYCAL_H
#define PYCAL_H

#include <QObject>
#include <QDebug>
#ifdef _DEBUG
  #undef _DEBUG
  #include <Python.h>
  #define _DEBUG
#else
  #include <Python.h>
#endif

// 在程序中，只允许生成一个实例
class PyCal : public QObject
{
    Q_OBJECT
public:
    explicit PyCal(QObject *parent = 0);
    ~PyCal();
    Q_INVOKABLE QVariantList callCircle2(QVariantList pos);

signals:

public slots:
private:
    bool m_pySuccess;
    PyObject *m_module;
    PyObject *m_funcCircle2;    // 求解两个圆的交点, param (x0, y0)
};

#endif // PYCAL_H
