//
//  Views.swift
//  hiit
//
//  Created by pc on 29.11.24.
//

import SwiftUI
//
//struct TimelineSegment: Identifiable {
//    enum SegmentType {
//        case warmUp
//        case coolDown
//        case rest
//        case exercise(label: String, indexInCycle: Int, totalInCycle: Int)
//    }
//
//    var id = UUID()
//    var type: SegmentType
//    var duration: TimeInterval
//}
//
//struct PreviewTimelineView: View {
//    var segments: [TimelineSegment]
//
//    var body: some View {
//        GeometryReader { geometry in
//            HStack(spacing: 0) {
//                ForEach(segments) { segment in
//                    Rectangle()
//                        .fill(color(for: segment.type))
//                        .frame(width: width(for: segment.duration, totalWidth: geometry.size.width))
//                }
//            }
//            .cornerRadius(5)
//        }
//    }
//
//    // Calculates the total duration of all segments
//    func totalDuration() -> TimeInterval {
//        segments.reduce(0) { $0 + $1.duration }
//    }
//
//    // Calculates the width of each segment proportionally
//    func width(for duration: TimeInterval, totalWidth: CGFloat) -> CGFloat {
//        let total = totalDuration()
//        guard total > 0 else { return 0 }
//        return CGFloat(duration / total) * totalWidth
//    }
//
//    // Assigns colors to different segment types
//    func color(for type: TimelineSegment.SegmentType) -> Color {
//        switch type {
//        case .warmUp:
//            return Color.orange.opacity(0.7)
//        case .coolDown:
//            return Color.green.opacity(0.7)
//        case .rest:
//            return Color.gray.opacity(0.5)
//        case .exercise(_, let index, let total):
//            // Calculate hue based on position in cycle
//            let hue = total == 1 ? 0.0 : Double(index) / Double(total)
//            return Color(hue: hue, saturation: 0.8, brightness: 0.9)
//        }
//    }
//}
//
//#Preview {
//    PreviewTimelineView(segments: [])
//}
//
//extension Workout {
//    var timelineSegments: [TimelineSegment] {
//        var segments: [TimelineSegment] = []
//        
//        if warmUp > 0 {
//            segments.append(TimelineSegment(type: .warmUp, duration: warmUp))
//        }
//        
//        for _ in 0..<circuit.repeatCount {
//            for (setIndex, exercise) in circuit.exersise.enumerated() {
//                segments.append(TimelineSegment(
//                    type: .exercise(
//                        label: exercise.label,
//                        indexInCycle: setIndex,
//                        totalInCycle: circuit.exersise.count
//                    ),
//                    duration: circuit.exerciseTime
//                ))
//                
//                // Add rest after exercise if it's not the last one
//                if setIndex < circuit.exersise.count - 1,
//                   circuit.restTime > 0 {
//                    segments.append(TimelineSegment(
//                        type: .rest,
//                        duration: circuit.restTime
//                    ))
//                }
//            }
//            
//            // Add rest after cycle repeat if it's not the last repeat
//            if circuit.restTime > 0 {
//                segments.append(TimelineSegment(
//                    type: .rest,
//                    duration: circuit.restTime
//                ))
//            }
//        }
//        
//        if coolDown > 0 {
//            segments.append(TimelineSegment(type: .coolDown, duration: coolDown))
//        }
//        
//        return segments
//    }
//}
