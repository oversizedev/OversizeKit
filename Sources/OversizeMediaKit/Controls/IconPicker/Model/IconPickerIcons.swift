//
// Copyright © 2026 Alexander Romanov
// IconPickerIcons.swift, created on 29.05.2026
//

import OversizeResources
import OversizeUI
import SwiftUI

#if canImport(UIKit) && !os(watchOS)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

public enum IconPickerIcons {
    #if canImport(UIKit) && !os(watchOS)
    public static var defaultIcons: [UIImage] {
        baseIcons + extendedIcons
    }

    private static var baseIcons: [UIImage] {
        [
            UIImage(named: "Base/Activity/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Calendar/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Camera/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Category/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Chart/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Chat/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Clock/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Document/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Edit/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Folder/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Game/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Heart/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Home/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Location/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Lock/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Message/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Notification/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Phone/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Picture/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Profile/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Search/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Setting/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/ShieldDone/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Star/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Ticket/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Upload/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Video/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Wallet/Fill", in: .oversizeUI, compatibleWith: nil),
            UIImage(named: "Base/Work/Fill", in: .oversizeUI, compatibleWith: nil),
        ].compactMap { $0 }
    }

    private static var extendedIcons: [UIImage] {
        [
            UIImage.Alert.Help.Circle.fill,
            UIImage.Alert.Info.Circle.fill,
            UIImage.Alert.Megaphone.fill,
            UIImage.Banking.Card.fill,
            UIImage.ChartAndAnalytics.ChartCircle.fill,
            UIImage.ComputerAndTV.KeyboardCloseDown.fill,
            UIImage.Delivery.Delivery.fill,
            UIImage.Design.PaintingPalette.fill,
            UIImage.Design.Pencil.fill,
            UIImage.Design.Ruler.fill,
            UIImage.Documentation.Clipboard.fill,
            UIImage.Documentation.Note.fill,
            UIImage.Editor.Link.Square.fill,
            UIImage.Editor.Marker.fill,
            UIImage.Electricity.Flash.fill,
            UIImage.Electricity.Lamp.fill,
            UIImage.Email.Email.fill,
            UIImage.FilterAndSetting.Dashboard1.fill,
            UIImage.Food.FoodPlate.fill,
            UIImage.Food.HotDrink.fill,
            UIImage.FruitVegetables.Carrot.fill,
            UIImage.HandGesture.Hand.fill,
            UIImage.Mobile.Vibration.fill,
            UIImage.TicketAndTag.Tag.fill,
            UIImage.Weather.Cloud.fill,
        ]
    }

    #elseif canImport(AppKit)
    public static var defaultIcons: [NSImage] {
        baseIcons + extendedIcons
    }

    private static var baseIcons: [NSImage] {
        [
            Bundle.oversizeUI.image(forResource: "Base/Activity/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Calendar/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Camera/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Category/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Chart/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Chat/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Clock/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Document/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Edit/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Folder/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Game/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Heart/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Home/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Location/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Lock/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Message/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Notification/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Phone/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Picture/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Profile/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Search/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Setting/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/ShieldDone/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Star/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Ticket/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Upload/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Video/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Wallet/Fill"),
            Bundle.oversizeUI.image(forResource: "Base/Work/Fill"),
        ].compactMap { $0 }
    }

    private static var extendedIcons: [NSImage] {
        [
            NSImage.Alert.Help.Circle.fill,
            NSImage.Alert.Info.Circle.fill,
            NSImage.Alert.Megaphone.fill,
            NSImage.Banking.Card.fill,
            NSImage.ChartAndAnalytics.ChartCircle.fill,
            NSImage.ComputerAndTV.KeyboardCloseDown.fill,
            NSImage.Delivery.Delivery.fill,
            NSImage.Design.PaintingPalette.fill,
            NSImage.Design.Pencil.fill,
            NSImage.Design.Ruler.fill,
            NSImage.Documentation.Clipboard.fill,
            NSImage.Documentation.Note.fill,
            NSImage.Editor.Link.Square.fill,
            NSImage.Editor.Marker.fill,
            NSImage.Electricity.Flash.fill,
            NSImage.Electricity.Lamp.fill,
            NSImage.Email.Email.fill,
            NSImage.FilterAndSetting.Dashboard1.fill,
            NSImage.Food.FoodPlate.fill,
            NSImage.Food.HotDrink.fill,
            NSImage.FruitVegetables.Carrot.fill,
            NSImage.HandGesture.Hand.fill,
            NSImage.Mobile.Vibration.fill,
            NSImage.TicketAndTag.Tag.fill,
            NSImage.Weather.Cloud.fill,
        ]
    }
    #endif
}
