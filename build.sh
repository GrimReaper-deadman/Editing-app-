#!/bin/bash
set -e

# Config
PROJECT_DIR="/data/data/com.termux/files/home/FluxForgeApp"
SDK_JAR="/data/data/com.termux/files/home/android.jar"
BUILD_DIR="$PROJECT_DIR/build"
SRC_DIR="$PROJECT_DIR/app/src/main"
RES_DIR="$SRC_DIR/res"
ASSETS_DIR="$SRC_DIR/assets"
MANIFEST="$SRC_DIR/AndroidManifest.xml"
PACKAGE="com.grimreaper.fluxforge"
KEYSTORE="$PROJECT_DIR/debug.keystore"
KEY_ALIAS="androiddebugkey"
KEY_PASS="android"
MIN_API=21

# Clean
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR/obj" "$BUILD_DIR/dex" "$BUILD_DIR/gen"

echo "1. Compiling resources..."
aapt2 compile --dir "$RES_DIR" -o "$BUILD_DIR/res.zip"

echo "2. Linking resources and generating R.java..."
aapt2 link --manifest "$MANIFEST" -I "$SDK_JAR" \
    --java "$BUILD_DIR/gen" \
    -A "$ASSETS_DIR" \
    -o "$BUILD_DIR/app-unsigned.apk" \
    "$BUILD_DIR/res.zip"

echo "3. Compiling Java sources..."
JAVA_FILES=$(find "$SRC_DIR/java" "$BUILD_DIR/gen" -name "*.java")
javac -source 1.8 -target 1.8 -d "$BUILD_DIR/obj" -classpath "$SDK_JAR" $JAVA_FILES

echo "4. Dexing classes..."
CLASS_FILES=$(find "$BUILD_DIR/obj" -name "*.class")
d8 --output "$BUILD_DIR/dex" $CLASS_FILES --lib "$SDK_JAR" --min-api $MIN_API

echo "5. Adding classes.dex to APK..."
cp "$BUILD_DIR/app-unsigned.apk" "$BUILD_DIR/app-with-dex.apk"
cd "$BUILD_DIR/dex"
zip -u "$BUILD_DIR/app-with-dex.apk" classes.dex
cd "$PROJECT_DIR"

echo "6. Zipaligning APK..."
zipalign -f 4 "$BUILD_DIR/app-with-dex.apk" "$BUILD_DIR/app-aligned.apk"

echo "7. Signing APK..."
apksigner sign --ks "$KEYSTORE" --ks-pass "pass:$KEY_PASS" --ks-key-alias "$KEY_ALIAS" \
    --v1-signing-enabled true --v2-signing-enabled true --v3-signing-enabled true \
    --out "$PROJECT_DIR/FluxForge.apk" "$BUILD_DIR/app-aligned.apk"

echo "Build complete! APK at $PROJECT_DIR/FluxForge.apk"
ls -l "$PROJECT_DIR/FluxForge.apk"
