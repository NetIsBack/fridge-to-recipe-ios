//
//  Fridge_to_Recipe_LiveLiveActivity.swift
//  Fridge-to-Recipe Live
//
//  Created by Xcode Account on 10/8/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct Fridge_to_Recipe_LiveAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct Fridge_to_Recipe_LiveLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: Fridge_to_Recipe_LiveAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension Fridge_to_Recipe_LiveAttributes {
    fileprivate static var preview: Fridge_to_Recipe_LiveAttributes {
        Fridge_to_Recipe_LiveAttributes(name: "World")
    }
}

extension Fridge_to_Recipe_LiveAttributes.ContentState {
    fileprivate static var smiley: Fridge_to_Recipe_LiveAttributes.ContentState {
        Fridge_to_Recipe_LiveAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: Fridge_to_Recipe_LiveAttributes.ContentState {
         Fridge_to_Recipe_LiveAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: Fridge_to_Recipe_LiveAttributes.preview) {
   Fridge_to_Recipe_LiveLiveActivity()
} contentStates: {
    Fridge_to_Recipe_LiveAttributes.ContentState.smiley
    Fridge_to_Recipe_LiveAttributes.ContentState.starEyes
}
