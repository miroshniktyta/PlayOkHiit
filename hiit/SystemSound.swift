//
//  Text.swift
//  hiit
//
//  Created by pc on 22.04.25.
//

import SwiftUI
import AVFoundation

enum SystemSound: Int, CaseIterable, Identifiable {
    case sound1013 = 1013  // Default
    case sound1010 = 1010  // Notification
    case sound1016 = 1016  // Mail Sent
    case sound1052 = 1104  // Tweet Sent
    case sound1108 = 1108  // Photoshot
    
    var id: Int { rawValue }
    
    var name: String {
        switch self {
        case .sound1013: return "Ding"
        case .sound1010: return "Beep"
        case .sound1016: return "Whisle"
        case .sound1052: return "Tick"
        case .sound1108: return "Camera"
        }
    }
}
