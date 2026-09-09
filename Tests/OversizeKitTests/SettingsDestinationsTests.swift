//
// Copyright © 2026 Alexander Romanov
// SettingsDestinationsTests.swift
//

import Foundation
import NavigatorUI
@testable import OversizeKit
import Testing

@Suite("SettingsDestinations")
@MainActor
struct SettingsDestinationsTests {
    @Test("Modal destinations are presented as a managed sheet")
    func modalDestinationsUseManagedSheet() throws {
        let modalDestinations: [SettingsDestinations] = try [
            .premium,
            .support,
            .feedback,
            .setPINCode,
            .updatePINCode,
            .debugMenu,
            .debugInfo,
            .webView(url: #require(URL(string: "https://oversize.app"))),
            .sendMail(to: "support@oversize.app", subject: "Subject", content: "Content"),
        ]

        for destination in modalDestinations {
            #expect(destination.method == .managedSheet, "\(destination) should be presented modally")
        }
    }

    @Test("Settings sub-screens are pushed onto the stack")
    func settingsScreensUsePush() {
        let pushedDestinations: [SettingsDestinations] = [
            .appearance,
            .about,
            .security,
            .notifications,
            .sync,
            .soundAndVibration,
            .ourResources,
            .border,
            .font,
            .radius,
            .appUpdates,
            .premiumInstructions(specialOfferMode: false),
        ]

        for destination in pushedDestinations {
            #expect(destination.method == .push, "\(destination) should be pushed")
        }
    }

    @Test("Associated values distinguish otherwise equal destinations")
    func associatedValuesAffectEquality() throws {
        #expect(SettingsDestinations.premiumInstructions(specialOfferMode: true) != .premiumInstructions(specialOfferMode: false))
        #expect(try SettingsDestinations.webView(url: #require(URL(string: "https://oversize.app"))) != .webView(url: #require(URL(string: "https://romanov.cc"))))
    }

    @Test("PIN code destinations are distinct")
    func pinCodeDestinationsAreDistinct() {
        #expect(SettingsDestinations.setPINCode != .updatePINCode)
    }

    @Test("Equal destinations share a hash value")
    func equalDestinationsShareHashValue() {
        #expect(SettingsDestinations.appearance.hashValue == SettingsDestinations.appearance.hashValue)
    }
}
