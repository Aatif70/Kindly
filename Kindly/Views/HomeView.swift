import SwiftUI

struct HomeView: View {
    @EnvironmentObject var kindnessService: KindnessService
    @EnvironmentObject var streakTracker: StreakTracker
    @State private var showingAddActSheet = false
    @State private var showingCompletionAnimation = false
    @State private var isLoaded = false
    
    var body: some View {
        NavigationView {
            ZStack {
                KindlyColors.subtleGradient.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    Text("Today's Kindness")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(Color(hex: "333333"))
                        .padding(.top, 20)
                    
                    Spacer()
                    
                    if let act = kindnessService.todaysAct {
                        KindnessCardView(act: act)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            .animation(.kindlySpring, value: isLoaded)
                    } else {
                        Text("Loading your act of kindness...")
                            .font(.system(size: 18))
                            .foregroundColor(Color(hex: "888888"))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 18) {
                        Button(action: {
                            completeAct()
                        }) {
                            Text(kindnessService.isActCompletedToday ? "Completed" : "Mark as Done")
                                .kindlyButtonStyle(
                                    backgroundColor: kindnessService.isActCompletedToday 
                                        ? Color(hex: "888888") 
                                        : KindlyColors.primaryPink
                                )
                        }
                        .disabled(kindnessService.isActCompletedToday)
                        .scaleEffect(kindnessService.isActCompletedToday ? 1.0 : 1.0)
                        .animation(.kindlyBounce, value: kindnessService.isActCompletedToday)
                        
                        Button(action: {
                            showingAddActSheet = true
                        }) {
                            Text("Add Your Own")
                                .kindlyOutlinedButtonStyle()
                        }
                        .animation(.kindlySpring, value: isLoaded)
                    }
                    .padding(.horizontal, 30)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Streak")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "888888"))
                            
                            Text("\(kindnessService.getCurrentStreak()) days")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color(hex: "333333"))
                        }
                        
                        Spacer()
                        
                        Button(action: {}) {
                            NavigationLink(destination: CalendarView()) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 20))
                                    .foregroundColor(KindlyColors.primaryPink)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(KindlyColors.warmWhite)
                                            .shadow(color: Color.black.opacity(0.07), radius: 3, x: 0, y: 1)
                                    )
                            }
                        }
                        .scaleEffect(isLoaded ? 1.0 : 0.95)
                        .opacity(isLoaded ? 1.0 : 0.0)
                        .animation(.kindlySpring.delay(0.1), value: isLoaded)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)
                }
                
                if showingCompletionAnimation {
                    LottieHeartView()
                        .frame(width: 200, height: 200)
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
    
    func completeAct() {
        withAnimation(.kindlySpring) {
            showingCompletionAnimation = true
            kindnessService.completeAct()
            
            // Update streak tracker
            streakTracker.updateCompletedDates(from: kindnessService.getCompletedActs())
            streakTracker.updateLongestStreak(currentStreak: kindnessService.getCurrentStreak())
        }
        
        // Hide animation after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.kindlyGently) {
                showingCompletionAnimation = false
            }
        }
    }
}

struct KindnessCardView: View {
    let act: KindnessAct
    @State private var isHovering = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Text(act.title)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color(hex: "333333"))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let description = act.description {
                Text(description)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "888888"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(KindlyColors.warmWhite)
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(KindlyColors.secondaryPink.opacity(0.6), lineWidth: 1.5)
        )
        .padding(.horizontal, 30)
        .scaleEffect(isHovering ? 1.02 : 1.0)
        .animation(.kindlySpring, value: isHovering)
        .onTapGesture {
            withAnimation(.kindlyBounce) {
                isHovering.toggle()
                
                // Return to normal state after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.kindlySpring) {
                        isHovering = false
                    }
                }
            }
        }
    }
}

// A heart animation view with improved animation
struct LottieHeartView: View {
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Smaller background hearts
            ForEach(0..<10) { i in
                Image(systemName: "heart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(KindlyColors.accentRed.opacity(0.7))
                    .offset(x: CGFloat.random(in: -100...100), y: CGFloat.random(in: -100...100))
                    .scaleEffect(opacity * CGFloat.random(in: 0.5...1.5))
                    .opacity(opacity * Double.random(in: 0.3...0.8))
                    .rotation3DEffect(.degrees(rotation * Double.random(in: -20...20)), axis: (x: 0, y: 0, z: 1))
            }
            
            // Main heart
            Image(systemName: "heart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(KindlyColors.primaryPink)
                .scaleEffect(scale)
                .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
                rotation = 360
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation(.easeOut(duration: 0.8)) {
                    opacity = 0
                    scale = 1.2
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(KindnessService())
        .environmentObject(StreakTracker())
} 