//
// Copyright © 2023 Alexander Romanov
// LocalNotificationAlertsTimes.swift
//

import EventKit
import Foundation

public enum LocalNotificationAlertsTimes: CaseIterable, Equatable, Identifiable {
    case oneMinuteBefore, fiveMinutesBefore, tenMinutesBefore, thirtyMinutesBefore, oneHourBefore, twoHoursBefore, oneDayBefore, twoDaysBefore, oneWeekBefore

    public var title: String {
        switch self {
        case .oneMinuteBefore:
            return "1 minute before"
        case .fiveMinutesBefore:
            return "5 minutes before"
        case .tenMinutesBefore:
            return "10 minutes before"
        case .thirtyMinutesBefore:
            return "30 minutes before"
        case .oneHourBefore:
            return "1 hour before"
        case .twoHoursBefore:
            return "2 hours before"
        case .oneDayBefore:
            return "1 day before"
        case .twoDaysBefore:
            return "2 days before"
        case .oneWeekBefore:
            return "1 week before"
        }
    }

    public var timeInterval: TimeInterval {
        switch self {
        case .oneMinuteBefore:
            return -1 * 60
        case .fiveMinutesBefore:
            return -5 * 60
        case .tenMinutesBefore:
            return -10 * 60
        case .thirtyMinutesBefore:
            return -30 * 60
        case .oneHourBefore:
            return -1 * 60 * 60
        case .twoHoursBefore:
            return -2 * 60 * 60
        case .oneDayBefore:
            return -1 * 24 * 60 * 60
        case .twoDaysBefore:
            return -2 * 24 * 60 * 60
        case .oneWeekBefore:
            return -7 * 24 * 60 * 60
        }
    }

    public var id: String {
        title
    }

    public static var allCases: [LocalNotificationAlertsTimes] = [.oneMinuteBefore, .fiveMinutesBefore, .tenMinutesBefore, .thirtyMinutesBefore, .oneHourBefore, .twoHoursBefore, .oneDayBefore, .twoDaysBefore, .oneWeekBefore]
}
