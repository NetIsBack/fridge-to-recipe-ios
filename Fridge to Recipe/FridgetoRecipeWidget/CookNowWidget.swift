import WidgetKit
import SwiftUI

struct CookNowWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "CookNowWidget", provider: CookNowWidgetProvider()) { entry in
            CookNowWidgetView(entry: entry)
        }
        .configurationDisplayName("Cooking Timer")
        .description("Shows your current cooking progress")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct CookNowWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> CookNowWidgetEntry {
        CookNowWidgetEntry(date: Date(), recipeName: "Pasta Carbonara", stepName: "Boil water", stepIndex: 1, totalSteps: 5, timeRemaining: 120, isPaused: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (CookNowWidgetEntry) -> ()) {
        let entry = CookNowWidgetEntry(date: Date(), recipeName: "Pasta Carbonara", stepName: "Boil water", stepIndex: 1, totalSteps: 5, timeRemaining: 120, isPaused: false)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // For now, return a simple timeline
        let entry = CookNowWidgetEntry(date: Date(), recipeName: "Pasta Carbonara", stepName: "Boil water", stepIndex: 1, totalSteps: 5, timeRemaining: 120, isPaused: false)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct CookNowWidgetEntry: TimelineEntry {
    let date: Date
    let recipeName: String
    let stepName: String
    let stepIndex: Int
    let totalSteps: Int
    let timeRemaining: TimeInterval
    let isPaused: Bool
}

struct CookNowWidgetView: View {
    let entry: CookNowWidgetEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // Recipe name
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundColor(.orange)
                    .font(.title2)
                Text(entry.recipeName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            
            // Current step info
            Text("Step \(entry.stepIndex) of \(entry.totalSteps)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Current step name
            Text(entry.stepName)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            // Timer display
            Text(timeString(from: entry.timeRemaining))
                .font(.system(size: 24, weight: .bold, design: .monospaced))
                .foregroundColor(.orange)
            
            // Pause status
            if entry.isPaused {
                HStack(spacing: 4) {
                    Image(systemName: "pause.circle.fill")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text("Paused")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview(as: .systemSmall) {
    CookNowWidget()
} timeline: {
    CookNowWidgetEntry(date: Date(), recipeName: "Pasta Carbonara", stepName: "Boil water", stepIndex: 1, totalSteps: 5, timeRemaining: 120, isPaused: false)
}
