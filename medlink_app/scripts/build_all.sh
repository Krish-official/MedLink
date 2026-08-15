#!/bin/bash

echo "🏗️  Building MedCare for all platforms..."

# Clean
echo "\n🧹 Cleaning..."
flutter clean
flutter pub get

# Generate code
echo "\n⚙️  Generating code..."
flutter pub run build_runner build --delete-conflicting-outputs

# Build Android
echo "\n📱 Building Android APK..."
flutter build apk --release --flavor prod --split-per-abi

echo "\n📦 Building Android App Bundle..."
flutter build appbundle --release --flavor prod

# Build iOS (on macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "\n🍎 Building iOS..."
    flutter build ios --release --flavor prod --no-codesign
else
    echo "\n⏭️  Skipping iOS build (not on macOS)"
fi

# Build Web
echo "\n🌐 Building Web..."
flutter build web --release

echo "\n✅ All builds complete!"
echo "\n📊 Build outputs:"
echo "  Android APK: build/app/outputs/flutter-apk/"
echo "  Android Bundle: build/app/outputs/bundle/prodRelease/"
echo "  iOS: build/ios/iphoneos/Runner.app"
echo "  Web: build/web/"