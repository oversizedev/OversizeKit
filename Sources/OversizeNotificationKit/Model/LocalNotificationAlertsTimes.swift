//
// Copyright © 2023 Alexander Romanov
// LocalNotificationAlertsTimes.swift
//

import Foundation

public enum LocalNotificationTime: CaseIterable, Equatable, Identifiable, @unchecked Sendable {
    case oneMinuteBefore, fiveMinutesBefore, tenMinutesBefore, thirtyMinutesBefore, oneHourBefore, twoHoursBefore, oneDayBefore, twoDaysBefore, oneWeekBefore

    public var title: String {
        switch self {
        case .oneMinuteBefore:
            "1 minute before"
        case .fiveMinutesBefore:
            "5 minutes before"
        case .tenMinutesBefore:
            "10 minutes before"
        case .thirtyMinutesBefore:
            "30 minutes before"
        case .oneHourBefore:
            "1 hour before"
        case .twoHoursBefore:
            "2 hours before"
        case .oneDayBefore:
            "1 day before"
        case .twoDaysBefore:
            "2 days before"
        case .oneWeekBefore:
            "1 week before"
        }
    }

    public var timeInterval: TimeInterval {
        switch self {
        case .oneMinuteBefore:
            -1 * 60
        case .fiveMinutesBefore:
            -5 * 60
        case .tenMinutesBefore:
            -10 * 60
        case .thirtyMinutesBefore:
            -30 * 60
        case .oneHourBefore:
            -1 * 60 * 60
        case .twoHoursBefore:
            -2 * 60 * 60
        case .oneDayBefore:
            -1 * 24 * 60 * 60
        case .twoDaysBefore:
            -2 * 24 * 60 * 60
        case .oneWeekBefore:
            -7 * 24 * 60 * 60
        }
    }

    public var id: String {
        title
    }

    public static let allCases: [LocalNotificationTime] = [.oneMinuteBefore, .fiveMinutesBefore, .tenMinutesBefore, .thirtyMinutesBefore, .oneHourBefore, .twoHoursBefore, .oneDayBefore, .twoDaysBefore, .oneWeekBefore]
}
