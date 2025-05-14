//
//  hiitApp.swift
//  hiit
//
//  Created by pc on 28.11.24.
//

import SwiftUI

#Preview{
    WorkoutListView()
}

extension UIWindow {
    static func updateAllWindows(with colorScheme: ColorScheme?) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.compactMap { $0 as? UIWindowScene }
        
        for windowScene in windowScenes {
            for window in windowScene.windows {
//                window.tintColor = UIColor(Color.purple)
                window.overrideUserInterfaceStyle = colorScheme == .dark ? .dark :
                                                  colorScheme == .light ? .light :
                                                  .unspecified
            }
        }
    }
}

@main
struct hiitApp: App {
    init() {
        UIWindow.updateAllWindows(with: .dark)
    }
    
    @AppStorage("appTintColor") private var appTintColor = "link"
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some Scene {
        WindowGroup {
            WorkoutListView()
//                .onAppear {
//                    UIWindow.updateAllWindows(with: .dark)
//                }
                .tint(tintColor)
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
    
    private var tintColor: Color {
        switch appTintColor {
        case "purple": return .purple
        case "pink": return .pink
        case "orange": return .orange
        case "green": return .green
        case "indigo": return .indigo
        default: return .blue
        }
    }
}

struct CustomCell: View {
    let name: String
    let onNameTap: () -> Void
    let onFirstButtonTap: () -> Void
    let onSecondButtonTap: () -> Void
    
    var body: some View {
        ZStack {
            // Background tap handler
            Color.clear // Ensure tap area spans the entire cell
                .contentShape(Rectangle()) // Define tap area as the full rectangle
                .onTapGesture {
                    onNameTap()
                }
            
            // Foreground content
            HStack {
                Text(name)
                
                Spacer()
                
                Button(action: onFirstButtonTap) {
                    Image(systemName: "info.circle")
//                        .foregroundColor(.purple)
                }
                .buttonStyle(BorderlessButtonStyle()) // Avoids interference
                
                Button(action: onSecondButtonTap) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.vertical, 8)
            .padding(.horizontal)
        }
    }
}
