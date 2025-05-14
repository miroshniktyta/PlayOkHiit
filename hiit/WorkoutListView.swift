//
//  List.swift
//  hiit
//
//  Created by pc on 06.12.24.
//

import Foundation
import SwiftUI

#Preview {
    WorkoutListView()
}

class WorkoutListViewModel: ObservableObject {
    @Published var workouts: [Workout] {
        didSet {
            saveWorkouts()
        }
    }
    
    private let userDefaultsKey = "savedWorkouts"
    
    init() {
        // Try to load saved workouts
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([Workout].self, from: data) {
            self.workouts = decoded
        } else {
            // If no saved workouts, use default workouts
            self.workouts = Workout.defaultWorkouts
            // Save default workouts
            saveWorkouts()
        }
    }
    
    private func saveWorkouts() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
    }
    
    func updateWorkout(_ workout: Workout, at index: Int) {
        workouts[index] = workout
    }
    
    func deleteWorkout(at index: Int) {
        workouts.remove(at: index)
    }
}

struct WorkoutListView: View {
    @StateObject private var viewModel = WorkoutListViewModel()
    @State private var showingNewWorkout = false
    @State private var editingWorkoutIndex: Int?
    @State private var selectedWorkoutIndex: Int?
    @State private var showingSettings = false
    @State private var showingOnboarding = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.workouts.indices, id: \.self) { index in
                    WorkoutRowView(
                        workout: viewModel.workouts[index],
                        onEdit: { editingWorkoutIndex = index }
                    )
                }
                .onDelete { indexSet in
                    if let index = indexSet.first {
                        viewModel.deleteWorkout(at: index)
                    }
                }
            }
            .navigationTitle("Workouts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingOnboarding = true
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                ToolbarItem(placement: .bottomBar) {
                    Button {
                        showingNewWorkout = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill").font(.title3)
                            Text("Add New Workout").font(.title3)
                        }
                        .padding(8)
                        .padding(.horizontal, 8)
                        .background(Color.accentColor.opacity(0.15))
                        .cornerRadius(16)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationDestination(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingNewWorkout) {
                NewView(viewModel: viewModel, onStartPlay: { index in
                    selectedWorkoutIndex = index
                })
            }
            .sheet(item: $editingWorkoutIndex) { index in
                EditView(
                    viewModel: viewModel,
                    workoutIndex: index,
                    workout: viewModel.workouts[index],
                    onStartPlay: { idx in
                        selectedWorkoutIndex = idx
                    }
                )
            }
            .fullScreenCover(item: $selectedWorkoutIndex) { index in
                ConteinerView(workout: viewModel.workouts[index])
            }
            .sheet(isPresented: $showingOnboarding) {
                OnboardingView()
            }
        }
        .onAppear {
            if !hasSeenOnboarding {
                showingOnboarding = true
            }
        }
    }
}

struct WorkoutRowView: View {
    let workout: Workout
    let onEdit: () -> Void
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(workout.name.isEmpty ? "Untitled Workout" : workout.name)
                        .font(.headline)
                    Spacer()
                }
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text(formatDuration(totalDuration))
                            .font(.caption)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text("\(workout.rounds.count) rounds")
                            .font(.caption)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text("\(totalExercises) exercises")
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
                .font(.subheadline)
            }
        .padding(.horizontal, 8)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(10)
            .onTapGesture {
                onEdit()
            }
        }
    }
    
    private var totalExercises: Int {
        workout.rounds.reduce(0) { $0 + $1.exersise.count * $1.repeatCount }
    }
    
    private var totalDuration: TimeInterval {
        var duration: TimeInterval = 0
        for round in workout.rounds {
            let exercisesTime = round.exerciseTime * Double(round.exersise.count)
            let restTime = round.exersise.count > 1 ? round.restTime * Double(round.exersise.count - 1) : 0
            let roundDuration = (exercisesTime + restTime) * Double(round.repeatCount)
            if round.repeatCount > 1 && round.restTime > 0 {
                duration += round.restTime * Double(round.repeatCount - 1)
            }
            duration += roundDuration
        }
        return duration
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter.string(from: duration) ?? ""
    }
}

struct NewView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WorkoutListViewModel
    var onStartPlay: ((Int) -> Void)?
    @StateObject private var customViewModel = ViewModel(
        workout: .init(name: "New Workout", rounds: [
            .init(
                exersise: ["New exersise"],
                exerciseTime: 30,
                restTime: 10,
                repeatCount: 4)
        ])
    )
    @State private var showingValidationAlert = false
    
    var body: some View {
        NavigationView {
            EditingView(viewModel: customViewModel, onStart: { workout in
                if customViewModel.isValid {
                    viewModel.addWorkout(workout)
                    let idx = viewModel.workouts.count - 1
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onStartPlay?(idx)
                    }
                } else {
                    showingValidationAlert = true
                }
            })
            .navigationTitle("New Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if customViewModel.isValid {
                            viewModel.addWorkout(customViewModel.workout)
                            dismiss()
                        } else {
                            showingValidationAlert = true
                        }
                    }
                }
            }
            .alert("Invalid Workout", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(customViewModel.validationMessage ?? "Please check your workout setup")
            }
        }
    }
}

