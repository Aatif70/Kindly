import Foundation
import Combine
import SwiftUI
import WidgetKit

class KindnessService: ObservableObject {
    @Published var todaysAct: KindnessAct?
    @Published var allActs: [KindnessAct] = []
    @Published var customActs: [KindnessAct] = []
    @Published var isActCompletedToday: Bool = false
    
    @AppStorage("customActs") private var customActsData: Data?
    @AppStorage("todaysActId") private var todaysActId: String?
    @AppStorage("lastUpdateDate") private var lastUpdateDateString: String?
    @AppStorage("completedActs") private var completedActsData: Data?
    
    private var completedActs: [CompletedAct] = []
    private let calendar = Calendar.current
    
    init() {
        loadCustomActs()
        loadCompletedActs()
        loadActsFromJSON()
        
        // Check if we need a new act for today
        checkAndUpdateTodaysAct()
    }
    
    // Load acts from the bundled JSON file
    private func loadActsFromJSON() {
        guard let url = Bundle.main.url(forResource: "kindness_acts", withExtension: "json") else {
            print("Error: Could not find kindness_acts.json in the bundle.")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let response = try decoder.decode(KindnessActsResponse.self, from: data)
            self.allActs = response.acts
            
            // Merge with custom acts
            self.allActs.append(contentsOf: customActs)
            
            // Set today's act if needed
            if let savedActId = todaysActId, let act = allActs.first(where: { $0.id == savedActId }) {
                self.todaysAct = act
                checkIfTodaysActIsCompleted()
                updateWidgetActTitle(act.title)
            }
        } catch {
            print("Error loading kindness acts: \(error)")
        }
    }
    
    // Load custom acts from UserDefaults
    private func loadCustomActs() {
        guard let data = customActsData else { return }
        
        do {
            let decoder = JSONDecoder()
            customActs = try decoder.decode([KindnessAct].self, from: data)
        } catch {
            print("Error loading custom acts: \(error)")
        }
    }
    
    // Load completed acts from UserDefaults
    private func loadCompletedActs() {
        guard let data = completedActsData else { return }
        
        do {
            let decoder = JSONDecoder()
            completedActs = try decoder.decode([CompletedAct].self, from: data)
        } catch {
            print("Error loading completed acts: \(error)")
        }
    }
    
    // Save the completed acts to UserDefaults
    private func saveCompletedActs() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(completedActs)
            completedActsData = data
        } catch {
            print("Error saving completed acts: \(error)")
        }
    }
    
    // Add a new custom act
    func addCustomAct(title: String, description: String? = nil) {
        let newId = UUID().uuidString
        let newAct = KindnessAct(id: newId, title: title, description: description, isCustom: true)
        
        customActs.append(newAct)
        allActs.append(newAct)
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(customActs)
            customActsData = data
        } catch {
            print("Error saving custom acts: \(error)")
        }
    }
    
    // Mark today's act as completed
    func completeAct(reflection: String? = nil) {
        guard let act = todaysAct else { return }
        
        let today = calendar.startOfDay(for: Date())
        
        // Check if already completed today
        let alreadyCompleted = completedActs.contains { completed in
            calendar.isDate(completed.date, inSameDayAs: today)
        }
        
        if !alreadyCompleted {
            let completedAct = CompletedAct(actId: act.id, date: today)
            completedActs.append(completedAct)
            saveCompletedActs()
            isActCompletedToday = true
        }
    }
    
    // Check if today's act has been completed
    private func checkIfTodaysActIsCompleted() {
        let today = calendar.startOfDay(for: Date())
        
        isActCompletedToday = completedActs.contains { completed in
            calendar.isDate(completed.date, inSameDayAs: today)
        }
    }
    
    // Select a new random act for today if needed
    private func checkAndUpdateTodaysAct() {
        let today = calendar.startOfDay(for: Date())
        let todayString = dateToString(today)
        
        // Check if we need a new act for today
        if lastUpdateDateString != todayString || todaysActId == nil || todaysAct == nil {
            selectNewRandomAct()
            lastUpdateDateString = todayString
            checkIfTodaysActIsCompleted()
        }
    }
    
    // Get a new random act, different from the current one
    private func selectNewRandomAct() {
        guard !allActs.isEmpty else { return }
        
        var filteredActs = allActs
        if let currentAct = todaysAct {
            filteredActs = allActs.filter { $0.id != currentAct.id }
        }
        
        // If we've used all acts, just pick randomly from all
        if filteredActs.isEmpty {
            filteredActs = allActs
        }
        
        // Randomly select an act
        let randomIndex = Int.random(in: 0..<filteredActs.count)
        todaysAct = filteredActs[randomIndex]
        todaysActId = todaysAct?.id
        
        // Update widget
        if let act = todaysAct {
            updateWidgetActTitle(act.title)
        }
    }
    
    // Update widget with today's act
    private func updateWidgetActTitle(_ title: String) {
        // Save to shared UserDefaults for the widget
        let userDefaults = UserDefaults(suiteName: "group.com.aatif.Kindly")
        userDefaults?.set(title, forKey: "widgetActTitle")
        userDefaults?.synchronize()
        
        // Request widget refresh
        #if os(iOS)
        WidgetCenter.shared.reloadAllTimelines()
        #endif
    }
    
    // Get all completed acts
    func getCompletedActs() -> [CompletedAct] {
        return completedActs
    }
    
    // Check if a specific date has a completed act
    func isDateCompleted(_ date: Date) -> Bool {
        let dayStart = calendar.startOfDay(for: date)
        return completedActs.contains { completed in
            calendar.isDate(completed.date, inSameDayAs: dayStart)
        }
    }
    
    // Get the current streak count
    func getCurrentStreak() -> Int {
        var streak = 0
        let today = calendar.startOfDay(for: Date())
        
        // Start checking from yesterday, going backwards
        var checkDate = calendar.date(byAdding: .day, value: -1, to: today)!
        
        while true {
            let completed = completedActs.contains { completed in
                calendar.isDate(completed.date, inSameDayAs: checkDate)
            }
            
            if completed {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        
        // Add today if completed
        if isActCompletedToday {
            streak += 1
        }
        
        return streak
    }
    
    // Reset all progress
    func resetProgress() {
        completedActs = []
        saveCompletedActs()
        isActCompletedToday = false
        selectNewRandomAct()
    }
    
    // Helper to convert date to string
    private func dateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
} 
