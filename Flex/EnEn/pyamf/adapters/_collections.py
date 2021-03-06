# Copyright (c) 2007-2009 The PyAMF Project.
# See LICENSE.txt for details.

"""
collections adapter module.

@since: 0.5
"""

import collections

import pyamf
from pyamf.adapters import util


if hasattr(collections, 'deque'):
    pyamf.add_type(collections.deque, util.to_list)

if hasattr(collections, 'defaultdict'):
    pyamf.add_type(collections.defaultdict, util.to_dict)
