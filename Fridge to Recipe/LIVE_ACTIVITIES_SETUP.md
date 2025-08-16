# Live Activities Setup Guide

## Overview
This guide explains how to properly set up Live Activities for the Fridge to Recipe app, following the correct implementation pattern from the YouTube video.

## Key Changes Made

### 1. Updated Info.plist
- Added `NSSupportsLiveActivities` and `NSSupportsLiveActivitiesFrequentUpdates`
- Added `remote-notification` to background modes

### 2. Created Proper Widget Extension
- `CookNowWidget.swift` - Main widget implementation
- `WidgetInfo.plist` - Widget extension configuration
- `WidgetEntitlements.entitlements` - Widget entitlements

### 3. Updated Live Activity Attributes
- Added `isPaused` state to track pause/resume
- Improved error handling and logging

### 4. Enhanced Timer Manager
- Better Live Activity integration
- Proper state management
- Optimized update frequency

## Xcode Project Setup

### Step 1: Add Widget Extension Target
1. In Xcode, go to File → New → Target
2. Choose "Widget Extension"
3. Name it "CookNowWidgetExtension"
4. Make sure "Include Configuration Intent" is unchecked
5. Click "Finish"

### Step 2: Configure Widget Extension
1. Replace the generated widget code with `CookNowWidget.swift`
2. Update the widget's Info.plist with the contents from `WidgetInfo.plist`
3. Update the widget's entitlements with the contents from `WidgetEntitlements.entitlements`

### Step 3: Configure App Groups
1. In your main app target, go to Signing & Capabilities
2. Add "App Groups" capability
3. Add group: `group.com.onsys.fridgetorecipe`
4. Do the same for the widget extension target

### Step 4: Update Bundle Identifiers
- Main app: `com.onsys.fridgetorecipe`
- Widget extension: `com.onsys.fridgetorecipe.widget`

## Testing Live Activities

### 1. Build and Run
1. Build the main app target
2. Build the widget extension target
3. Run on a physical device (Live Activities don't work in simulator)

### 2. Test the Flow
1. Open the app
2. Navigate to a recipe
3. Tap "Cook Now"
4. Start the cooking process
5. Check for Live Activity on lock screen and Dynamic Island

### 3. Debugging
- Check Xcode console for Live Activity logs
- Use Console app on Mac to view system logs
- Test pause/resume functionality

## Common Issues and Solutions

### Issue: Live Activity doesn't appear
**Solution:**
- Ensure you're testing on a physical device
- Check that notifications are enabled
- Verify app groups are properly configured
- Check that the widget extension is built and included

### Issue: Live Activity appears but doesn't update
**Solution:**
- Check the update frequency in `CookNowTimerManager`
- Verify the content state is being updated correctly
- Check for any errors in the console

### Issue: Dynamic Island doesn't show expanded view
**Solution:**
- Ensure the Dynamic Island regions are properly configured
- Check that the content fits within the available space
- Test on iPhone 14 Pro or newer

## Key Implementation Details

### Activity Attributes
```swift
struct CookNowAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var stepName: String
        var stepIndex: Int
        var totalSteps: Int
        var timeRemaining: TimeInterval
        var isPaused: Bool
    }
    var recipeName: String
}
```

### Widget Configuration
```swift
ActivityConfiguration(for: CookNowAttributes.self) { context in
    // Lock screen UI
} dynamicIsland: { context in
    DynamicIsland {
        // Dynamic Island UI
    }
}
```

### Starting Live Activity
```swift
let attributes = CookNowAttributes(recipeName: recipeName)
let contentState = CookNowAttributes.ContentState(...)
activity = try Activity<CookNowAttributes>.request(
    attributes: attributes, 
    contentState: contentState, 
    pushType: nil
)
```

## Best Practices

1. **Update Frequency**: Don't update too frequently (every 5 seconds is good)
2. **Error Handling**: Always check for errors when starting/updating activities
3. **State Management**: Keep the content state in sync with your app state
4. **Testing**: Always test on physical devices
5. **User Experience**: Provide clear visual feedback for different states

## Resources
- [Apple's Live Activities Documentation](https://developer.apple.com/documentation/activitykit)
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [YouTube Tutorial](https://www.youtube.com/watch?v=mu9LlmUYC9E) 