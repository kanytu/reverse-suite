#!/bin/bash

BASEDIR="$(dirname $0)/../"

read -p "Drag apk..." APK
OUT="$BASEDIR/output/output.jar"

[[ -f "$OUT" ]] && rm -f "$OUT"

sh "$BASEDIR/tools/dex2jar/d2j-dex2jar.sh" -f -o "$OUT" "$APK"
java -jar "$BASEDIR/tools/gui/luyten.jar" "$OUT" &