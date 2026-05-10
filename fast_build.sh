#!/bin/bash

# Druk Fast Build Script - v2 (Official China Mirror)
# 使用 Google 官方中国镜像站，确保引擎同步成功

echo "🚀 Starting optimized build with Official China Mirror..."

# 1. 设置 Google 官方为中国开发者提供的镜像
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

echo "🌐 Mirror environment set to flutter-io.cn (Official)."

# 2. 进入 Flutter 目录
cd Druk_Flutter

# 3. 清理缓存
echo "🧹 Cleaning project..."
flutter clean

# 4. 同步依赖
echo "📦 Fetching dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Failed to fetch packages."
    exit 1
fi

# 5. 执行构建
echo "🏗️ Building Debug APK (Ensuring Engine Download)..."
# 使用 --verbose 可以查看详细的引擎下载过程
flutter build apk --debug

if [ $? -eq 0 ]; then
    echo "✅ Build Successful!"
    echo "📍 APK Location: Druk_Flutter/build/app/outputs/flutter-apk/app-debug.apk"
else
    echo "❌ Build Failed. If it still fails, please check your network proxy settings."
    exit 1
fi
