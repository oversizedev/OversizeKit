//
// Copyright © 2022 Alexander Romanov
// StoreSpecialOfferEventType.swift
//

import Foundation
import OversizeCDN

public enum StoreSpecialOfferEventType {
    case newUser, activeUser, oldUser, newYear, halloween, blackFriday, foolsDay, backToSchool

//    public var eventStartDate: DateFormatter? {
//        switch self {
//        case .newYear:
//            return Calendar.current.date(from: DateComponents())
//        case .halloween:
//
//        case .blackFriday:
//
//        case .foolsDay:
//
//        case .backToSchool:
//
//        default: return nil
//        }
    // }

    public var specialOfferSubtitle: String {
        switch self {
        case .activeUser, .oldUser: return "You have a gift"
        case .newUser: return "Special introductory Offer"
        case .newYear: return "Special New Year's offer"
        case .halloween: return "Halloween Special"
        case .blackFriday: return "Black Friday Special"
        default: return "Special offer"
        }
    }

    public var isNeedTrialDescription: Bool {
        switch self {
        case .activeUser, .oldUser: return false
        default: return true
        }
    }

    public var specialOfferTitle: String {
        switch self {
        case .newUser: return "Free full access\nfor" // \(trialDaysPeriodText)"
        case .activeUser: return "Special Offer\nfor active Users"
        case .oldUser: return "Special Offer\nfor Longtime Users"
        default: return "Free full access\nfor" // \(trialDaysPeriodText)"
        }
    }

    public var specialOfferDescription: String {
        switch self {
        case .newUser: return "Use the offer at low price\n and long trial periods for new users"
        case .activeUser: return "Take advantage of the low price\n offer and long trial periods"
        default: return "Take advantage of the low price\n offer and long trial periods"
        }
    }

    public var specialOfferImageURL: String {
        switch self {
        case .newUser: return IllustrationCDN.Objects.Christmas.Gift1.large
        case .activeUser: return IllustrationCDN.Objects.Christmas.Gift1.large
        case .oldUser: return IllustrationCDN.Objects.Sundry.Hand.large
        case .newYear: return IllustrationCDN.Objects.Christmas.Snowman.large
        case .halloween: return IllustrationCDN.Objects.Tools.Broom.large
        case .blackFriday: return IllustrationCDN.Objects.Tools.Bolt.large
        case .foolsDay: return IllustrationCDN.Objects.Sundry.Smile.large
        case .backToSchool: return IllustrationCDN.Objects.Education.Pencil2a.large
        }
    }
}
