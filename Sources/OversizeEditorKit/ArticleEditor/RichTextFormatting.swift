////
//// Copyright © 2024 Alexander Romanov
//// RichTextFormatting.swift, created on 14.05.2026
////
//
// import Foundation
// import SwiftUI
//
//// MARK: - Block Format Value
//
// @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
// public enum RichBlockFormat: Codable, Sendable, Hashable {
//    case blockQuote
//    case listItem
// }
//
//// MARK: - Custom Attribute Key
//
// @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
// public struct RichBlockFormatAttribute: CodableAttributedStringKey {
//    public typealias Value = RichBlockFormat
//    public static let name = "OversizeEditorKit.RichBlockFormatAttribute"
//    public static let runBoundaries: AttributedString.AttributeRunBoundaries? = .paragraph
//    public static let inheritedByAddedText: Bool = false
// }
//
//// MARK: - Attribute Scope
//
// @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
// public extension AttributeScopes {
//    struct RichTextEditorAttributes: AttributeScope {
//        public let blockFormat: RichBlockFormatAttribute
//        public let foregroundColor: AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute
//        public let font: AttributeScopes.SwiftUIAttributes.FontAttribute
//    }
// }
//
//// MARK: - Formatting Definition
//
// @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
// public struct RichTextFormattingDefinition: AttributedTextFormattingDefinition {
//    public typealias Scope = AttributeScopes.RichTextEditorAttributes
//    public init() {}
//    public var body: some AttributedTextFormattingDefinition<Scope> {
//        BlockQuoteFont()
//        BlockQuoteColor()
//    }
// }
//
//// MARK: - Constraints
//
// @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
// struct BlockQuoteFont: AttributedTextValueConstraint {
//    typealias Scope = RichTextFormattingDefinition.Scope
//    typealias AttributeKey = AttributeScopes.SwiftUIAttributes.FontAttribute
//
//    func constrain(_ container: inout Attributes) {
//        guard container[RichBlockFormatAttribute.self] == .blockQuote else { return }
//        container.font = .body.italic()
//    }
// }
//
// @available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, visionOS 26.0, *)
// struct BlockQuoteColor: AttributedTextValueConstraint {
//    typealias Scope = RichTextFormattingDefinition.Scope
//    typealias AttributeKey = AttributeScopes.SwiftUIAttributes.ForegroundColorAttribute
//
//    func constrain(_ container: inout Attributes) {
//        guard container[RichBlockFormatAttribute.self] == .blockQuote else { return }
//        container.foregroundColor = .secondary
//    }
// }
