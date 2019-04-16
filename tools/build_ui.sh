#!/bin/bash
#
# generate python files based on the designer ui files. pyuic5 and pyrcc5
# should be on the path.
#

set -e

if [ ! -d "designer" ]
then
    echo "Please run this from the project root"
    exit
fi

mkdir -p aqt/forms

init=aqt/forms/__init__.py
temp=aqt/forms/scratch
rm -f $init $temp
echo "# This file auto-generated by build_ui.sh. Don't edit." > $init
echo "__all__ = [" >> $init

echo "Generating forms.."
for i in designer/*.ui
do
    base=$(basename $i .ui)
    py="aqt/forms/${base}.py"
    echo "	\"$base\"," >> $init
    echo "from . import $base" >> $temp
    if [ $i -nt $py ]; then
        echo " * "$py
        pyuic5 --from-imports $i -o $py.tmp
        (cat <<EOF; tail -n +3 $py.tmp) |  perl -p -e 's/(QtGui\.QApplication\.)?_?translate\(".*?", /_(/; s/, None.*/))/' > $py
# -*- coding: utf-8 -*-
# pylint: disable=unsubscriptable-object,unused-import
from anki.lang import _
EOF
        rm $py.tmp
    fi
done
echo "]" >> $init
cat $temp >> $init
rm $temp

echo "Building resources.."
#pyrcc5 designer/icons.qrc -o aqt/forms/icons_rc.py
/usr/bin/pyrcc5 designer/icons.qrc -o aqt/forms/icons_rc.py
