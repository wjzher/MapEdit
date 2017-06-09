#include "pycal.h"

PyCal::PyCal(QObject *parent) : QObject(parent)
{
    m_pySuccess = false;
    m_module = NULL;
    m_funcCircle2 = NULL;
    // 初始化Python解释器
    Py_Initialize();
    if (!Py_IsInitialized()) {
        qDebug() << "error Py_Initialize ...";
        return;
    }

    // 执行单句Python语句，用于给出调用模块的路径，否则将无法找到相应的调用模块
    PyRun_SimpleString("import sys");
    PyRun_SimpleString("sys.path.append('./')");

    // 获取qt_python_fun.py模块的指针
    m_module = PyImport_ImportModule("cal");
    if (!m_module) {
        qDebug() << "Can't open python cal file";
        return;
    }

    // 获取circle2函数的指针
    m_funcCircle2 = PyObject_GetAttrString(m_module, "circle2");
    if (!m_funcCircle2){
        qDebug() << "Get function circle2 failed";
        return;
    }
    m_pySuccess = true;
    qDebug() << "PyCal init success";
}

PyCal::~PyCal()
{
    // 释放资源
    if (m_funcCircle2)
        Py_DECREF(m_funcCircle2);
    if (m_module)
        Py_DECREF(m_module);
    // 销毁Python解释器
    if (Py_IsInitialized())
        Py_Finalize();
    m_pySuccess = false;
}

QVariantList PyCal::callCircle2(QVariantList pos)
{
    QVariantList res;
    if (pos.count() != 3 || m_pySuccess == false) {
        qDebug() << "callCircle2 param error";
        return res;
    }
    double x0 = pos.at(0).toDouble();
    double y0 = pos.at(1).toDouble();
    double l = pos.at(2).toDouble();
    qDebug() << "callCircle2 get x0 " << x0 << ", y0 " << y0 << ", l " << l;
    PyObject *pArgs = PyTuple_New(3);
    PyTuple_SetItem(pArgs, 0, Py_BuildValue("d", x0));
    PyTuple_SetItem(pArgs, 1, Py_BuildValue("d", y0));
    PyTuple_SetItem(pArgs, 2, Py_BuildValue("d", l));
    PyObject *pRes = PyObject_CallObject(m_funcCircle2, pArgs);
    Py_DECREF(pArgs);
    if (pRes == NULL) {
        qDebug() << "PyObject_CallObject return NULL";
        return res;
    }
    if (!PyList_Check(pRes)) {
        qDebug() << "PyObject_CallObject not return List";
        Py_DECREF(pRes);
        return res;
    }
    int n = PyList_Size(pRes);
    int i;
    for (i = 0; i < n; i++) {
        PyObject *tmp = PyList_GetItem(pRes, i);
        double x, y;
        if (tmp == NULL) {
            qDebug() << "PyList_GetItem (" << i << ") failed";
            Py_DECREF(pRes);
            return QVariantList();
        }
        PyArg_ParseTuple(tmp, "dd", &x, &y);
        QVariantList v;
        v.append(QVariant(x));
        v.append(QVariant(y));
        res.append(v);
        Py_DECREF(tmp);
    }
    Py_DECREF(pRes);
    return res;
}
