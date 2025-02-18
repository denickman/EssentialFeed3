#!/bin/bash

echo "Now Current directory is:"
cd EssentialFeed
pwd
ls -la

xcodebuild clean build test \
  -workspace EssentialApp.xcworkspace \
  -scheme "CI_iOS" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  -sdk iphonesimulator \
  -destination "platform=iOS Simulator,name=iPhone 16,OS=latest"