struct EditView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WorkoutListViewModel
    let workoutIndex: Int
    var onStartPlay: ((Int) -> Void)?
    @StateObject private var customViewModel: ViewModel
    @State private var hasChanges = false
    @State private var showingDiscardAlert = false
    @State private var showingValidationAlert = false

    init(viewModel: WorkoutListViewModel, workoutIndex: Int, workout: Workout, onStartPlay: ((Int) -> Void)? = nil) {
        self.viewModel = viewModel
        self.workoutIndex = workoutIndex
        self._customViewModel = StateObject(wrappedValue: ViewModel(workout: workout))
        self.onStartPlay = onStartPlay
    }
    
    var body: some View {
        NavigationView {
            EditingView(viewModel: customViewModel, onStart: { workout in
                if customViewModel.isValid {
                    viewModel.updateWorkout(workout, at: workoutIndex)
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        onStartPlay?(workoutIndex)
                    }
                } else {
                    showingValidationAlert = true
                }
            })
            .navigationTitle("Edit Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        if hasChanges {
                            showingDiscardAlert = true
                        } else {
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        if customViewModel.isValid {
                            viewModel.updateWorkout(customViewModel.workout, at: workoutIndex)
                            dismiss()
                        } else {
                            showingValidationAlert = true
                        }
                    }
                }
            }
            .alert("Invalid Workout", isPresented: $showingValidationAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(customViewModel.validationMessage ?? "Please check your workout setup")
            }
            .onChange(of: customViewModel.workout) { newValue in
                hasChanges = true
                viewModel.updateWorkout(newValue, at: workoutIndex)
            }
            .alert("Discard Changes?", isPresented: $showingDiscardAlert) {
                Button("Discard", role: .destructive) {
                    dismiss()
                }
                Button("Keep Editing", role: .cancel) {}
            } message: {
                Text("Are you sure you want to discard your changes?")
            }
        }
    }
}

struct ConteinerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: PlayViewModel
    @State private var showingExitAlert = false
    
    init(workout: Workout) {
        self._viewModel = StateObject(wrappedValue: PlayViewModel(workout: workout))
    }
    
    var body: some View {
        NavigationView {
            PlayView(viewModel: viewModel)
                .navigationTitle(viewModel.workout.name.isEmpty ? "Workout" : viewModel.workout.name)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Close") {
                            if viewModel.isPlaying {
                                showingExitAlert = true
                            } else {
                                dismiss()
                            }
                        }
                    }
                }
        }
        .alert("Stop Workout?", isPresented: $showingExitAlert) {
            Button("Stop", role: .destructive) {
                dismiss()
            }
            Button("Continue", role: .cancel) {}
        } message: {
            Text("Are you sure you want to stop the workout?")
        }
    }
}

// Helper to make Int work with sheet(item:)
extension Int: Identifiable {
    public var id: Int { self }
}
//
//struct SettingsView: View {
//    @Environment(\.dismiss) var dismiss
//    @AppStorage("soundsEnabled") private var soundsEnabled = true
//    @AppStorage("selectedSound") private var selectedSound: SystemSound = .sound1013
//    
//    enum SystemSound: Int, CaseIterable, Identifiable {
//        case sound1013 = 1013  // Default
//        case sound1014 = 1014  // Notification
//        case sound1103 = 1103  // Mail Sent
//        case sound1104 = 1104  // Tweet Sent
//        case sound1123 = 1123  // Photoshot
//        
//        var id: Int { rawValue }
//        
//        var name: String {
//            switch self {
//            case .sound1013: return "Default"
//            case .sound1014: return "Notification"
//            case .sound1103: return "Mail"
//            case .sound1104: return "Tweet"
//            case .sound1123: return "Camera"
//            }
//        }
//    }
//    
//    var body: some View {
//        NavigationView {
//            List {
//                Section {
//                    Toggle("Sound Effects", isOn: $soundsEnabled)
//                    
//                    if soundsEnabled {
//                        Picker("Sound", selection: $selectedSound) {
//                            ForEach(SystemSound.allCases) { sound in
//                                Text(sound.name).tag(sound)
//                            }
//                        }
//                        Button("Test Sound") {
//                            AudioServicesPlaySystemSound(UInt32(selectedSound.rawValue))
//                        }
//                    }
//                } header: {
//                    Text("General")
//                } footer: {
//                    Text("Play sounds when changing exercise phases")
//                }
//                // ... rest of the view
//            }
//        }
//    }
//}

