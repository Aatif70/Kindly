//
//  KindlyApp.swift
//  Kindly
//
//  Created by Aatif Ahmed on 4/28/25.
//

import SwiftUI

@main
struct KindlyApp: App {
    @StateObject private var kindnessService = KindnessService()
    @StateObject private var streakTracker = StreakTracker()
    @StateObject private var notificationManager = NotificationManager()
    
    init() {
        // Apply global app appearance settings
        configureAppAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(kindnessService)
                .environmentObject(streakTracker)
                .environmentObject(notificationManager)
                .preferredColorScheme(.light)
                .onAppear {
                    notificationManager.requestAuthorization()
                }
        }
    }
    
    private func configureAppAppearance() {
        // Configure navigation bar appearance
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = UIColor(KindlyColors.warmWhite)
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor(KindlyColors.primaryPink)]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color(hex: "333333"))]
        
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
    }
}
