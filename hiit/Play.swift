//
//  Play.swift
//  hiit
//
//  Created by pc on 05.12.24.
//

import SwiftUI
import AVFoundation

#Preview {
    NavigationView {
        PlayView(viewModel: .init(workout: .example))
            .navigationTitle("Title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {}
                }
            }
    }
}

struct PlayView: View {
    @ObservedObject var viewModel: PlayViewModel
    @AppStorage("soundsEnabled") private var soundsEnabled = true
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                TabView(selection: $viewModel.selectedTabIndex) {
                    ForEach(viewModel.workout.rounds.indices, id: \.self) { index in
                        VStack {
                            if viewModel.workout.rounds.count > 1 {
                                Text("Round \(index + 1) of \(viewModel.workout.rounds.count)")
                                    .font(.title3)
                            }
                            CircularView(
                                cycle: viewModel.workout.rounds[index],
                                currentProgress: index == viewModel.currentRoundIndex ? viewModel.workoutProgress : 0,
                                currentExerciseIndex: index == viewModel.currentRoundIndex ? viewModel.currentExerciseIndex : 0,
                                currentCycleRepetition: index == viewModel.currentRoundIndex ? viewModel.currentRepetition : 0,
                                isRest: index == viewModel.currentRoundIndex && viewModel.isRestPhase,
                                isPaused: !viewModel.isPlaying,
                                isCompleted: viewModel.currentPhase == .completed
                            )
                            .tag(index)
                        }
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            Spacer(minLength: 24)
        }
        .background(Color.purple.opacity(0.1).ignoresSafeArea())
        .navigationTitle(viewModel.workout.name)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button(action: viewModel.restart) {
                    Image(systemName: "arrow.counterclockwise")
                }
                .font(.title2)
                
                Spacer()
                
                Button(action: viewModel.previous) {
                    Image(systemName: "backward.fill")
                }
                .font(.title2)
                
                Spacer()
                
                Button(action: viewModel.play) {
                    Image(systemName: viewModel.isPlaying ? "pause.fill" : "play.fill")
                }
                .font(.largeTitle)
                
                Spacer()
                
                Button(action: viewModel.next) {
                    Image(systemName: "forward.fill")
                }
                .font(.title2)
                
                Spacer()
                
                Button(action: { soundsEnabled.toggle() }) {
                    Image(systemName: soundsEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                }
                .font(.title2)
            }
        }
    }
}

enum WorkoutPhase {
    case round(roundIndex: Int, exerciseIndex: Int, repetition: Int)
    case rest(roundIndex: Int, afterExerciseIndex: Int, repetition: Int)
    case completed
}

extension WorkoutPhase: Equatable {
    static func == (lhs: WorkoutPhase, rhs: WorkoutPhase) -> Bool {
        switch (lhs, rhs) {
        case let (.round(index1, ex1, rep1), .round(index2, ex2, rep2)):
            return index1 == index2 && ex1 == ex2 && rep1 == rep2
        case let (.rest(index1, ex1, rep1), .rest(index2, ex2, rep2)):
            return index1 == index2 && ex1 == ex2 && rep1 == rep2
        case (.completed, .completed):
            return true
        default:
            return false
        }
    }
}

class PlayViewModel: ObservableObject {
    @Published var workout: Workout
    @Published var currentPhase: WorkoutPhase = .round(roundIndex: 0, exerciseIndex: 0, repetition: 0) {
        didSet {
            withAnimation(.easeInOut(duration: 0.3)) {
                selectedTabIndex = currentRoundIndex
            }
        }
    }
    @Published var progress: Double = 1.0
    @Published var isPlaying: Bool = false
    @Published var selectedTabIndex: Int = 0
    @AppStorage("soundsEnabled") private var soundsEnabled = true
    
    private var timer: Timer?
    private let updateInterval: TimeInterval = 0.1
    private let transitionDuration: TimeInterval = 0.3
    
    init(workout: Workout) {
        self.workout = workout
    }
    
    // MARK: - Computed Properties for View
    
    var currentRoundIndex: Int {
        switch currentPhase {
        case let .round(roundIndex, _, _):
            return roundIndex
        case let .rest(roundIndex, _, _):
            return roundIndex
        case .completed:
            return workout.rounds.count - 1
        }
    }
    
    var currentExerciseIndex: Int {
        switch currentPhase {
        case let .round(_, exerciseIndex, _):
            return exerciseIndex
        case let .rest(_, afterIndex, _):
            return afterIndex
        case .completed:
            return workout.rounds.last?.exersise.count ?? 0 - 1
        }
    }
    
    var currentRepetition: Int {
        switch currentPhase {
        case let .round(_, _, repetition):
            return repetition
        case let .rest(_, _, repetition):
            return repetition
        case .completed:
            return workout.rounds.last?.repeatCount ?? 0
        }
    }
    
    var workoutProgress: Double {
        switch currentPhase {
        case .round:
            return progress
        case .rest:
            return progress
        case .completed:
            return 0
        }
    }
    
    // MARK: - Time Labels
    
    var currentExerciseTimeLabel: String {
        switch currentPhase {
        case let .round(roundIndex, _, _):
            let round = workout.rounds[roundIndex]
            return formattedTime(round.exerciseTime * progress)
        case let .rest(roundIndex, _, _):
            let round = workout.rounds[roundIndex]
            return formattedTime(round.restTime * progress)
        case .completed:
            return "00:00"
        }
    }
    
    // MARK: - Timer Control
    
