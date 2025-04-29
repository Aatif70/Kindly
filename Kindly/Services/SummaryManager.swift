import Foundation
import SwiftUI

class SummaryManager: ObservableObject {
    @Published var currentMonthlySummary: MonthlySummary?
    @Published var pastSummaries: [MonthlySummary] = []
    @Published var shouldShowMonthlySummary = false
    
    @AppStorage("lastSummaryMonth") private var lastSummaryMonth: Int = 0
    @AppStorage("lastSummaryYear") private var lastSummaryYear: Int = 0
    @AppStorage("monthlySummaries") private var monthlySummariesData: Data?
    
    private let calendar = Calendar.current
    private let kindnessService: KindnessService
    private let streakTracker: StreakTracker
    
    init(kindnessService: KindnessService, streakTracker: StreakTracker) {
        self.kindnessService = kindnessService
        self.streakTracker = streakTracker
        
        loadSummaries()
        checkIfShouldShowSummary()
    }
    
    // Load existing summaries
    private func loadSummaries() {
        guard let data = monthlySummariesData else { return }
        
        do {
            let decoder = JSONDecoder()
            pastSummaries = try decoder.decode([MonthlySummary].self, from: data)
        } catch {
            print("Error loading monthly summaries: \(error)")
        }
    }
    
    // Save summaries
    private func saveSummaries() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(pastSummaries)
            monthlySummariesData = data
        } catch {
            print("Error saving monthly summaries: \(error)")
        }
    }
    
    // Check if we should show the monthly summary
    func checkIfShouldShowSummary() {
        let today = Date()
        let components = calendar.dateComponents([.month, .year, .day], from: today)
        
        guard let currentMonth = components.month,
              let currentYear = components.year,
              let currentDay = components.day else { return }
        
        // Check if we're on the first day of a new month and haven't shown summary for previous month
        let isFirstDayOfMonth = currentDay == 1
        let isDifferentMonthThanLastSummary = currentMonth != lastSummaryMonth || currentYear != lastSummaryYear
        
        if isFirstDayOfMonth && isDifferentMonthThanLastSummary {
            // Calculate for previous month
            var previousMonthComponents = DateComponents()
            previousMonthComponents.month = currentMonth == 1 ? 12 : currentMonth - 1
            previousMonthComponents.year = currentMonth == 1 ? currentYear - 1 : currentYear
            
            generateMonthlySummary(month: previousMonthComponents.month!, year: previousMonthComponents.year!)
            shouldShowMonthlySummary = true
        }
    }
    
    // Generate a monthly summary for a specific month
    func generateMonthlySummary(month: Int, year: Int) {
        // Get completed acts from KindnessService
        let completedActs = kindnessService.getCompletedActs()
        
        // Filter acts for the specified month
        let filteredActs = completedActs.filter { act in
            let components = calendar.dateComponents([.month, .year], from: act.date)
            return components.month == month && components.year == year
        }
        
        guard !filteredActs.isEmpty else {
            // No acts for this month
            currentMonthlySummary = nil
            return
        }
        
        // Get acts details
        let completedKindnessActs = filteredActs.compactMap { completedAct -> CompletedKindnessAct? in
            guard let act = kindnessService.allActs.first(where: { $0.id == completedAct.actId }) else {
                return nil
            }
            
            return CompletedKindnessAct(
                actId: act.id,
                title: act.title,
                dateCompleted: completedAct.date,
                
            )
        }
        
        // Get longest streak for the month
        let longestStreak = streakTracker.getLongestStreak()
        
        // Generate growth message based on number of acts
        let totalActs = completedKindnessActs.count
        let growthMessage = generateGrowthMessage(totalActs: totalActs)
        
        // Select a subset of acts to highlight (up to 5)
        let selectedActs = selectNotableActs(from: completedKindnessActs)
        
        // Create the summary
        let summary = MonthlySummary(
            month: month,
            year: year,
            totalActs: totalActs,
            longestStreak: longestStreak,
            selectedActs: selectedActs,
            growthMessage: growthMessage,
            dateGenerated: Date()
        )
        
        // Update state
        currentMonthlySummary = summary
        
        // Add to past summaries if not already there
        if !pastSummaries.contains(where: { $0.month == month && $0.year == year }) {
            pastSummaries.append(summary)
            saveSummaries()
        }
        
        // Update last summary date
        lastSummaryMonth = month
        lastSummaryYear = year
    }
    
    // Generate a heartfelt growth message based on activity level
    private func generateGrowthMessage(totalActs: Int) -> String {
        if totalActs < 5 {
            return "Every small act of kindness you shared made a big difference 🌸"
        } else if totalActs < 10 {
            return "Your kind actions have started to create ripples of positivity 🌊"
        } else if totalActs < 15 {
            return "You steadily planted seeds of kindness all month 🌱"
        } else if totalActs < 20 {
            return "Your kindness garden is growing beautifully this month 🌿"
        } else {
            return "Your kindness bloomed and touched countless hearts 🌷✨"
        }
    }
    
    // Select up to 5 notable acts to highlight
    private func selectNotableActs(from acts: [CompletedKindnessAct]) -> [CompletedKindnessAct] {
        // If we have 5 or fewer acts, return all of them
        if acts.count <= 5 {
            return acts
        }
        
        // Otherwise, select 5 random acts
        var selectedActs: [CompletedKindnessAct] = []
        var availableActs = acts
        
        for _ in 1...5 {
            if availableActs.isEmpty { break }
            
            let randomIndex = Int.random(in: 0..<availableActs.count)
            selectedActs.append(availableActs[randomIndex])
            availableActs.remove(at: randomIndex)
        }
        
        return selectedActs
    }
    
    // Mark that we've shown the summary
    func markSummaryAsShown() {
        shouldShowMonthlySummary = false
    }
} 
