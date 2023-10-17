//
// Copyright © 2023 Alexander Romanov
// AppSettingsPageViewModel.swift, created on 25.09.2023
//

import SwiftUI

@MainActor
class AppSettingsPageViewModel: ObservableObject {
    @AppStorage("AppState.Option") var option: String = ""
}
