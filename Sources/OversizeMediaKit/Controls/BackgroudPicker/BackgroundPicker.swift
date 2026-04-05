//
// Copyright © 2026 Alexander Romanov
// BackgroundPicker.swift
//

import OversizeUI
import SwiftUI

#if os(iOS)
@available(iOS 17.0, *)
public struct BackgroundPicker: View {
    @Environment(\.dismiss) var dismiss

    @Binding private var selection: BackgroundPickerResult

    // MARK: - Presets

    private let presetImages: [UIImage]
    private let presetColors: [Color]
    private let presetGradients: [(startColor: Color, endColor: Color, direction: GradientDirection)]

    // MARK: - State

    @State private var selectedTab: BackgroundTab = .image
    @State private var isPhotoLibraryPresented = false
    @State private var isCustomGradientPickerPresented = false
    @State private var pickedImage: UIImage?
    @State private var selectedColor: Color = .blue
    @State private var gradientStart: Color = .blue
    @State private var gradientEnd: Color = .purple
    @State private var gradientDirection: GradientDirection = .topBottom

    // MARK: - Constants

    private static let threeColumnGrid = [
        GridItem(.flexible(), spacing: .xxxSmall),
        GridItem(.flexible(), spacing: .xxxSmall),
        GridItem(.flexible(), spacing: .xxxSmall),
    ]

    public static let defaultGradients: [(startColor: Color, endColor: Color, direction: GradientDirection)] = [
        (.blue, .purple, .topBottom),
        (.red, .orange, .topBottom),
        (.green, .teal, .topBottom),
        (.pink, .red, .leadingTrailing),
        (.orange, .yellow, .leadingTrailing),
        (.indigo, .blue, .topLeadingBottomTrailing),
        (.purple, .pink, .topLeadingBottomTrailing),
        (.teal, .green, .topTrailingBottomLeading),
        (.cyan, .blue, .bottomTop),
    ]

    public static let defaultColors: [Color] = Palette.baseColors

    // MARK: - Init

    public init(
        selection: Binding<BackgroundPickerResult>,
        images: [UIImage] = [],
        colors: [Color] = BackgroundPicker.defaultColors,
        gradients: [(startColor: Color, endColor: Color, direction: GradientDirection)] = BackgroundPicker.defaultGradients
    ) {
        _selection = selection
        presetImages = images
        presetColors = colors
        presetGradients = gradients
    }

    // MARK: - Body

