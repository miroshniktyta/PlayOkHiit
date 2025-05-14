import SwiftUI

class OnboardingManager: ObservableObject {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var shouldShowOnboarding: Bool {
        !hasSeenOnboarding
    }
    
    func markOnboardingAsComplete() {
        hasSeenOnboarding = true
    }
} 