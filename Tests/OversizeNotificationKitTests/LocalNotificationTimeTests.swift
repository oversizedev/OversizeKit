//
// Copyright © 2026 Alexander Romanov
// LocalNotificationTimeTests.swift
//

import Foundation
@testable import OversizeNotificationKit
import Testing

@Suite("LocalNotificationTime")
struct LocalNotificationTimeTests {
    @Test("Every case offsets the notification before the event")
    func timeIntervalIsNegative() {
        for time in LocalNotificationTime.allCases {
            #expect(time.timeInterval < 0, "\(time) should fire before the event")
        }
    }

    @Test("Cases are ordered from the closest offset to the furthest")
    func casesAreOrderedByProximity() {
        let intervals = LocalNotificationTime.allCases.map(\.timeInterval)
        #expect(intervals == intervals.sorted(by: >))
    }

    @Test("Identifiers are unique")
    func identifiersAreUnique() {
        let identifiers = LocalNotificationTime.allCases.map(\.id)
        #expect(Set(identifiers).count == identifiers.count)
    }

    @Test(
        "Named offsets match their duration",
        arguments: [
            (LocalNotificationTime.oneMinuteBefore, TimeInterval(-60)),
            (.tenMinutesBefore, -600),
            (.oneHourBefore, -3600),
            (.oneDayBefore, -86400),
            (.oneWeekBefore, -604_800),
        ]
    )
    func offsetMatchesDuration(_ time: LocalNotificationTime, _ expected: TimeInterval) {
        #expect(time.timeInterval == expected)
    }

    @Test("allCases covers every declared case")
    func allCasesIsComplete() {
        #expect(LocalNotificationTime.allCases.count == 9)
    }
}
