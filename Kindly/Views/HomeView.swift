import SwiftUI

struct HomeView: View {
    @EnvironmentObject var kindnessService: KindnessService
    @EnvironmentObject var streakTracker: StreakTracker
    @State private var showingAddActSheet = false
    @State private var showingCompletionAnimation = false
    @State private var showingReflectionSheet = false
    @State private var userReflection = ""
    @State private var isLoaded = false
    
    // Vibrant pink color scheme
    private let vibrantPink = Color(hex: "FF3D7F") // More vibrant pink
    private let softPink = Color(hex: "FF93B0")
    private let darkText = Color(hex: "222222")
    private let lightText = Color(hex: "777777")
    
    var body: some View {
        NavigationView {
            ZStack {
                // Updated gradient background with vibrant pink
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, softPink.opacity(0.1)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    HStack {
                        Text("Today's Kindness")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(darkText)
                        
                        Spacer()
                        
                        // Adding a refresh button with nice animation
                        Button(action: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                kindnessService.checkAndUpdateTodaysAct()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(vibrantPink)
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    if let act = kindnessService.todaysAct {
                        KindnessCardView(act: act, vibrantPink: vibrantPink, softPink: softPink)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.8).combined(with: .opacity),
                                removal: .scale(scale: 1.1).combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isLoaded)
                    } else {
                        Text("Loading your act of kindness...")
                            .font(.system(size: 18))
                            .foregroundColor(lightText)
                    }
                    
                    Spacer()
                    
                    // Current streak indicator with improved design
                    HStack(spacing: 15) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Streak")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(lightText)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Text("\(kindnessService.getCurrentStreak())")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(vibrantPink)
                                
                                Text("days")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(darkText)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            NavigationLink(destination: CalendarView()) {
                                HStack(spacing: 8) {
                                    Text("Calendar")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Image(systemName: "calendar")
                                        .font(.system(size: 16))
                                }
                                .foregroundColor(vibrantPink)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(vibrantPink.opacity(0.1))
                                )
                            }
                        }
                        .scaleEffect(isLoaded ? 1.0 : 0.95)
                        .opacity(isLoaded ? 1.0 : 0.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1), value: isLoaded)
                    }
                    .padding(.horizontal, 25)
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            if !kindnessService.isActCompletedToday {
                                showingReflectionSheet = true
                            }
                        }) {
                            HStack {
                                Text(kindnessService.isActCompletedToday ? "Completed" : "Mark as Done")
                                    .font(.system(size: 18, weight: .bold))
                                
                                if kindnessService.isActCompletedToday {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 18))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .foregroundColor(.white)
                            .background(
                                kindnessService.isActCompletedToday
                                    ? LinearGradient(
                                        gradient: Gradient(colors: [softPink, Color(hex: "999999")]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      )
                                    : LinearGradient(
                                        gradient: Gradient(colors: [vibrantPink, softPink]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                      )
                            )
                            .cornerRadius(16)
                            .shadow(color: vibrantPink.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .disabled(kindnessService.isActCompletedToday)
                        .scaleEffect(kindnessService.isActCompletedToday ? 1.0 : 1.0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: kindnessService.isActCompletedToday)
                        .sheet(isPresented: $showingReflectionSheet) {
                            ReflectionSheetView(reflection: $userReflection, onSave: {
                                completeAct()
                            }, vibrantPink: vibrantPink, softPink: softPink)
                        }
                        
                        Button(action: {
                            showingAddActSheet = true
                        }) {
                            Text("Add Your Own")
                                .font(.system(size: 18, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .foregroundColor(vibrantPink)
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(vibrantPink, lineWidth: 2)
                                )
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isLoaded)
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 25)
                }
                
                if showingCompletionAnimation {
                    EnhancedCompletionView(vibrantPink: vibrantPink, softPink: softPink)
                        .edgesIgnoringSafeArea(.all)
                        .transition(.opacity)
                        .zIndex(100)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isLoaded = true
                }
            }
            .sheet(isPresented: $showingAddActSheet) {
                AddCustomActView()
                    .environmentObject(kindnessService)
            }
        }
    }
    
    private func completeAct() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            kindnessService.completeAct(reflection: userReflection.isEmpty ? nil : userReflection)
            showingCompletionAnimation = true
            userReflection = ""
            
            // Update streak tracker with completed dates
            streakTracker.updateCompletedDates(from: kindnessService.getCompletedActs())
            
            // Calculate current streak and update longest if needed
            let currentStreak = calculateCurrentStreak()
            streakTracker.updateLongestStreak(currentStreak: currentStreak)
        }
        
        // Hide animation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeOut(duration: 0.8)) {
                showingCompletionAnimation = false
            }
        }
    }
    
    private func calculateCurrentStreak() -> Int {
        let completedActs = kindnessService.getCompletedActs()
        
        // Get today's date and initialize variables
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var currentStreak = 0
        var currentDate = today
        
        // Loop backwards from today, checking each day
        while true {
            let dayCompleted = completedActs.contains { act in
                calendar.isDate(act.date, inSameDayAs: currentDate)
            }
            
            if dayCompleted {
                currentStreak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else {
                break
            }
        }
        
        return currentStreak
    }
}

