#!/usr/bin/env python3
# Copyright (c) 2026 Rezoss
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Keep every smali*/ folder of a decoded APK/JAR under the 64K dex reference
# limits. Patches and mods add references to the source firmware's dex files,
# and when a dex is already close to the limit apktool fails with
# "Unsigned short value out of range". Classes are moved (descriptor unchanged)
# from an overflowing smali dir into a new smali_classesN dir.
#
# Usage: rebalance_dex.py <apktool output dir>

import os
import re
import sys

LIMIT = 65000  # leave headroom below 65535 for refs the regexes may miss

METHOD_REF = re.compile(r'L[^;\s]+;->[^\s(:]+\([^)\s]*\)\S+')
FIELD_REF = re.compile(r'L[^;\s]+;->[^\s(:]+:\S+')
CLASS_DEF = re.compile(r'^\.class\b.*?(L[^;\s]+;)', re.M)
METHOD_DEF = re.compile(r'^\.method\b.*?\s(\S+\([^)]*\)\S+)\s*$', re.M)
FIELD_DEF = re.compile(r'^\.field\b.*?\s([^\s:]+:[^\s=]+)', re.M)


def class_refs(path):
    with open(path, encoding='utf-8', errors='replace') as f:
        text = f.read()
    m = CLASS_DEF.search(text)
    cls = m.group(1) if m else None
    methods = set(METHOD_REF.findall(text))
    fields = set(FIELD_REF.findall(text))
    if cls:
        methods.update(cls + '->' + d for d in METHOD_DEF.findall(text))
        fields.update(cls + '->' + d for d in FIELD_DEF.findall(text))
    return methods, fields


def scan(smali_dir):
    files = {}
    for root, _, names in os.walk(smali_dir):
        for n in names:
            if n.endswith('.smali'):
                p = os.path.join(root, n)
                files[p] = class_refs(p)
    return files


def counts(files):
    m, f = {}, {}
    for methods, fields in files.values():
        for r in methods:
            m[r] = m.get(r, 0) + 1
        for r in fields:
            f[r] = f.get(r, 0) + 1
    return m, f


def next_dex_dir(base):
    idx = 2
    while os.path.exists(os.path.join(base, 'smali_classes%d' % idx)):
        idx += 1
    return os.path.join(base, 'smali_classes%d' % idx)


def rebalance(base):
    dirs = sorted(d for d in os.listdir(base)
                  if (d == 'smali' or d.startswith('smali_classes'))
                  and os.path.isdir(os.path.join(base, d)))
    for d in dirs:
        smali_dir = os.path.join(base, d)
        files = scan(smali_dir)
        m_cnt, f_cnt = counts(files)
        if len(m_cnt) <= LIMIT and len(f_cnt) <= LIMIT:
            continue
        print('%s: %d method refs, %d field refs (limit %d), rebalancing'
              % (d, len(m_cnt), len(f_cnt), LIMIT))
        # Score: refs that only this class uses, i.e. refs the dex loses when
        # the class leaves. Move the best classes first.
        def gain(item):
            methods, fields = item[1]
            return (sum(1 for r in methods if m_cnt[r] == 1)
                    + sum(1 for r in fields if f_cnt[r] == 1))
        dest = next_dex_dir(base)
        moved = 0
        for path, (methods, fields) in sorted(files.items(), key=gain, reverse=True):
            if len(m_cnt) <= LIMIT and len(f_cnt) <= LIMIT:
                break
            for r in methods:
                m_cnt[r] -= 1
                if not m_cnt[r]:
                    del m_cnt[r]
            for r in fields:
                f_cnt[r] -= 1
                if not f_cnt[r]:
                    del f_cnt[r]
            rel = os.path.relpath(path, smali_dir)
            os.makedirs(os.path.dirname(os.path.join(dest, rel)), exist_ok=True)
            os.rename(path, os.path.join(dest, rel))
            moved += 1
        print('  moved %d classes to %s (now %d method / %d field refs)'
              % (moved, os.path.basename(dest), len(m_cnt), len(f_cnt)))


if __name__ == '__main__':
    if len(sys.argv) != 2 or not os.path.isdir(sys.argv[1]):
        sys.exit('usage: rebalance_dex.py <apktool output dir>')
    rebalance(sys.argv[1])