    public var body: some View {
        LayoutView("Background") {
            content
                .padding(.horizontal, .xxSmall)
                .padding(.vertical, .small)
        }
        .safeAreaBarTop {
            tabBar
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close", systemImage: "xmark", role: .cancel) { dismiss() }
                    .labelStyle(.toolbar)
                    .buttonStyle(.toolbarSecondary)
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .sheet(isPresented: $isPhotoLibraryPresented) {
            NavigationStack {
                PhotoLibraryPicker(selection: $pickedImage)
                    .hideCamera()
            }
        }
        .onChange(of: pickedImage) { _, image in
            if let image {
                selection = .image(image)
            }
        }
        .onAppear {
            syncStateFromSelection()
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        Picker("", selection: $selectedTab) {
            ForEach(BackgroundTab.allCases) { tab in
                Text(tab.title).tag(tab)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, .xSmall)
        .padding(.top, .xxSmall)
        .controlSize(.large)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var content: some View {
        switch selectedTab {
        case .image: imageTabContent
        case .color: colorTabContent
        case .gradient: gradientTabContent
        }
    }

    // MARK: - Image Tab

    private var imageTabContent: some View {
        VStack(alignment: .leading, spacing: .medium) {
            if let pickedImage {
                pickedImagePreview(pickedImage)
            }

            LazyVGrid(columns: BackgroundPicker.threeColumnGrid, spacing: .xxxSmall) {
                addPhotoCell
                ForEach(presetImages.indices, id: \.self) { index in
                    imageCell(presetImages[index])
                }
            }
        }
    }

    private func pickedImagePreview(_ image: UIImage) -> some View {
        VStack(alignment: .leading, spacing: .xSmall) {
            Text("Selected Photo")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ZStack(alignment: .topTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 180)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button {
                    pickedImage = nil
                    if case .image = selection {
                        if !presetImages.isEmpty {
                            selection = .image(presetImages[0])
                        }
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                }
                .padding(8)
            }
        }
    }

    private var addPhotoCell: some View {
        Color.secondary.opacity(0.15)
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: .small, style: .continuous))
            .padding(4)
            .overlay {
                RoundedRectangle(cornerRadius: .small + 4, style: .continuous)
                    .strokeBorder(Color.clear, lineWidth: 2)
            }
            .overlay {
                Image(systemName: "photo.badge.plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            .contentShape(RoundedRectangle(cornerRadius: .small + 4, style: .continuous))
            .onTapGesture {
                isPhotoLibraryPresented = true
            }
    }

    private func imageCell(_ image: UIImage) -> some View {
        let isSelected: Bool = {
            if case let .image(current) = selection {
                return current === image
            }
            return false
        }()

        return Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: .small, style: .continuous))
            .padding(4)
            .overlay {
                RoundedRectangle(cornerRadius: .small + 4, style: .continuous)
                    .strokeBorder(isSelected ? Color.accent : Color.clear, lineWidth: 2)
            }
            .overlay(alignment: .bottomTrailing) {
                if isSelected {
                    Icon(Image.Base.Check.mini)
                        .iconColor(Color.onSurfaceSecondary)
                        .background { Circle().surfacePrimary() }
                        .padding(.small)
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: .small + 4, style: .continuous))
            .onTapGesture {
                selection = .image(image)
            }
    }

    // MARK: - Color Tab

    private var colorTabContent: some View {
        LazyVGrid(columns: BackgroundPicker.threeColumnGrid, spacing: .xxxSmall) {
            ForEach(presetColors.indices, id: \.self) { index in
                colorCell(presetColors.element(index) ?? Color.clear)
            }
            customColorCell
        }

        .onChange(of: selectedColor) { _, color in
            if selectedTab == .color {
                selection = .color(color)
            }
        }
    }

    private var customColorCell: some View {
        AngularGradient(
            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple, .red]),
            center: .center
        )
        .aspectRatio(1, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: .small, style: .continuous))
        .padding(4)
        .overlay {
            RoundedRectangle(cornerRadius: .small + 4, style: .continuous)
                .strokeBorder(Color.clear, lineWidth: 2)
        }
        .overlay {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .shadow(radius: 4)
        }
        .overlay {
            ColorPicker("", selection: $selectedColor)
                .labelsHidden()
                .opacity(0.05)
        }
        .contentShape(RoundedRectangle(cornerRadius: .small + 4, style: .continuous))
    }

    private func colorCell(_ color: Color) -> some View {
        let isSelected: Bool = {
            if case let .color(current) = selection {
                return current == color
            }
            return false
        }()

        return color
            .aspectRatio(1, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: .small, style: .continuous))
            .padding(4)
            .overlay {
                RoundedRectangle(cornerRadius: .small + 4, style: .continuous)
                    .strokeBorder(isSelected ? Color.accent : Color.clear, lineWidth: 2)
            }
            .overlay(alignment: .bottomTrailing) {
                if isSelected {
                    Icon(Image.Base.Check.mini)
                        .iconColor(Color.onSurfaceSecondary)
                        .background {
                            Circle().surfacePrimary()
                        }
                        .padding(.small)
                }
            }
            .onTapGesture {
                selectedColor = color
                selection = .color(color)
            }
    }

    // MARK: - Gradient Tab

    private var gradientTabContent: some View {
        LazyVGrid(columns: BackgroundPicker.threeColumnGrid, spacing: .xxxSmall) {
            ForEach(presetGradients.indices, id: \.self) { index in
                gradientCell(presetGradients[index], index: index)
            }
            customGradientCell
        }
        .onChange(of: gradientStart) { _, _ in
            if selectedTab == .gradient {
                selection = .gradient(startColor: gradientStart, endColor: gradientEnd, direction: gradientDirection)
            }
        }
        .onChange(of: gradientEnd) { _, _ in
            if selectedTab == .gradient {
                selection = .gradient(startColor: gradientStart, endColor: gradientEnd, direction: gradientDirection)
            }
        }
        .onChange(of: gradientDirection) { _, _ in
            if selectedTab == .gradient {
                selection = .gradient(startColor: gradientStart, endColor: gradientEnd, direction: gradientDirection)
            }
        }
        .sheet(isPresented: $isCustomGradientPickerPresented) {
            NavigationStack {
                GradientPicker(
                    startColor: $gradientStart,
                    endColor: $gradientEnd,
                    direction: $gradientDirection
                )
            }
            .presentationDetents([.large])
        }
    }

    private var customGradientCell: some View {
        LinearGradient(
            colors: [.purple, .blue, .cyan, .green],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .aspectRatio(1, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: .small, style: .continuous))
        .padding(4)
        .overlay {
            RoundedRectangle(cornerRadius: .small + 4, style: .continuous)
                .strokeBorder(Color.clear, lineWidth: 2)
        }
        .overlay {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .shadow(radius: 4)
        }
        .contentShape(RoundedRectangle(cornerRadius: .small + 4, style: .continuous))
        .onTapGesture {
            isCustomGradientPickerPresented = true
        }
    }

    private func gradientCell(
        _ preset: (startColor: Color, endColor: Color, direction: GradientDirection),
        index _: Int
    ) -> some View {
        let isSelected: Bool = {
            if case let .gradient(s, e, d) = selection {
                return s == preset.startColor && e == preset.endColor && d == preset.direction
            }
            return false
        }()

        return LinearGradient(
            colors: [preset.startColor, preset.endColor],
            startPoint: preset.direction.startPoint,
            endPoint: preset.direction.endPoint
        )
        .aspectRatio(1, contentMode: .fill)
        .clipShape(RoundedRectangle(cornerRadius: .small, style: .continuous))
        .padding(4)
        .overlay {
            RoundedRectangle(cornerRadius: .small + 4, style: .continuous)
                .strokeBorder(isSelected ? Color.accent : Color.clear, lineWidth: 2)
        }
        .overlay(alignment: .bottomTrailing) {
            if isSelected {
                Icon(Image.Base.Check.mini)
                    .iconColor(Color.onSurfaceSecondary)
                    .background { Circle().surfacePrimary() }
                    .padding(.small)
            }
        }
        .contentShape(RoundedRectangle(cornerRadius: .small + 4, style: .continuous))
        .onTapGesture {
            gradientStart = preset.startColor
            gradientEnd = preset.endColor
            gradientDirection = preset.direction
            selection = .gradient(startColor: preset.startColor, endColor: preset.endColor, direction: preset.direction)
        }
    }

    // MARK: - State Sync

    private func syncStateFromSelection() {
        switch selection {
        case let .color(c):
            selectedColor = c
            selectedTab = .color
        case let .gradient(s, e, d):
            gradientStart = s
            gradientEnd = e
            gradientDirection = d
            selectedTab = .gradient
        case .image:
            selectedTab = .image
        case .builtIn:
            selectedTab = .image
        }
    }
}

// MARK: - BackgroundTab

extension BackgroundPicker {
    enum BackgroundTab: String, CaseIterable, Identifiable {
        case image
        case color
        case gradient

        var id: String {
            rawValue
        }

        var title: String {
            switch self {
            case .image: "Image"
            case .color: "Color"
            case .gradient: "Gradient"
            }
        }
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview("Image") {
    NavigationStack {
        BackgroundPicker(selection: .constant(.image(.actions)))
    }
}

@available(iOS 17.0, *)
#Preview("Color") {
    NavigationStack {
        BackgroundPicker(selection: .constant(.color(.blue)))
    }
}

@available(iOS 17.0, *)
#Preview("Gradient") {
    NavigationStack {
        BackgroundPicker(selection: .constant(.gradient(startColor: .blue, endColor: .purple, direction: .topBottom)))
    }
}
#endif
