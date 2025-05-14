//
//  DurationPicker.swift
//  hiit
//
//  Created by pc on 29.11.24.
//

import SwiftUI

struct DurationPicker: View {
    @Binding var duration: TimeInterval
    let title: String
    
    // Internal state for hours, minutes, seconds
    @State private var hours: Int = 0
    @State private var minutes: Int = 0
    @State private var seconds: Int = 0
    
    // Constants for time limits
    private let maxHours = 23
    private let maxMinutes = 59
    private let maxSeconds = 59
    
    init(title: String, duration: Binding<TimeInterval>) {
        self.title = title
        self._duration = duration
        
        // Initialize the time components
        let totalSeconds = Int(duration.wrappedValue)
        let hrs = totalSeconds / 3600
        let mins = (totalSeconds % 3600) / 60
        let secs = totalSeconds % 60
        
        // Set initial state values
        _hours = State(initialValue: hrs)
        _minutes = State(initialValue: mins)
        _seconds = State(initialValue: secs)
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding(.top)
            
            HStack(spacing: 20) {
                // Hours Picker
                VStack {
                    Picker("Hours", selection: $hours) {
                        ForEach(0...maxHours, id: \.self) { hour in
                            Text("\(hour)").tag(hour)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 50)
                    .clipped()
                    .onChange(of: hours) { updateDuration() }
                    
                    Text("Hours")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Minutes Picker
                VStack {
                    Picker("Minutes", selection: $minutes) {
                        ForEach(0...maxMinutes, id: \.self) { minute in
                            Text("\(minute)").tag(minute)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 50)
                    .clipped()
                    .onChange(of: minutes) { updateDuration() }
                    
                    Text("Minutes")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // Seconds Picker
                VStack {
                    Picker("Seconds", selection: $seconds) {
                        ForEach(0...maxSeconds, id: \.self) { second in
                            Text("\(second)").tag(second)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 50)
                    .clipped()
                    .onChange(of: seconds) { updateDuration() }
                    
                    Text("Seconds")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding()
        }
    }
    
    private func updateDuration() {
        duration = TimeInterval(hours * 3600 + minutes * 60 + seconds)
    }
}
