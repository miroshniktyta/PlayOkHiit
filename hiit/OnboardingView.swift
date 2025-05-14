import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let images: [String]
    let title: String
    let subtitle: String
}

struct OnboardingView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var currentPage = 0
    @State private var animateContent = false
    
    private let pages = [
        OnboardingPage(
            images: ["timer.circle.fill", "book.fill", "brain.head.profile"],
            title: "Welcome to FocusFlow",
            subtitle: "Your personal assistant for workouts, study, and mindfulness routines"
        ),
        OnboardingPage(
            images: ["list.bullet.circle.fill", "pencil.circle.fill", "graduationcap.circle.fill"],
            title: "Create Custom Sessions",
            subtitle: "Design your perfect routine: HIIT, Pomodoro, yoga, or meditation"
        ),
        OnboardingPage(
            images: ["repeat.circle.fill", "chart.bar.fill", "figure.mind.and.body"],
            title: "Track Your Progress",
            subtitle: "Follow your session with intuitive visual progress indicators"
        ),
        OnboardingPage(
            images: ["bell.circle.fill", "waveform.path.ecg", "moon.stars.fill"],
            title: "Stay Focused & Mindful",
            subtitle: "Audio cues and gentle reminders help you stay on track and present"
        )
    ]
    
    private func dismissOnboarding() {
        hasSeenOnboarding = true
        dismiss()
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Skip") {
                    dismissOnboarding()
                }
                .padding()
            }
            
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    VStack(spacing: 20) {
                        HStack(spacing: 24) {
                            ForEach(pages[index].images, id: \.self) { image in
                                Image(systemName: image)
                                    .font(.system(size: 48))
                                    .foregroundColor(.blue)
                                    .scaleEffect(animateContent ? 1 : 0.7)
                                    .opacity(animateContent ? 1 : 0)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(Double(pages[index].images.firstIndex(of: image) ?? 0) * 0.1), value: animateContent)
                            }
                        }
                        Text(pages[index].title)
                            .font(.title)
                            .bold()
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.2), value: animateContent)
                        Text(pages[index].subtitle)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 32)
                            .opacity(animateContent ? 1 : 0)
                            .offset(y: animateContent ? 0 : 20)
                            .animation(.easeOut(duration: 0.4).delay(0.3), value: animateContent)
                    }
                    .tag(index)
                    .onAppear {
                        animateContent = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            animateContent = true
                        }
                    }
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            
            Button {
                if currentPage < pages.count - 1 {
                    withAnimation {
                        currentPage += 1
                    }
                } else {
                    dismissOnboarding()
                }
            } label: {
                Text(currentPage < pages.count - 1 ? "Next" : "Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
} 

#Preview {
    OnboardingView()
}
