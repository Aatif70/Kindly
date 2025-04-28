import Foundation
import SwiftUI

class StreakTracker: ObservableObject {
    @AppStorage("longestStreak") private var longestStreak: Int = 0
    @Published var completedDates: Set<Date> = []
    
    private let calendar = Calendar.current
    
    func updateCompletedDates(from completedActs: [CompletedAct]) {
        var dates = Set<Date>()
        
        for act in completedActs {
            let dayStart = calendar.startOfDay(for: act.date)
            dates.insert(dayStart)
        }
        
        completedDates = dates
    }
    
    func getLongestStreak() -> Int {
        return longestStreak
    }
    
    func updateLongestStreak(currentStreak: Int) {
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
    }
    
    func isDateCompleted(_ date: Date) -> Bool {
        let dayStart = calendar.startOfDay(for: date)
        return completedDates.contains(dayStart)
    }
    
    func getDaysInMonth(for date: Date) -> [Date] {
        let range = calendar.range(of: .day, in: .month, for: date)!
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: date))!
        
        return range.compactMap { day -> Date? in
            return calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
    }
    
    func resetStreak() {
        longestStreak = 0
        completedDates = []
    }
} 