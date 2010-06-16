#!/bin/bash

rm -Rf dist
mkdir dist
cp jdbvim dist/jdbvim.sample
cp install.sh dist
mkdir dist/plugin
cp jdbvim.vim dist/plugin
cp functions.tcl dist
cd dist
sed -e "/FUNCTION/,/FUNCTION/H" -e "/FUNCTION/,/FUNCTION/b" -e "d" functions.tcl > functions.tcl_clean
sed -e "/source functions/r functions.tcl_clean" -e "/source functions/d" jdbvim.sample > jdbvim
rm jdbvim.sample
rm functions.tcl
rm functions.tcl_clean
chmod +x jdbvim
#sed -e "s/souce functions\.tcl/$value" jdbvim
cd ..
# vim: sw=4 ts=4 ai expandtab
