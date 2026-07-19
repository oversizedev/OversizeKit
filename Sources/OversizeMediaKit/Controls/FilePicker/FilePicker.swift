//
// Copyright © 2026 Alexander Romanov
// FilePicker.swift
//

import OversizeResources
import OversizeUI
import SwiftUI

#if os(iOS)
struct RecentFileEntry: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let urlString: String
    let date: Date
    var url: URL? {
        URL(string: urlString)
    }
}

public struct FilePicker: View {
    @Environment(\.dismiss) private var dismiss

    @Binding public var url: URL?

    public init(url: Binding<URL?>) {
        _url = url
    }

    @AppStorage("MediaPicker.RecentFiles") private var recentFilesData: Data = .init()
    @State private var recentFiles: [RecentFileEntry] = []
    @State private var isShowDocumentPicker = false
    @State private var isShowScanner = false

    public var body: some View {
        ListLayoutView("File") {
            Section {
                Button { isShowDocumentPicker = true } label: {
                    ListRow("Select in Files", leading: { Image.Base.folder.iconOnSurface()
                    })
                }

                Button { isShowScanner = true } label: {
                    ListRow("Scan document", leading: { Image.Base.camera.iconOnSurface()
                    })
                }
            }

            if !recentFiles.isEmpty {
                Section("Recent used") {
                    ForEach(recentFiles) { entry in
                        ListRow(
                            entry.name,
                            subtitle: entry.date.formatted(
                                date: .abbreviated,
                                time: .shortened

                            ),
                            leading: {
                                Image.Base.document.iconOnSurface()
                            }
                        )
                        .swipeActions {
                            Button(action: { removeRecent(id: entry.id) }) {
                                Label {
                                    Text("Delete")
                                } icon: {
                                    Image.Design.PencilAndSquare.mini
                                }
                            }
                            .tint(.error)
                        }
                    }
                }
                .listRowSeparator(.hidden, edges: .all)
            }
        }
        .listLayoutStyle(.insetGrouped)
        .toolbarTitleDisplayMode(.inline)
        .fileImporter(
            isPresented: $isShowDocumentPicker,
            allowedContentTypes: [.item],
            allowsMultipleSelection: false
        ) { result in
            if case let .success(urls) = result, let picked = urls.first {
                let accessing = picked.startAccessingSecurityScopedResource()
                defer {
                    if accessing {
                        picked.stopAccessingSecurityScopedResource()
                    }
                }
                saveRecent(url: picked)
                url = persistentCopy(of: picked)
            }
            dismiss()
        }
        .fullScreenCover(isPresented: $isShowScanner) {
            DocumentScanner(selectedURL: $url) {
                if let scanned = url {
                    saveRecent(url: scanned)
                }
                isShowScanner = false
                dismiss()
            }
            .ignoresSafeArea()
        }
        .onAppear {
            loadRecent()
        }
    }

    // MARK: - Recent Files

    private func loadRecent() {
        guard !recentFilesData.isEmpty,
              let decoded = try? JSONDecoder().decode([RecentFileEntry].self, from: recentFilesData)
        else { return }
        recentFiles = decoded
    }

    private func saveRecent(url: URL) {
        let persistentURL = persistentCopy(of: url)
        let entry = RecentFileEntry(
            id: UUID().uuidString,
            name: persistentURL.lastPathComponent,
            urlString: persistentURL.absoluteString,
            date: .now
        )
        var updated = recentFiles.filter { $0.urlString != persistentURL.absoluteString }
        updated.insert(entry, at: 0)
        if updated.count > 10 {
            updated = Array(updated.prefix(10))
        }
        recentFiles = updated
        recentFilesData = (try? JSONEncoder().encode(updated)) ?? Data()
    }

    private func persistentCopy(of url: URL) -> URL {
        let supportDir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MediaPickerRecents", isDirectory: true)
        try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        let destination = supportDir.appendingPathComponent(url.lastPathComponent)
        if !FileManager.default.fileExists(atPath: destination.path) {
            try? FileManager.default.copyItem(at: url, to: destination)
        }
        return destination
    }

    private func removeRecent(id: String) {
        recentFiles.removeAll { $0.id == id }
        recentFilesData = (try? JSONEncoder().encode(recentFiles)) ?? Data()
    }
}

#Preview {
    NavigationStack {
        FilePicker(url: .constant(nil))
    }
}
#endif
