import Foundation

struct KindnessAct: Identifiable, Codable, Equatable {
    var id: String
    var title: String
    var description: String?
    var isCustom: Bool
    
    static func == (lhs: KindnessAct, rhs: KindnessAct) -> Bool {
        lhs.id == rhs.id
    }
}

struct KindnessActsResponse: Codable {
    var acts: [KindnessAct]
}

struct CompletedAct: Codable, Identifiable {
    var id: UUID = UUID()
    var actId: String
    var date: Date
} 