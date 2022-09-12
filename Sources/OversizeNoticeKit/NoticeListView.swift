//
// Copyright © 2022 Alexander Romanov
// NoticeListView.swift
//

import OversizeUI
import SwiftUI

public struct NoticeListView: View {
    public init() {}

    public var body: some View {
        VStack(spacing: .small) {
            NoticeView("Title") {
                Button {
                    print("Ok")
                } label: {
                    Text("Primay")
                }
                .accent()
            }

            NoticeView("Title", subtitle: "Subtitle") {
                Button("Primay") {
                    print("Ok")
                }
                Button("Primay") {
                    print("Ok")
                }
                .buttonStyle(.tertiary)

            } closeAction: {
                print("Close")
            }
        }
    }
}

// struct NoticeListView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoticeListView()
//    }
// }
