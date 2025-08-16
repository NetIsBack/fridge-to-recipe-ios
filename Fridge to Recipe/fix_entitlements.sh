#!/bin/bash

echo "Checking entitlements for Live Activities..."

# Check main app entitlements
echo "Main app entitlements:"
if grep -q "com.apple.developer.activities" "Fridge to Recipe.entitlements"; then
    echo "✅ com.apple.developer.activities found in main app"
else
    echo "❌ com.apple.developer.activities missing in main app"
fi

# Check widget entitlements
echo "Widget entitlements:"
if grep -q "com.apple.developer.activities" "FridgetoRecipeWidget/FridgetoRecipeWidget.entitlements"; then
    echo "✅ com.apple.developer.activities found in widget"
else
    echo "❌ com.apple.developer.activities missing in widget"
fi

echo ""
echo "To fix the provisioning profile issue:"
echo "1. Go to Apple Developer Portal"
echo "2. Navigate to Certificates, Identifiers & Profiles"
echo "3. Go to Identifiers and find your app identifier"
echo "4. Enable Live Activities capability"
echo "5. Go to Profiles and regenerate your provisioning profile"
echo "6. In Xcode, try signing again" 