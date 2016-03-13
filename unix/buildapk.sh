#!/bin/bash

BASEDIR="$(dirname $0)/../"
OUT="$BASEDIR/output/"
ORIGIN="$OUT/apk_source"
TEMPAPK="$OUT/temp.apk"
EXTR="$OUT/extracted"
FINAL="$OUT/generated-apk.apk"


find $ORIGIN -name '*.png' ! -name '*.9.png' | xargs $BASEDIR/tools/others/optipng -o5

java -jar "$BASEDIR/tools/others/apktool.jar" b "$ORIGIN" -o "$FINAL" > /dev/null

rm "$TEMPAPK"

"$BASEDIR/tools/others/zipalign" 4  "$FINAL" "$TEMPAPK"

java -jar "$BASEDIR/tools/others/signapk.jar" "$BASEDIR/tools/others/debugkey.x509.pem" "$BASEDIR/tools/others/debugkey.pk8" "$TEMPAPK" "$FINAL"

rm "$TEMPAPK"