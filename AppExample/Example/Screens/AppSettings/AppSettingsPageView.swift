//
// Copyright © 2023 Alexander Romanov
// AppSettingsPageView.swift, created on 25.09.2023
//  

import OversizeUI
import SwiftUI

struct AppSettingsPageView: View {
    @StateObject var viewModel: AppSettingsPageViewModel

    init() {
        _viewModel = StateObject(wrappedValue: AppSettingsPageViewModel())
    }

    var body: some View {
        PageView("Option") {
            SectionView {
                VStack(spacing: .zero) {
                    Row("Default option") {
                        Image(systemName: "")
                    }
                }
            }
            .sectionContentCompactRowMargins()
        }
        .leadingBar {
            BarButton(.back)
        }
    }
}

struct AppSettingsPageView_ViewPreviews: PreviewProvider {
    static var previews: some View {
        AppSettingsPageView()
    }
}
