import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @EnvironmentObject var summaryManager: SummaryManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Today", systemImage: "heart.fill")
                }
                .tag(0)
            
            CalendarView()
                .tabItem {
                    Label("Streaks", systemImage: "calendar")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
        .accentColor(KindlyColors.primaryPink)
        .onAppear {
            // Style the tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.backgroundColor = UIColor(KindlyColors.warmWhite)
            appearance.shadowColor = UIColor.black.withAlphaComponent(0.05)
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(KindnessService())
        .environmentObject(StreakTracker())
        .environmentObject(NotificationManager())
        .environmentObject(SummaryManager(kindnessService: KindnessService(), streakTracker: StreakTracker()))
} 