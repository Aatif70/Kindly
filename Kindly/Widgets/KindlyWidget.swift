import WidgetKit
import SwiftUI

// MARK: - Color Extension for Widget
extension Color {
   
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> KindnessEntry {
        KindnessEntry(date: Date(), kindnessAct: "Be kind to someone today", isPlaceholder: true)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (KindnessEntry) -> Void) {
        let entry = KindnessEntry(date: Date(), kindnessAct: "Pay for the person behind you in line", isPlaceholder: false)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<KindnessEntry>) -> Void) {
        var entries: [KindnessEntry] = []
        let currentDate = Date()
        
        // Get today's kindness act from UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.com.aatif.Kindly")
        let todaysActTitle = userDefaults?.string(forKey: "widgetActTitle") ?? "Be kind to someone today"
        
        // Create an entry for the current day
        let entry = KindnessEntry(date: currentDate, kindnessAct: todaysActTitle, isPlaceholder: false)
        entries.append(entry)
        
        // Set up refresh for next day
        var refreshDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        refreshDate = Calendar.current.startOfDay(for: refreshDate)
        
        let timeline = Timeline(entries: entries, policy: .after(refreshDate))
        completion(timeline)
    }
}

struct KindnessEntry: TimelineEntry {
    let date: Date
    let kindnessAct: String
    let isPlaceholder: Bool
}

struct KindlyWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        ZStack {
            Color(hex: "FDE2E4")
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                Text("Today's Kindness")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color(hex: "333333").opacity(0.7))
                
                Spacer()
                
                Text(entry.kindnessAct)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "333333"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "FACBD6"))
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
        }
    }
}

struct KindlyWidget: Widget {
    let kind: String = "KindlyWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            KindlyWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today's Kindness")
        .description("See your daily act of kindness")
        .supportedFamilies([.systemSmall])
    }
}

struct KindlyWidgetBundle: WidgetBundle {
    var body: some Widget {
        KindlyWidget()
    }
}

struct KindlyWidget_Previews: PreviewProvider {
    static var previews: some View {
        KindlyWidgetEntryView(entry: KindnessEntry(date: Date(), kindnessAct: "Pay for the person behind you in line", isPlaceholder: false))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
} 
