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
                Text(selection == nil ? "Add photo" : "Change photo")
                    .frame(maxWidth: .infinity, alignment: .leading)

                if let selection {
                    Image(uiImage: selection)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 24, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .strokeBorder(Color.border, lineWidth: 0.5)
                        }
                } else {
                    Icon(Image.Base.camera)
                }
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