    func play() {
        if !isPlaying {
            playPhaseChangeSound()
        }
        if isPlaying {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        guard timer == nil else { return }
        
        isPlaying = true
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateProgress()
        }
    }
    
    private func pauseTimer() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
    }
    
    private func updateProgress() {
        progress -= updateInterval / currentPhaseDuration
        
        if progress <= 0 {
            moveToNextPhase()
        }
    }
    
    private var currentPhaseDuration: TimeInterval {
        switch currentPhase {
        case let .round(roundIndex, _, _):
            return workout.rounds[roundIndex].exerciseTime
        case let .rest(roundIndex, _, _):
            return workout.rounds[roundIndex].restTime
        case .completed:
            return 0
        }
    }
    
    func next() {
        let wasPlaying = isPlaying
        pauseTimer()
        
        withAnimation(.easeInOut(duration: transitionDuration)) {
            moveToNextPhase()
        }
        
        // Resume timer after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
            if wasPlaying {
                self.startTimer()
            }
        }
    }
    
    func restart() {
        pauseTimer()
        
        withAnimation(.easeInOut(duration: transitionDuration)) {
            currentPhase = .round(roundIndex: 0, exerciseIndex: 0, repetition: 0)
            progress = 1.0
        }
    }
    
    func previous() {
        let wasPlaying = isPlaying
        pauseTimer()
        
        withAnimation(.easeInOut(duration: transitionDuration)) {
            switch currentPhase {
            case let .round(roundIndex, exerciseIndex, repetition):
                if exerciseIndex > 0 {
                    currentPhase = .round(roundIndex: roundIndex, exerciseIndex: exerciseIndex - 1, repetition: repetition)
                } else if repetition > 0 {
                    let round = workout.rounds[roundIndex]
                    currentPhase = .round(roundIndex: roundIndex, exerciseIndex: round.exersise.count - 1, repetition: repetition - 1)
                } else if roundIndex > 0 {
                    let previousRound = workout.rounds[roundIndex - 1]
                    currentPhase = .round(roundIndex: roundIndex - 1, exerciseIndex: previousRound.exersise.count - 1, repetition: previousRound.repeatCount - 1)
                }
            case let .rest(roundIndex, afterIndex, repetition):
                if afterIndex > 0 {
                    currentPhase = .round(roundIndex: roundIndex, exerciseIndex: afterIndex - 1, repetition: repetition)
                } else if repetition > 0 {
                    let round = workout.rounds[roundIndex]
                    currentPhase = .round(roundIndex: roundIndex, exerciseIndex: round.exersise.count - 1, repetition: repetition - 1)
                } else if roundIndex > 0 {
                    let previousRound = workout.rounds[roundIndex - 1]
                    currentPhase = .round(roundIndex: roundIndex - 1, exerciseIndex: previousRound.exersise.count - 1, repetition: previousRound.repeatCount - 1)
                }
            case .completed:
                if let lastRound = workout.rounds.last {
                    currentPhase = .round(roundIndex: workout.rounds.count - 1, exerciseIndex: lastRound.exersise.count - 1, repetition: lastRound.repeatCount - 1)
                }
            }
            progress = 1.0
        }
        
        // Resume timer after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) {
            if wasPlaying {
                self.startTimer()
            }
        }
    }
    
    var currentPhaseLabel: String {
        switch currentPhase {
        case let .round(roundIndex, exerciseIndex, _):
            return workout.rounds[roundIndex].exersise[exerciseIndex]
        case .rest:
            return "REST"
        case .completed:
            return "Completed"
        }
    }
    
    var isRestPhase: Bool {
        if case .rest = currentPhase {
            return true
        }
        return false
    }
    
    private func playPhaseChangeSound() {
        if soundsEnabled {
            AudioServicesPlaySystemSound(1013)
        }
    }
    
    private func moveToNextPhase() {
        let previousPhase = currentPhase
        
        switch currentPhase {
        case let .round(roundIndex, exerciseIndex, repetition):
            let round = workout.rounds[roundIndex]
            if round.restTime > 0 {
                currentPhase = .rest(roundIndex: roundIndex, afterExerciseIndex: exerciseIndex, repetition: repetition)
            } else if exerciseIndex < round.exersise.count - 1 {
                currentPhase = .round(roundIndex: roundIndex, exerciseIndex: exerciseIndex + 1, repetition: repetition)
            } else if repetition < round.repeatCount - 1 {
                currentPhase = .round(roundIndex: roundIndex, exerciseIndex: 0, repetition: repetition + 1)
            } else if roundIndex < workout.rounds.count - 1 {
                currentPhase = .round(roundIndex: roundIndex + 1, exerciseIndex: 0, repetition: 0)
            } else {
                currentPhase = .completed
            }
        case let .rest(roundIndex, afterIndex, repetition):
            let round = workout.rounds[roundIndex]
            if afterIndex < round.exersise.count - 1 {
                currentPhase = .round(roundIndex: roundIndex, exerciseIndex: afterIndex + 1, repetition: repetition)
            } else if repetition < round.repeatCount - 1 {
                currentPhase = .round(roundIndex: roundIndex, exerciseIndex: 0, repetition: repetition + 1)
            } else if roundIndex < workout.rounds.count - 1 {
                currentPhase = .round(roundIndex: roundIndex + 1, exerciseIndex: 0, repetition: 0)
            } else {
                currentPhase = .completed
            }
        case .completed:
            pauseTimer()
        }
        
        if previousPhase != currentPhase {
            progress = 1.0
            playPhaseChangeSound()
        }
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
