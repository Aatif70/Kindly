import SwiftUI

struct MonthlySummaryView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var summaryManager: SummaryManager
    
    @State private var animateContent = false
    @State private var saveInProgress = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [KindlyColors.warmWhite, KindlyColors.subtlePink.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            // Actual content
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Text("Your Kindness Journey")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(Color(hex: "333333"))
                    
                    if let summary = summaryManager.currentMonthlySummary {
                        Text(summary.monthName + " " + String(summary.year))
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(KindlyColors.primaryPink)
                    }
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : -20)
                
                // Bloom animation
                if animateContent {
                    BloomAnimation(color: KindlyColors.primaryPink.opacity(0.8))
                        .frame(width: 120, height: 120)
                        .padding(.bottom, -20)
                }
                
                ScrollView {
                    VStack(spacing: 30) {
                        if let summary = summaryManager.currentMonthlySummary {
                            // Acts of Kindness counter
                            SummaryCard(
                                icon: "heart.fill",
                                title: "Acts of Kindness",
                                content: "\(summary.totalActs)"
                            )
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            
                            // Longest streak
                            SummaryCard(
                                icon: "flame.fill",
                                title: "Longest Streak",
                                content: "\(summary.longestStreak) days"
                            )
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            
                            // Notable acts
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: "list.star")
                                        .foregroundColor(KindlyColors.accentRed)
                                    
                                    Text("Memorable Acts")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundColor(Color(hex: "333333"))
                                    
                                    Spacer()
                                }
                                
                                ForEach(summary.selectedActs) { act in
                                    HStack(alignment: .top) {
                                        Circle()
                                            .fill(KindlyColors.primaryPink.opacity(0.6))
                                            .frame(width: 8, height: 8)
                                            .padding(.top, 7)
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(act.title)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(Color(hex: "333333"))
                                            
                                            if let reflection = act.userReflection {
                                                Text(reflection)
                                                    .font(.system(size: 14))
                                                    .foregroundColor(Color(hex: "666666"))
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .padding(.leading, 2)
                                            }
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(.vertical, 5)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(KindlyColors.warmWhite)
                                    .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            
                            // Growth message
                            VStack(spacing: 10) {
                                Text("🌱 Growth")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(hex: "333333"))
                                
                                Text(summary.growthMessage)
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "555555"))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(KindlyColors.subtlePink.opacity(0.3))
                                    .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
                            )
                            .padding(.horizontal)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                        } else {
                            Text("No summary data available for this month.")
                                .font(.system(size: 18))
                                .foregroundColor(Color(hex: "666666"))
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    }
                    .padding(.vertical, 10)
                }
                
                // Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        saveScreenshot()
                    }) {
                        HStack {
                            Image(systemName: saveInProgress ? "checkmark.circle.fill" : "square.and.arrow.down")
                            Text(saveInProgress ? "Saved" : "Save Memory")
                        }
                        .kindlyOutlinedButtonStyle()
                    }
                    .disabled(saveInProgress)
                    
                    Button(action: {
                        withAnimation(.kindlyGently) {
                            summaryManager.markSummaryAsShown()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Text("Start a New Month 🌼")
                            .kindlyButtonStyle()
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .opacity(animateContent ? 1 : 0)
            }
            .padding(.vertical, 20)
        }
        .onAppear {
            // Animate content with a gentle delay
            withAnimation(.kindlyGently.delay(0.3)) {
                animateContent = true
            }
        }
    }
    
    // Function to save a screenshot of the summary
    private func saveScreenshot() {
        saveInProgress = true
        
        // Simulate save process
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Reset after animation
            saveInProgress = false
        }
    }
}

// Card view for summary statistics
struct SummaryCard: View {
    var icon: String
    var title: String
    var content: String
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(KindlyColors.primaryPink)
                
                Text(title)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color(hex: "333333"))
                
                Spacer()
            }
            
            Text(content)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(KindlyColors.primaryPink)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 5)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(KindlyColors.warmWhite)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
        .padding(.horizontal)
    }
}

// Bloom animation for summary
struct BloomAnimation: View {
    var color: Color
    @State private var scale = 0.0
    @State private var rotation = -20.0
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            ForEach(0..<5) { i in
                Petal(rotation: .degrees(Double(i) * 72))
                    .stroke(color, lineWidth: 1.5)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(.kindlyGently.delay(0.5)) {
                scale = 1.0
                rotation = 0
                opacity = 1.0
            }
        }
    }
}

// Single petal for the bloom animation
struct Petal: Shape {
    var rotation: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        path.move(to: center)
        
        // Create a petal shape
        for i in 0...100 {
            let angle = rotation + .degrees(Double(i) * 0.36) // 36 degrees total arc per petal
            let distance = radius * (0.3 + 0.7 * sin(Double.pi * Double(i) / 100))
            let x = center.x + distance * cos(angle.radians)
            let y = center.y + distance * sin(angle.radians)
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        path.closeSubpath()
        return path
    }
}

#Preview {
    let kindnessService = KindnessService()
    let streakTracker = StreakTracker()
    let summaryManager = SummaryManager(kindnessService: kindnessService, streakTracker: streakTracker)
    
    // Create a sample summary for preview
    let sampleActs = [
        CompletedKindnessAct(actId: "1", title: "Helped a neighbor with groceries", dateCompleted: Date(), userReflection: "They were really grateful and it made my day!"),
        CompletedKindnessAct(actId: "2", title: "Sent a handwritten note to a friend", dateCompleted: Date(), userReflection: nil),
        CompletedKindnessAct(actId: "3", title: "Volunteered at local animal shelter", dateCompleted: Date(), userReflection: "The puppies were so cute!")
    ]
    
    let sample = MonthlySummary(
        month: Calendar.current.component(.month, from: Date()),
        year: Calendar.current.component(.year, from: Date()),
        totalActs: 12,
        longestStreak: 5,
        selectedActs: sampleActs,
        growthMessage: "Your kindness bloomed and touched countless hearts 🌷✨",
        dateGenerated: Date()
    )
    
    summaryManager.currentMonthlySummary = sample
    
    return MonthlySummaryView(summaryManager: summaryManager)
} 