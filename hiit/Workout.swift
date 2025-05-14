//
//  Workout.swift
//  hiit
//
//  Created by pc on 04.04.25.
//

import Foundation

struct Exersise: Identifiable, Codable {
    var id = UUID()
    var exersiseLabel: String
}

struct Round: Identifiable, Codable {
    var id = UUID()
    var exersise: [String]
    var exerciseTime: TimeInterval
    var restTime: TimeInterval
    var repeatCount: Int
}

struct Workout: Identifiable, Equatable, Codable {
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        lhs.id == rhs.id
    }
    
    var id: UUID = .init()
    var name: String = ""
    var rounds: [Round]
}

// test

extension Round {
    static var example: Round {
        .init(
            exersise: ["Exercise 1", "Exercise 2", "Exercise 3", "Exercise 4", "Exercise 5"],
            exerciseTime: 30,  // Default exercise time of 30 seconds
            restTime: 10,      // Default rest time of 10 seconds
            repeatCount: 6
        )
    }
}

extension Workout {
    static var example: Workout {
        return Workout(
            name: "Yoga Flow",
            rounds: [
                Round(
                    exersise: ["Breath Awareness"],
                    exerciseTime: 60,
                    restTime: 0,
                    repeatCount: 1
                ),
                Round(
                    exersise: ["Cat-Cow", "Downward Dog", "Child's Pose", "Cat-Cow2", "Downward Dog2", "Child's Pose2"],
                    exerciseTime: 45,
                    restTime: 15,
                    repeatCount: 2
                ),
                Round(
                    exersise: ["Seated Forward Fold"],
                    exerciseTime: 60,
                    restTime: 0,
                    repeatCount: 1
                )
            ]
        )
    }
}

extension Workout {
    static let defaultWorkouts: [Workout] = [
        // Yoga Routine
        Workout(
            name: "Morning Yoga Flow",
            rounds: [
                Round(
                    exersise: ["Breath Awareness"],
                    exerciseTime: 60,
                    restTime: 0,
                    repeatCount: 1
                ),
                Round(
                    exersise: ["Cat-Cow", "Downward Dog", "Cobra Pose", "Child's Pose"],
                    exerciseTime: 40,
                    restTime: 10,
                    repeatCount: 2
                ),
                Round(
                    exersise: ["Seated Forward Fold", "Spinal Twist"],
                    exerciseTime: 60,
                    restTime: 0,
                    repeatCount: 1
                )
            ]
        ),
        // Functional Body Workout 1
        Workout(
            name: "Full Body Functional",
            rounds: [
                Round(
                    exersise: ["Warm Up"],
                    exerciseTime: 120,
                    restTime: 0,
                    repeatCount: 1
                ),
                Round(
                    exersise: ["Squats", "Push-ups", "Lunges", "Plank"],
                    exerciseTime: 40,
                    restTime: 20,
                    repeatCount: 3
                ),
                Round(
                    exersise: ["Cool Down"],
                    exerciseTime: 90,
                    restTime: 0,
                    repeatCount: 1
                )
            ]
        ),
        // Functional Body Workout 2
        Workout(
            name: "Core & Cardio Blast",
            rounds: [
                Round(
                    exersise: ["Warm Up"],
                    exerciseTime: 90,
                    restTime: 0,
                    repeatCount: 1
                ),
                Round(
                    exersise: ["Mountain Climbers", "Russian Twists", "Jumping Jacks", "Bicycle Crunches"],
                    exerciseTime: 30,
                    restTime: 15,
                    repeatCount: 4
                ),
                Round(
                    exersise: ["Stretch"],
                    exerciseTime: 60,
                    restTime: 0,
                    repeatCount: 1
                )
            ]
        ),
        // Study Routine (Pomodoro)
        Workout(
            name: "Study Pomodoro",
            rounds: [
                Round(
                    exersise: ["Study Focus"],
                    exerciseTime: 1500, // 25 min
                    restTime: 0,
                    repeatCount: 1
                ),
                Round(
                    exersise: ["Short Break"],
                    exerciseTime: 300, // 5 min
                    restTime: 0,
                    repeatCount: 1
                ),
                Round(
                    exersise: ["Study Focus"],
                    exerciseTime: 1500,
                    restTime: 0,
                    repeatCount: 1
                ),
                Round(
                    exersise: ["Long Break"],
                    exerciseTime: 900, // 15 min
                    restTime: 0,
                    repeatCount: 1
                )
            ]
        )
    ]
}
