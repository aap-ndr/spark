//
//  CycleHelpers.swift
//  Spark
//
//  Purpose:
//  Cycle tracking calculation and formatting helpers.
//
//  Responsibilities:
//  • Computes averages, predictions, and display labels.
//

import Foundation

enum CycleContent {
    static let minLength = 20
    static let maxLength = 45
    static let lengthChoices = [21, 24, 26, 28, 30, 32, 35]
    static let dayMilliseconds: Int64 = 86_400_000

    static func clampLength(_ value: Int) -> Int {
        min(maxLength, max(minLength, value))
    }
}

enum CycleHelpers {
    static func toMidnight(_ date: Date) -> Int64 {
        let start = Calendar.current.startOfDay(for: date)
        return Int64(start.timeIntervalSince1970 * 1000)
    }

    static func daysBetween(_ a: Int64, _ b: Int64) -> Int {
        Int(round(Double(a - b) / Double(CycleContent.dayMilliseconds)))
    }

    static func sameDay(_ a: Int64, _ b: Int64) -> Bool {
        toMidnight(Date(timeIntervalSince1970: TimeInterval(a) / 1000))
            == toMidnight(Date(timeIntervalSince1970: TimeInterval(b) / 1000))
    }

    static func formatDate(_ milliseconds: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        return date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
    }

    static func observedCycleLengths(entries: [CycleEntry]) -> [Int] {
        guard entries.count > 1 else { return [] }
        var lengths: [Int] = []
        for index in 0..<(entries.count - 1) {
            let gap = daysBetween(entries[index].startDate, entries[index + 1].startDate)
            lengths.append(gap)
        }
        return lengths
    }

    static func observedAverage(entries: [CycleEntry]) -> Int? {
        let lengths = observedCycleLengths(entries: entries)
        guard !lengths.isEmpty else { return nil }
        let sum = lengths.reduce(0, +)
        return Int(round(Double(sum) / Double(lengths.count)))
    }

    struct CycleStatus {
        let cycleDay: Int
        let nextStart: Int64
        let daysUntil: Int
    }

    static func cycleStatus(lastStart: Int64, averageCycleLength: Int, today: Int64? = nil) -> CycleStatus {
        let todayMidnight = today ?? toMidnight(Date())
        let cycleDay = daysBetween(todayMidnight, lastStart) + 1
        let nextStart = lastStart + Int64(averageCycleLength) * CycleContent.dayMilliseconds
        let daysUntil = daysBetween(nextStart, todayMidnight)
        return CycleStatus(cycleDay: cycleDay, nextStart: nextStart, daysUntil: daysUntil)
    }

    static func daysUntilLabel(_ daysUntil: Int) -> String {
        if daysUntil > 0 {
            return "in \(daysUntil) \(daysUntil == 1 ? "day" : "days")"
        }
        if daysUntil == 0 {
            return "expected today"
        }
        let absolute = abs(daysUntil)
        return "\(absolute) \(absolute == 1 ? "day" : "days") ago"
    }
}
