import Foundation

// MARK: - Sex

enum Sex: String, CaseIterable, Codable, Identifiable {
    case male = "Male"
    case female = "Female"
    case preferNotToSay = "Prefer not to say"

    var id: String { rawValue }

    var emoji: String {
        switch self {
        case .male: return "♂️"
        case .female: return "♀️"
        case .preferNotToSay: return "⚧️"
        }
    }
}

// MARK: - ActivityLevel

enum ActivityLevel: String, CaseIterable, Codable, Identifiable {
    case sedentary = "Sedentary"
    case moderate = "Moderate"
    case active = "Active"

    var id: String { rawValue }

    var subtitle: String {
        switch self {
        case .sedentary: return "Desk job, little to no exercise"
        case .moderate: return "Exercise 3–5 days per week"
        case .active: return "Daily intense workouts"
        }
    }

    var emoji: String {
        switch self {
        case .sedentary: return "🧘"
        case .moderate: return "🚶"
        case .active: return "🏃"
        }
    }

    var multiplier: Double {
        switch self {
        case .sedentary: return 1.0
        case .moderate: return 1.15
        case .active: return 1.3
        }
    }
}

// MARK: - UserProfile

struct UserProfile: Codable {
    var name: String
    var weightLbs: Double
    var sex: Sex
    var activityLevel: ActivityLevel
    var bottleSizeOz: Double
    var notificationStartHour: Int
    var notificationEndHour: Int

    init(
        name: String,
        weightLbs: Double,
        sex: Sex,
        activityLevel: ActivityLevel,
        bottleSizeOz: Double,
        notificationStartHour: Int = 8,
        notificationEndHour: Int = 21
    ) {
        self.name = name
        self.weightLbs = weightLbs
        self.sex = sex
        self.activityLevel = activityLevel
        self.bottleSizeOz = bottleSizeOz
        self.notificationStartHour = notificationStartHour
        self.notificationEndHour = notificationEndHour
    }

    /// Recommended daily intake in oz.
    /// Formula: (weight × 0.5) × activity multiplier, rounded to nearest 4 oz.
    var dailyGoalOz: Double {
        let base = weightLbs * 0.5
        let adjusted = base * activityLevel.multiplier
        return max(32.0, (adjusted / 4.0).rounded() * 4.0)
    }

    /// Number of full bottles the user needs to drink per day.
    var bottlesPerDay: Int {
        max(1, Int(ceil(dailyGoalOz / bottleSizeOz)))
    }
}
