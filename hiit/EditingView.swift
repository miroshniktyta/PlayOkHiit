//
//  Custom.swift
//  hiit
//
//  Created by pc on 29.11.24.
//

import SwiftUI

#Preview {
    EditingView(viewModel: ViewModel(workout: .example))
}

class ViewModel: ObservableObject {
    @Published var workout: Workout
    
    init(workout: Workout) {
        self.workout = workout
    }
    
    var totalDuration: TimeInterval {
        var duration: TimeInterval = 0
        for round in workout.rounds {
            let cycleSetDuration = Double(round.exersise.count) * round.exerciseTime
            duration += cycleSetDuration * Double(round.repeatCount)
            duration += round.restTime * Double(round.repeatCount - 1)
        }
        return duration
    }
    
    func createDefaultExerciseName(at index: Int, in roundIndex: Int) -> String {
        "Exercise \(index + 1)"
    }
    
    func validateAndUpdateExerciseName(_ name: String, at index: Int, in roundIndex: Int) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmedName.isEmpty ? createDefaultExerciseName(at: index, in: roundIndex) : trimmedName
        workout.rounds[roundIndex].exersise[index] = finalName
    }
    
    func addExercise(name: String, to roundIndex: Int) {
        let index = workout.rounds[roundIndex].exersise.count
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmedName.isEmpty ? createDefaultExerciseName(at: index, in: roundIndex) : trimmedName
        workout.rounds[roundIndex].exersise.append(finalName)
    }
    
    func deleteExercise(at index: Int, in roundIndex: Int) {
        workout.rounds[roundIndex].exersise.remove(at: index)
    }
    
    func addRound() {
        workout.rounds.append(Round(
            exersise: ["Exercise 1"],
            exerciseTime: 30,
            restTime: 10,
            repeatCount: 1
        ))
    }
    
    func deleteRound(at index: Int) {
        workout.rounds.remove(at: index)
    }
    
    var isValid: Bool {
        // Check if workout has a name
        guard !workout.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        
        // Check if there's at least one round
        guard !workout.rounds.isEmpty else { return false }
        
        // Check each round
        for round in workout.rounds {
            // Must have at least one exercise
            guard !round.exersise.isEmpty else { return false }
            
            // Exercise time must be greater than 0
            guard round.exerciseTime > 0 else { return false }
            
            // Repeat count must be at least 1
            guard round.repeatCount >= 1 else { return false }
        }
        
        return true
    }

    var validationMessage: String? {
        if workout.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Workout needs a name"
        }
        if workout.rounds.isEmpty {
            return "Add at least one round"
        }
        for (index, round) in workout.rounds.enumerated() {
            if round.exersise.isEmpty {
                return "Round \(index + 1) needs at least one exercise"
            }
            if round.exerciseTime <= 0 {
                return "Round \(index + 1) needs exercise time"
            }
            if round.repeatCount < 1 {
                return "Round \(index + 1) needs at least 1 repeat"
            }
        }
        return nil
    }
}

struct EditingView: View {
    @ObservedObject var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    var onSave: ((Workout) -> Void)?
    var onStart: ((Workout) -> Void)?
    private struct PickerState {
        let title: String
        let duration: Binding<TimeInterval>
    }
    @State private var pickerState: PickerState?
    @State private var editingExerciseContext: EditingExerciseContext? = nil
    @State private var editingExerciseName: String = ""
    
