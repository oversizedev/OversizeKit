//
// Copyright © 2023 Alexander Romanov
// PhotosField.swift
//

import OversizeLocalizable
import OversizeUI
import SwiftUI

#if os(iOS)

@available(iOS 17.0, *)
public struct PhotosField: View {
    @Binding var selection: [UIImage]
    @Binding var selectionDate: [Date]
    @State var isShowSelector: Bool = false

    public init(_ selection: Binding<[UIImage]>, selectionDate: Binding<[Date]>) {
        _selection = selection
        _selectionDate = selectionDate
    }

    public var body: some View {
        field
            .animation(.default, value: selection)
            .sheet(isPresented: $isShowSelector) {
                NavigationStack {
                    PhotoLibraryPicker(selection: $selection, dates: $selectionDate)
                }
            }
    }

    @ViewBuilder
    var field: some View {
        if selection.isEmpty {
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
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(alignment: .top, spacing: .xSmall) {
                    addPhotoSurface

                    ForEach(selection, id: \.self) { photo in
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 128, height: 128)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    if let index = selection.firstIndex(of: photo) {
                                        selection.remove(at: index)
                                        selectionDate.remove(at: index)
                                    }

                                } label: {
                                    Icon(Image.Base.Close.mini)
                                        .iconColor(.white)
                                        .padding(.xxxSmall)
                                        .background {
                                            Circle()
                                                .fill(.thinMaterial)
                                        }
                                        .padding(.xxSmall)
                                }
                                .buttonStyle(.scale)
                            }
                            .cornerRadius(.medium)
                    }
                }
            }
        }
    }

    var addPhotoSurface: some View {
        Surface {
            isShowSelector.toggle()
        } label: {
            VStack(spacing: .xSmall) {
                Circle()
                    .fill(Color.surfacePrimary)
                    .frame(width: 48, height: 48)
                    .shadowElevation(.z1)
                    .overlay {
                        Icon(Image.Base.plus).iconColor(.onSurfacePrimary)
                            .shadowElevation(.z1)
                    }
                Text(L10n.Button.add)
                    .headline(.semibold)
                    .onSurfacePrimary()
            }
            .frame(width: 104)
        }
        .surfaceBackgroundColor(.surfacePrimary)
        .surfaceBorderColor(.surfaceSecondary)
        .surfaceBorderWidth(2)
        .surfaceContentMargins(EdgeInsets(top: .medium, leading: .xxSmall, bottom: .medium, trailing: .xxSmall))
    }
}

@available(iOS 17.0, *)
struct PhotosFieldView_Previews: PreviewProvider {
    static var previews: some View {
        PhotosField(.constant([]), selectionDate: .constant([]))
            .previewComponent()
    }
}
#endif
