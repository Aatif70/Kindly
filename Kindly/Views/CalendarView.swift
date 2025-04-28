import SwiftUI

struct CalendarView: View {
    @EnvironmentObject var kindnessService: KindnessService
    @EnvironmentObject var streakTracker: StreakTracker
    
    @State private var selectedMonth = Date()
    @State private var isLoaded = false
    @State private var isChangingMonth = false
    
    private let calendar = Calendar.current
    private let weekdays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        NavigationView {
            ZStack {
                KindlyColors.subtleGradient.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 20) {
                    VStack(spacing: 8) {
                        Text("Your Kindness Streaks")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(hex: "333333"))
                        
                        Text("Track your progress over time")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "888888"))
                    }
                    .padding(.top, 16)
                    .opacity(isLoaded ? 1 : 0)
                    .offset(y: isLoaded ? 0 : -10)
                    .animation(.kindlySpring.delay(0.1), value: isLoaded)
                    
                    // Streak info
                    HStack(spacing: 35) {
                        VStack {
                            Text("Current")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "888888"))
                            
                            Text("\(kindnessService.getCurrentStreak())")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(KindlyColors.primaryPink)
                        }
                        
                        VStack {
                            Text("Longest")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "888888"))
                            
                            Text("\(streakTracker.getLongestStreak())")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(Color(hex: "333333"))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(KindlyColors.warmWhite)
                            .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)
                    )
                    .padding(.horizontal, 30)
                    .scaleEffect(isLoaded ? 1 : 0.9)
                    .opacity(isLoaded ? 1 : 0)
                    .animation(.kindlySpring.delay(0.2), value: isLoaded)
                    
                    // Month selector
                    HStack {
                        Button(action: {
                            changeMonth(by: -1)
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(KindlyColors.primaryPink.opacity(0.8))
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(KindlyColors.warmWhite)
                                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                )
                        }
                        
                        Spacer()
                        
                        Text(monthYearFormatter.string(from: selectedMonth))
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "333333"))
                            .opacity(isChangingMonth ? 0 : 1)
                            .scaleEffect(isChangingMonth ? 0.8 : 1)
                            .animation(.kindlySpring, value: isChangingMonth)
                        
                        Spacer()
                        
                        Button(action: {
                            changeMonth(by: 1)
                        }) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(KindlyColors.primaryPink.opacity(0.8))
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(KindlyColors.warmWhite)
                                        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    .opacity(isLoaded ? 1 : 0)
                    .animation(.kindlySpring.delay(0.3), value: isLoaded)
                    
                    // Weekday headers
                    HStack(spacing: 0) {
                        ForEach(weekdays, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 14, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .foregroundColor(KindlyColors.primaryPink.opacity(0.7))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .opacity(isLoaded ? 1 : 0)
                    .animation(.kindlySpring.delay(0.4), value: isLoaded)
                    
                    // Calendar grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                        ForEach(daysInMonth, id: \.self) { date in
                            if let date = date {
                                DayView(date: date, isCompleted: kindnessService.isDateCompleted(date))
                                    .id(date) // Important for animations
                                    .transition(.asymmetric(
                                        insertion: .scale(scale: 0.5).combined(with: .opacity),
                                        removal: .scale(scale: 0.5).combined(with: .opacity)
                                    ))
                            } else {
                                Color.clear
                                    .frame(height: 40)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .animation(.kindlyPop.delay(0.05), value: selectedMonth)
                    
                    Spacer()
                }
            }
            .onAppear {
                streakTracker.updateCompletedDates(from: kindnessService.getCompletedActs())
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isLoaded = true
                }
            }
        }
    }
    
    private func changeMonth(by value: Int) {
        withAnimation(.kindlyQuick) {
            isChangingMonth = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation {
                selectedMonth = calendar.date(byAdding: .month, value: value, to: selectedMonth)!
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.kindlyQuick) {
                    isChangingMonth = false
                }
            }
        }
    }
    
    private var daysInMonth: [Date?] {
        let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedMonth))!
        let firstWeekday = calendar.component(.weekday, from: firstDay)
        let offsetDays = firstWeekday - 1
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedMonth)!.count
        
        var days = [Date?](repeating: nil, count: offsetDays)
        
        for day in 1...daysInMonth {
            let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay)!
            days.append(date)
        }
        
        // Fill the remaining days to complete the grid
        let remainingCells = 42 - days.count // 6 rows * 7 days = 42
        days.append(contentsOf: [Date?](repeating: nil, count: remainingCells))
        
        return days
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

struct DayView: View {
    let date: Date
    let isCompleted: Bool
    @State private var animateIn = false
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 4) {
            if isToday {
                Text("\(day)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color(hex: "333333"))
                    .frame(width: 34, height: 34)
                    .background(
                        Circle()
                            .stroke(KindlyColors.primaryPink, lineWidth: 2)
                    )
            } else {
                Text("\(day)")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "333333"))
                    .frame(width: 34, height: 34)
            }
            
            if isCompleted {
                Circle()
                    .fill(KindlyColors.primaryPink)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animateIn ? 1 : 0)
                    .animation(.kindlyPop.delay(Double(day) * 0.01), value: animateIn)
            } else {
                Circle()
                    .stroke(KindlyColors.primaryPink.opacity(0.3), lineWidth: 1)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 50)
        .scaleEffect(animateIn ? 1 : 0.8)
        .opacity(animateIn ? 1 : 0)
        .onAppear {
            // Staggered animation timing based on day number
            let staggerDelay = min(0.5, Double(day) * 0.01 + 0.1)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + staggerDelay) {
                withAnimation(.kindlyPop) {
                    animateIn = true
                }
            }
        }
    }
    
    private var day: Int {
        return calendar.component(.day, from: date)
    }
    
    private var isToday: Bool {
        return calendar.isDateInToday(date)
    }
}

#Preview {
    CalendarView()
        .environmentObject(KindnessService())
        .environmentObject(StreakTracker())
} 