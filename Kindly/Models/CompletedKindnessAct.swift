import Foundation

struct CompletedKindnessAct: Codable, Identifiable {
    var id = UUID()
    var actId: String
    var title: String
    var dateCompleted: Date
    var userReflection: String?
    
    init(actId: String, title: String, dateCompleted: Date, userReflection: String? = nil) {
        self.actId = actId
        self.title = title
        self.dateCompleted = dateCompleted
        self.userReflection = userReflection
    }
}

struct MonthlySummary: Codable, Identifiable {
    var id = UUID()
    var month: Int
    var year: Int
    var totalActs: Int
    var longestStreak: Int
    var selectedActs: [CompletedKindnessAct]
    var growthMessage: String
    var dateGenerated: Date
    
    var monthName: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        
        var components = DateComponents()
        components.month = month
        components.year = year
        
        if let date = Calendar.current.date(from: components) {
            return dateFormatter.string(from: date)
        }
        return ""
    }
} 