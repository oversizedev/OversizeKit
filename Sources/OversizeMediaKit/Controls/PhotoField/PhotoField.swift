//
// Copyright © 2023 Alexander Romanov
// PhotoField.swift, created on 20.11.2023
//

import OversizeLocalizable
import OversizeUI
import SwiftUI

#if os(iOS)
@available(iOS 17.0, *)
public struct PhotoField: View {
    @Binding var selection: UIImage?
    @State var isShowSelector: Bool = false

    public init(_ selection: Binding<UIImage?>) {
        _selection = selection
    }

    public var body: some View {
        field
            .animation(.default, value: selection)
            .sheet(isPresented: $isShowSelector) {
                NavigationView {
                    PhotoLibraryPicker(selection: $selection)
                }
            }
    }

    private var field: some View {
        Button {
            isShowSelector.toggle()
        } label: {
            HStack {
                Text("Add photo")

                Spacer()

                Image.Base.camera
                    .icon()
            }
        }
        .buttonStyle(.field)
    }
}

@available(iOS 17.0, *)
#Preview {
    PhotoField(.constant(nil))
        .padding()
}
#endif
