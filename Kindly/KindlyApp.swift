//
//  KindlyApp.swift
//  Kindly
//
//  Created by Aatif Ahmed on 4/28/25.
//

import SwiftUI

@main
struct KindlyApp: App {
    // StateObject declarations with direct initialization
    @StateObject private var kindnessService = KindnessService()
    @StateObject private var streakTracker = StreakTracker()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var summaryManager: SummaryManager
    
    @State private var showingMonthlySummary = false
    
    init() {
        // Initialize SummaryManager with the other services
        // Using underscore to access the projected value of the property wrappers
        let summaryManagerInstance = SummaryManager(
            kindnessService: _kindnessService.wrappedValue,
            streakTracker: _streakTracker.wrappedValue
        )
        
        // Initialize summaryManager
        self._summaryManager = StateObject(wrappedValue: summaryManagerInstance)
        
        // Configure appearance after all properties are initialized
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(KindlyColors.warmWhite)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(KindlyColors.primaryPink)]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color(hex: "333333"))]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .environmentObject(kindnessService)
                    .environmentObject(streakTracker)
                    .environmentObject(notificationManager)
                    .environmentObject(summaryManager)
                    .preferredColorScheme(.light)
                    .onAppear {
                        notificationManager.requestAuthorization()
                        
                        // Check if we should show the monthly summary
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            // Only check after a brief delay to allow app to fully load
                            showingMonthlySummary = summaryManager.shouldShowMonthlySummary
                        }
                    }
                    .onChange(of: summaryManager.shouldShowMonthlySummary) { newValue in
                        showingMonthlySummary = newValue
                    }
            }
            .sheet(isPresented: $showingMonthlySummary) {
                MonthlySummaryView(summaryManager: summaryManager)
                    .interactiveDismissDisabled()
            }
        }
    }
}
