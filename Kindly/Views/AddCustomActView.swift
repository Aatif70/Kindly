import SwiftUI

struct AddCustomActView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var kindnessService: KindnessService
    
    @State private var title = ""
    @State private var description = ""
    @State private var showingSavedAnimation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.white.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 24) {
                    Text("Add Your Own Act")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color(hex: "333333"))
                        .padding(.top, 20)
                    
                    Text("Create your own act of kindness to add to the collection")
                        .font(.system(size: 16))
                        .foregroundColor(Color(hex: "888888"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                    
                    VStack(spacing: 16) {
                        TextField("Title of your act", text: $title)
                            .font(.system(size: 18))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "FACBD6").opacity(0.5), lineWidth: 1)
                            )
                        
                        TextField("Description (optional)", text: $description)
                            .font(.system(size: 16))
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: "FACBD6").opacity(0.5), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    Button(action: saveAct) {
                        Text("Save Act")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "FACBD6"))
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .disabled(title.isEmpty)
                    .opacity(title.isEmpty ? 0.6 : 1.0)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 30)
                }
                
                if showingSavedAnimation {
                    SavedCheckmarkView()
                        .frame(width: 100, height: 100)
                        .zIndex(100)
                }
            }
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    func saveAct() {
        guard !title.isEmpty else { return }
        
        // Add the act
        kindnessService.addCustomAct(title: title, description: description.isEmpty ? nil : description)
        
        // Show animation
        withAnimation {
            showingSavedAnimation = true
        }
        
        // Dismiss after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            presentationMode.wrappedValue.dismiss()
        }
    }
}

struct SavedCheckmarkView: View {
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "FACBD6").opacity(0.3))
                .frame(width: 80, height: 80)
            
            Image(systemName: "checkmark")
                .font(.system(size: 40, weight: .bold))
                .foregroundColor(Color(hex: "FACBD6"))
        }
        .scaleEffect(scale)
        .opacity(opacity)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

#Preview {
    AddCustomActView()
        .environmentObject(KindnessService())
} 