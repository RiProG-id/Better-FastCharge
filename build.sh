#!/bin/sh
set -e
PROJECT_DIR=$(dirname "$(realpath "$0")")
MODULE_DIR="$PROJECT_DIR/module"
BUILD_DIR="$PROJECT_DIR/build"
if [ ! -d "$MODULE_DIR" ]; then
	echo "Error: Module directory not found."
	exit 1
fi
if [ ! -f "$MODULE_DIR/module.prop" ]; then
	echo "Error: module.prop not found."
	exit 1
fi
if ! command -v zip >/dev/null 2>&1; then
	echo "Error: 'zip' command not found." >&2
	exit 1
fi
MODULE_VERSION=$(sed -n 's/^version=//p' "$MODULE_DIR/module.prop" | head -n 1)
[ -n "$MODULE_VERSION" ] || MODULE_VERSION="Unknown"
OUTPUT_ZIP="$BUILD_DIR/Better-FastCharge-$MODULE_VERSION.zip"
mkdir -p "$BUILD_DIR"
echo "Project directory : $PROJECT_DIR"
echo "Module directory  : $MODULE_DIR"
echo "Build directory   : $BUILD_DIR"
echo "Module version    : $MODULE_VERSION"
echo "Preparing module package..."
rm -f "$OUTPUT_ZIP"
cd "$MODULE_DIR"
zip -r9 "$OUTPUT_ZIP" .
echo "----------------------------------------"
echo "Module package created successfully:"
echo "$OUTPUT_ZIP"
