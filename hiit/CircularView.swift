import SwiftUI

enum ExerciseState {
    case past
    case current(isRest: Bool, isPaused: Bool)
    case future
    
    var color: Color {
        switch self {
        case .past:
            return .gray.opacity(0.3)
        case .current(let isRest, let isPaused):
            if isPaused {
                return .yellow
            }
            return isRest ? .blue : .orange
        case .future:
            return .gray.opacity(0.5)
        }
    }
    
    var icon: String {
        switch self {
        case .current(let isRest, _):
            return isRest ? "figure.mind.and.body" : "figure.run"
        default:
            return ""
        }
    }
    
    var label: String? {
        if case .current(let isRest, _) = self {
            return isRest ? "REST" : nil
        }
        return nil
    }
}

struct ExerciseCell: View {
    let exercise: String
    let state: ExerciseState
    
    var body: some View {
        HStack {
            Text(exercise)
                .font(.body)
            Spacer()
            if case .current = state {
                HStack(spacing: 4) {
                    if let label = state.label {
                        Text(label)
                            .font(.subheadline)
                            .foregroundColor(state.color)
                    }
                    Image(systemName: state.icon)
                        .foregroundColor(state.color)
                }
            }
        }
        .padding()
        .background(state.color.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(state.color, lineWidth: 1)
        )
        .cornerRadius(10)
    }
}

struct CircularView: View {
    let cycle: Round
    let currentProgress: Double
    let currentExerciseIndex: Int
    let currentCycleRepetition: Int
    let isRest: Bool
    let isPaused: Bool
    
    private let frameSize: CGFloat = 260
    private let innerCircleSize: CGFloat = 180
    private let lineWidth: CGFloat = 16
    
    private var exerciseProgress: Double {
        isRest ? 0 : currentProgress
    }
    
    private var restProgress: Double {
        isRest ? currentProgress : 1
    }
    
    private var timeLabel: String {
        let time = isRest ? cycle.restTime : cycle.exerciseTime
        let remainingTime = time * (isRest ? currentProgress : currentProgress)
        return formattedTime(remainingTime)
    }
    
    private var phaseLabel: String {
        if isRest {
            return "REST"
        } else if currentExerciseIndex < cycle.exersise.count {
            return cycle.exersise[currentExerciseIndex]
        }
        return ""
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                progressCircles
                centerContent
            }
            .padding(.bottom, 24)
            Divider()
            exerciseList
            Divider()
        }
        .padding(.vertical, 24)
    }
    
    @ViewBuilder
    private var progressCircles: some View {
        ZStack {
            ZStack {
                // Base circle for exercise
                Circle()
                    .stroke(Color.pink.opacity(0.25), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                
                // Exercise progress circle
                Circle()
                    .trim(from: 0, to: exerciseProgress)
                    .stroke(Color.pink, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: frameSize, height: frameSize)
            
            ZStack {
                // Base circle for rest
                Circle()
                    .stroke(Color.blue.opacity(0.25), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                
                // Rest progress circle
                Circle()
                    .trim(from: 0, to: restProgress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: frameSize - 34, height: frameSize - 34)
            
            // Center circle
            Circle()
                .fill(Color.indigo.opacity(0.4))
                .frame(width: frameSize - 34 - 18, height: frameSize - 34 - 18)
        }
        .frame(width: frameSize, height: frameSize)
        .animation(nil, value: exerciseProgress)
        .animation(nil, value: restProgress)
    }
    
    @ViewBuilder
    private var centerContent: some View {
        VStack(spacing: 8) {
            Text(phaseLabel)
                .font(.headline)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: 100)
            
            Text(timeLabel)
                .font(.title2.bold())
            
            if cycle.repeatCount > 1 {
                Text("Set \(currentCycleRepetition + 1) of \(cycle.repeatCount)")
                    .font(.subheadline)
            }
        }
        .frame(width: innerCircleSize)
    }
    
    @ViewBuilder
    private var exerciseList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 8) {
                    ForEach(cycle.exersise.indices, id: \.self) { index in
                        let state: ExerciseState = {
                            if index < currentExerciseIndex {
                                return .past
                            } else if index == currentExerciseIndex {
                                return .current(isRest: isRest, isPaused: isPaused)
                            } else {
                                return .future
                            }
                        }()
                        
                        ExerciseCell(exercise: cycle.exersise[index], state: state)
                            .id(index)
                    }
                }
                .padding()
            }
            .frame(height: 200)
            .onChange(of: currentExerciseIndex) { newIndex in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
    }
    
    private func formattedTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    VStack(spacing: 40) {
        CircularView(
            cycle: .example,
            currentProgress: 5,
            currentExerciseIndex: 0,
            currentCycleRepetition: 0,
            isRest: false,
            isPaused: true
        )
    }
}
