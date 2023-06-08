//
// Copyright © 2023 Alexander Romanov
// PhotoOptionsView.swift, created on 08.05.2023
//

import OversizeUI
import SwiftUI

private struct SharePhoto: Transferable {
    @available(iOS 16.0, *)
    fileprivate static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }

    fileprivate var image: Image
}

public struct PhotoOptionsView<A>: View where A: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    private let image: Image

    private let photo: SharePhoto

    private let date: Date?
    private let actions: Group<A>?
    private let deleteAction: (() -> Void)?

    @State private var isShowAlert: Bool = false

    public init(
        image: Image,
        date: Date?,
        @ViewBuilder actions: @escaping () -> A,
        deleteAction: (() -> Void)? = nil
    ) {
        self.image = image
        self.date = date
        photo = SharePhoto(image: image)
        self.actions = Group { actions() }
        self.deleteAction = deleteAction
    }

    public var body: some View {
        PageView {
            content
        }
        .titleLabel {
            Row("Photo", subtitle: date?.formatted(date: .long, time: .omitted)) {
                image
            }
            .rowContentInset(.init(horizontal: .zero, vertical: .xSmall))
        }
        .trailingBar { BarButton(.close) }
        .backgroundSecondary()
        .alert("Are you sure you want to delete?", isPresented: $isShowAlert) {
            Button("Delete", role: .destructive) {
                deleteAction?()
            }
        }
    }

    private var content: some View {
        VStack(spacing: .medium) {
            SectionView {
                VStack {
                    if #available(iOS 16.0, *) {
                        ShareLink(
                            item: photo,
                            preview: SharePreview(
                                "Photo",
                                image: photo.image
                            )
                        ) {
                            Row("Share") {
                                Icon(Icons.Base.upload)
                            }
                        }
                    }

                    actions
                }
                .buttonStyle(.row)
            }
            .surfaceContentRowInsets()

            if deleteAction != nil {
                SectionView {
                    VStack {
                        RowButton("Delete", style: .delete, action: {
                            isShowAlert.toggle()
                        })
                        .multilineTextAlignment(.center)
                    }
                }
                .surfaceContentRowInsets()
            }
        }
        .padding(.top, -16)
    }
}
