import Foundation

// MARK: - WaterLog

struct WaterLog: Codable, Identifiable, Equatable {
    let id: UUID
    let timestamp: Date
    let amountOz: Double

    init(id: UUID = UUID(), timestamp: Date = Date(), amountOz: Double) {
        self.id = id
        self.timestamp = timestamp
        self.amountOz = amountOz
    }
}

// MARK: - DayStatus

enum DayStatus: Codable {
    case complete   // >= 100% of goal
    case partial    // 50–99%
    case behind     // < 50% with logs
    case none       // no logs at all
}

// MARK: - DayRecord

struct DayRecord {
    let date: Date
    let logs: [WaterLog]
    let goalOz: Double

    var totalOz: Double {
        logs.reduce(0) { $0 + $1.amountOz }
    }

    var percentComplete: Double {
        guard goalOz > 0 else { return 0 }
        return min(totalOz / goalOz, 1.0)
    }

    var status: DayStatus {
        let pct = percentComplete
        if pct >= 1.0 { return .complete }
        if pct >= 0.5 { return .partial }
        if logs.isEmpty { return .none }
        return .behind
    }
}

// MARK: - BottleState

struct BottleState: Identifiable {
    let id = UUID()
    /// 0.0 = empty, 1.0 = full, values in between = partial fill.
    let fillFraction: Double

    var isEmpty: Bool { fillFraction == 0 }
    var isFull: Bool { fillFraction >= 1.0 }
    var isPartial: Bool { fillFraction > 0 && fillFraction < 1.0 }
}
