import SwiftUI
import AVFoundation

#Preview {
    SettingsView()
}

let tintColors = [
    "purple": Color.purple,
    "orange": Color.orange,
    "red": Color.red,
    "link": Color.accentColor
]


struct SettingsView: View {
    @AppStorage("appTintColor") private var appTintColor = "link"
    @AppStorage("isDarkMode") private var isDarkMode = true
    @Environment(\.dismiss) var dismiss
    @AppStorage("soundsEnabled") private var soundsEnabled = true
    @AppStorage("selectedSound") private var selectedSound: SystemSound = .sound1013
    
    private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    private let appStoreURL = "https://apps.apple.com/app/id6745899956"
    
    var body: some View {
        List {
            Section("Appearance") {
//                Picker("Theme", selection: $isDarkMode) {
//                    Text("Light").tag(false)
//                    Text("Dark").tag(true)
//                }
//                .pickerStyle(.menu)
                
                Picker("Accent Color", selection: $appTintColor) {
                    ForEach(Array(tintColors.keys.sorted()), id: \.self) { key in
                        Text(key.capitalized).tag(key)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Section {
                Toggle("Sound Effects", isOn: $soundsEnabled)
                
                if soundsEnabled {
                    Picker("Sound", selection: $selectedSound) {
                        ForEach(SystemSound.allCases) { sound in
                            Text(sound.name).tag(sound)
                        }
                    }
                    .pickerStyle(.menu)
                    Button("Test Sound") {
                        AudioServicesPlaySystemSound(UInt32(selectedSound.rawValue))
                    }
                }
            } header: {
                Text("General")
            } footer: {
                Text("Play sounds when changing exercise phases")
            }
            
            Section {
                HStack {
                    Text("Version")
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.secondary)
                }
                
                Button {
                    shareApp()
                } label: {
                    HStack {
                        Text("Share App")
                        Spacer()
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            } header: {
                Text("About")
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func shareApp() {
        let itemsToShare: [Any] = ["Check out this awesome workout timer app!", URL(string: appStoreURL)!]
        
        let activityVC = UIActivityViewController(
            activityItems: itemsToShare,
            applicationActivities: nil
        )
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              var topController = window.rootViewController else {
            print("hmm")
            return
        }
        
        // Find the topmost presented view controller
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        // For iPad: Set the source view/rect to prevent crash
        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceView = topController.view
            popoverController.sourceRect = CGRect(x: topController.view.bounds.midX,
                                                y: topController.view.bounds.midY,
                                                width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        DispatchQueue.main.async {
            topController.present(activityVC, animated: true) { }
        }
    }
}