    var body: some View {
        VStack(spacing: 16) {
            Form {
                Section {
                    TextField("Workout Name", text: $viewModel.workout.name)
                }
                
                ForEach(viewModel.workout.rounds.indices, id: \.self) { roundIndex in
                    Section {
                        cycleContent(for: roundIndex)
                    } header: {
                        Text("Round \(roundIndex + 1)")
                    }
                }
                
                Section {
                    Button {
                        viewModel.addRound()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Round")
                        }
                    }
                }
            }
        }
        .sheet(item: $editingExerciseContext) { context in
            EditExerciseSheet(
                exerciseName: Binding(
                    get: { editingExerciseName },
                    set: { editingExerciseName = $0 }
                ),
                isNew: context.exerciseIndex == nil,
                onSave: {
                    if case let .edit(roundIndex, exerciseIndex, _) = context {
                        viewModel.validateAndUpdateExerciseName(editingExerciseName, at: exerciseIndex, in: roundIndex)
                    } else if case let .add(roundIndex, _) = context {
                        viewModel.addExercise(name: editingExerciseName, to: roundIndex)
                    }
                    editingExerciseContext = nil
                },
                onDelete: {
                    if case let .edit(roundIndex, exerciseIndex, _) = context {
                        viewModel.deleteExercise(at: exerciseIndex, in: roundIndex)
                    }
                    editingExerciseContext = nil
                },
                onCancel: {
                    editingExerciseContext = nil
                }
            )
            .onAppear {
                editingExerciseName = context.name
            }
            .presentationDetents([.fraction(0.4)])
        }
        .sheet(isPresented: .init(
            get: { pickerState != nil },
            set: { if !$0 { pickerState = nil } }
        )) {
            if let state = pickerState {
                NavigationView {
                    DurationPicker(title: state.title, duration: state.duration)
                        .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.fraction(0.4)])
            }
        }
        .toolbar {
            if let onSave = onSave {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave(viewModel.workout)
                        dismiss()
                    }
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    onStart?(viewModel.workout)
                }) {
                    VStack(spacing: 0) {
                        Text("Start")
//                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Total Duration: \(formattedTime(viewModel.totalDuration))")
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(2)
                    .background(Color.accentColor.opacity(0.15))
                    .cornerRadius(12)
                }
            }
        }
    }
    
    private func cycleContent(for roundIndex: Int) -> some View {
        let round = $viewModel.workout.rounds[roundIndex]
        return Group {
            // Repeat count
            HStack {
                Text("Repeat count")
                Spacer()
                Stepper("\(round.repeatCount.wrappedValue)", 
                        value: round.repeatCount, 
                        in: 1...100)
            }

            // Exercise time
            Button {
                pickerState = PickerState(
                    title: "Exercise Time",
                    duration: round.exerciseTime
                )
            } label: {
                HStack {
                    Text("Exercise Time")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(formattedTime(round.exerciseTime.wrappedValue))
                        .foregroundColor(.secondary)
                }
            }
            
            // Rest between exercises
            Button {
                pickerState = PickerState(
                    title: "Rest",
                    duration: round.restTime
                )
            } label: {
                HStack {
                    Text("Rest Between Exercises")
                        .foregroundColor(.primary)
                    Spacer()
                    Text(formattedTime(round.restTime.wrappedValue))
                        .foregroundColor(.secondary)
                }
            }

            // Exercises list
            ForEach(round.exersise.indices, id: \.self) { index in
                let exercise = round.exersise[index]
                Button {
                    editingExerciseContext = .edit(roundIndex: roundIndex, exerciseIndex: index, name: exercise.wrappedValue)
                } label: {
                    HStack {
                        Text(exercise.wrappedValue)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Add Exercise button
            Button {
                editingExerciseContext = .add(roundIndex: roundIndex, name: "")
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Exercise")
                }
            }
            
            // Delete Round button
            Button {
                viewModel.deleteRound(at: roundIndex)
            } label: {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                    Text("Delete Round")
                        .foregroundColor(.red)
                }
            }
        }
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: timeInterval) ?? "00:00:00"
    }
}

struct EditExerciseSheet: View {
    @Binding var exerciseName: String
    var isNew: Bool
    var onSave: () -> Void
    var onDelete: () -> Void
    var onCancel: () -> Void
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Form {
                    Section(header: Text("Exercise Name")) {
                        TextField("Exercise Name", text: $exerciseName)
                            .textFieldStyle(PlainTextFieldStyle())
                        if !isNew {
                            Button(role: .destructive, action: onDelete) {
                                Text("Delete")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save", action: onSave)
                }
            }
        }
        .presentationDetents([.fraction(0.4)])
    }
}

struct PickerState {
    let title: String
    let duration: Binding<TimeInterval>
}

enum EditingExerciseContext: Identifiable, Equatable {
    case edit(roundIndex: Int, exerciseIndex: Int, name: String)
    case add(roundIndex: Int, name: String)
    
    var id: String {
        switch self {
        case let .edit(roundIndex, exerciseIndex, _):
            return "edit-\(roundIndex)-\(exerciseIndex)"
        case let .add(roundIndex, _):
            return "add-\(roundIndex)"
        }
    }
    
    var roundIndex: Int {
        switch self {
        case let .edit(roundIndex, _, _): return roundIndex
        case let .add(roundIndex, _): return roundIndex
        }
    }
    
    var exerciseIndex: Int? {
        switch self {
        case let .edit(_, exerciseIndex, _): return exerciseIndex
        case .add: return nil
        }
    }
    
    var name: String {
        switch self {
        case let .edit(_, _, name): return name
        case let .add(_, name): return name
        }
    }
}