struct KindnessCardView: View {
    let act: KindnessAct
    let vibrantPink: Color
    let softPink: Color
    @State private var isHovering = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            Image(systemName: "heart.fill")
                .font(.system(size: 40))
                .foregroundColor(vibrantPink)
                .padding(.top, 10)
                .opacity(isHovering ? 1.0 : 0.9)
                .scaleEffect(isHovering ? 1.1 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6).repeatCount(1), value: isHovering)
            
            Text(act.title)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(Color(hex: "333333"))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .fixedSize(horizontal: false, vertical: true)
            
            if let description = act.description {
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "777777"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 10)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Tag to show if this is a custom act
            if act.isCustom {
                Text("Custom Act")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(vibrantPink)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(vibrantPink.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.bottom, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 15, x: 0, y: 8)
                
                // Decorative elements
                Circle()
                    .fill(vibrantPink.opacity(0.05))
                    .frame(width: 200, height: 200)
                    .offset(x: -120, y: -100)
                
                Circle()
                    .fill(softPink.opacity(0.05))
                    .frame(width: 160, height: 160)
                    .offset(x: 120, y: 100)
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [vibrantPink.opacity(0.3), softPink.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .padding(.horizontal, 25)
        .scaleEffect(isHovering ? 1.03 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isHovering)
        .onTapGesture {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                isHovering.toggle()
                
                // Return to normal state after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isHovering = false
                    }
                }
            }
        }
    }
}

// Enhanced celebration animation
struct EnhancedCompletionView: View {
    let vibrantPink: Color
    let softPink: Color
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var particleScale: CGFloat = 0.3
    @State private var particleOpacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background blur and color overlay
            Color.black.opacity(0.15)
                .blur(radius: 3)
                .opacity(opacity * 0.7)
            
            // Expanding circles
            ForEach(0..<3) { i in
                Circle()
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [vibrantPink, softPink]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 120 + CGFloat(i * 60))
                    .scaleEffect(scale)
                    .opacity(opacity * (1.0 - Double(i) * 0.2))
            }
            
            // Confetti particles
            ForEach(0..<20) { i in
                Group {
                    if i % 3 == 0 {
                        Image(systemName: "heart.fill")
                            .foregroundColor(vibrantPink)
                    } else if i % 3 == 1 {
                        Image(systemName: "star.fill")
                            .foregroundColor(softPink)
                    } else {
                        Circle()
                            .fill(i % 2 == 0 ? vibrantPink : softPink)
                            .frame(width: 8, height: 8)
                    }
                }
                .font(.system(size: 16))
                .offset(
                    x: CGFloat.random(in: -150...150),
                    y: CGFloat.random(in: -200...200)
                )
                .scaleEffect(particleScale * CGFloat.random(in: 0.7...1.5))
                .opacity(particleOpacity * Double.random(in: 0.6...1.0))
                .rotationEffect(.degrees(Double.random(in: 0...360)))
            }
            
            // Central elements
            VStack(spacing: 20) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 80))
                    .foregroundColor(vibrantPink)
                    .shadow(color: vibrantPink.opacity(0.5), radius: 10, x: 0, y: 0)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .rotationEffect(.degrees(rotation * 20))
                
                Text("Act of Kindness Completed!")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 1)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
        }
        .onAppear {
            // Primary animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
                rotation = 1.0
            }
            
            // Particle animation with slight delay
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6).delay(0.1)) {
                particleScale = 1.0
                particleOpacity = 1.0
            }
            
            // Fade out animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                withAnimation(.easeOut(duration: 0.8)) {
                    opacity = 0
                    particleOpacity = 0
                    scale = 1.5
                    particleScale = 1.5
                }
            }
        }
    }
}

// Updated reflection sheet with vibrant colors
struct ReflectionSheetView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var reflection: String
    var onSave: () -> Void
    let vibrantPink: Color
    let softPink: Color
    @State private var animateBackground = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, softPink.opacity(0.2)]),
                    startPoint: animateBackground ? .topLeading : .bottomLeading,
                    endPoint: animateBackground ? .bottomTrailing : .topTrailing
                )
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                        animateBackground.toggle()
                    }
                }
                
                VStack(spacing: 30) {
                    VStack(spacing: 15) {
                        Image(systemName: "heart.text.square.fill")
                            .font(.system(size: 50))
                            .foregroundColor(vibrantPink)
                            .padding(.top, 20)
                        
                        Text("Your Reflection")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(Color(hex: "333333"))
                        
                        Text("How did this act of kindness make you feel?")
                            .font(.system(size: 16))
                            .foregroundColor(Color(hex: "666666"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $reflection)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(16)
                            .frame(height: 180)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [vibrantPink.opacity(0.3), softPink.opacity(0.5)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        
                        if reflection.isEmpty {
                            Text("Share your thoughts about this experience...")
                                .foregroundColor(Color(hex: "AAAAAA"))
                                .padding(.leading, 20)
                                .padding(.top, 24)
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    Spacer()
                    
                    VStack(spacing: 16) {
                        Button(action: {
                            onSave()
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Complete & Save")
                                .font(.system(size: 18, weight: .bold))
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .foregroundColor(.white)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [vibrantPink, softPink]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: vibrantPink.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Skip Reflection")
                                .font(.system(size: 16, weight: .medium))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .foregroundColor(Color(hex: "777777"))
                                .background(Color.white)
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color(hex: "DDDDDD"), lineWidth: 1.5)
                                )
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(KindnessService())
        .environmentObject(StreakTracker())
} 