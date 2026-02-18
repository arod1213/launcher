#!/bin/bash

# Configuration
APP_NAME="Launcher"
APP_IDENTIFIER="com.aidanrodriguez.launcher"
EXE_NAME="launcher"

# Build the app
zig build --release=small
# sudo zig build -Dtarget=x86_64-macos --release=small

# Create app bundle structure
mkdir -p ./${APP_NAME}.app/Contents/MacOS
mkdir -p ./${APP_NAME}.app/Contents/Resources

# Create Info.plist
cat > ./${APP_NAME}.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${EXE_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>${APP_IDENTIFIER}</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSDocumentsFolderUsageDescription</key>
    <string>This app needs access to your Documents folder to manage files.</string>
    <key>NSAppleEventsUsageDescription</key>
    <string>This app needs to listen to keyboard events for hotkey functionality.</string>
</dict>
</plist>
EOF

# Copy executable
cp ./zig-out/bin/${EXE_NAME} ./${APP_NAME}.app/Contents/MacOS/${EXE_NAME}
chmod +x ./${APP_NAME}.app/Contents/MacOS/${EXE_NAME}

# Code sign the app
# codesign --force --deep --sign - ./${APP_NAME}.app

echo "✓ App bundle created at ./${APP_NAME}.app"
cp -r ./${APP_NAME}.app /Applications/
# echo "To run: open ./${APP_NAME}.app"
