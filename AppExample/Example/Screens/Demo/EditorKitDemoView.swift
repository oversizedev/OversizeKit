//
// Copyright © 2026 Alexander Romanov
// EditorKitDemoView.swift, created on 06.09.2026
//

import OversizeEditorKit
import OversizeKit
import OversizeUI
import SwiftUI

struct EditorKitDemoView: View {
    @State private var note: String = "OversizeKit ships the screens every app repeats."
    @State private var richText: AttributedString = .init("Rich text editor with formatting bar")
    @State private var link: URL?
    @State private var textStyle: Font.TextStyle = .body
    @State private var fontDesign: Font.Design = .default
    @State private var fontName: String?

    @State private var isShowNoteViewer = false
    @State private var isShowTextStylePicker = false
    @State private var isShowFontPicker = false
    @State private var isShowSystemFontPicker = false

    var body: some View {
        ScrollView {
            VStack(spacing: .small) {
                SectionView("Note") {
                    NoteEditor("Note", text: $note)
                        .frame(minHeight: 160)
                }

                SectionView("Rich text") {
                    RichTextEditor("Rich text", text: $richText)
                        .frame(minHeight: 200)
                }

                SectionView("Link") {
                    URLEditor("Link", url: $link) {
                        EmptyView()
                    }
                }

                SectionView("Screens") {
                    VStack(spacing: .zero) {
                        Row("Note viewer") {
                            isShowNoteViewer = true
                        } leading: {
                            Image(systemName: "doc.text")
                        }
                        .navigatable()
                        .buttonStyle(.row)

                        Row("Text style") {
                            isShowTextStylePicker = true
                        } leading: {
                            Image(systemName: "textformat.size")
                        }
                        .navigatable()
                        .buttonStyle(.row)

                        Row("Font", subtitle: fontName) {
                            isShowFontPicker = true
                        } leading: {
                            Image(systemName: "textformat")
                        }
                        .navigatable()
                        .buttonStyle(.row)

                        Row("System font") {
                            isShowSystemFontPicker = true
                        } leading: {
                            Image(systemName: "character")
                        }
                        .navigatable()
                        .buttonStyle(.row)
                    }
                }
                .sectionContentCompactRowMargins()
            }
            .paddingContent(.horizontal)
        }
        .background {
            Color.backgroundSecondary.ignoresSafeArea()
        }
        .navigationTitle("Editor")
        .sheet(isPresented: $isShowNoteViewer) {
            NavigationStack {
                NoteViewer("Note", text: note)
            }
        }
        .sheet(isPresented: $isShowTextStylePicker) {
            NavigationStack {
                TextStylePicker(selectedStyle: $textStyle)
            }
        }
        .sheet(isPresented: $isShowFontPicker) {
            NavigationStack {
                FontPicker(selectedFontName: $fontName)
            }
        }
        .sheet(isPresented: $isShowSystemFontPicker) {
            NavigationStack {
                SystemFontPicker(selectedDesign: $fontDesign, selectedFontName: $fontName)
            }
        }
    }
}

#Preview {
    NavigationStack {
        EditorKitDemoView()
    }
    .appEnvironment()
}
