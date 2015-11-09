#!/bin/bash

BASEDIR="$(dirname $0)/../"

read -p "Drag apk..." APK
OUT="$BASEDIR/output/apk_source"

rm -rf "$OUT"

java -jar "$BASEDIR/tools/others/apktool.jar" d "$APK" -o "$OUT"