#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from sympy import *

def circle2(x0, y0, l):
    x = Symbol('x')
    y = Symbol('y')
    print(x0)
    print(y0)
    r = solve([x ** 2 + y ** 2 - 10000, (x - x0) ** 2 + (y - y0) ** 2 - l ** 2], [x, y])
    print(r)
    print([( float(r[0][0]), float(r[0][1]) ), ( float(r[1][0]), float(r[1][1]) )])
    return r
