//
// Copyright © 2024 Alexander Romanov
// ArticleBlock.swift, created on 03.03.2024
//

import Foundation

public enum BlockType: Sendable {
    case text, image, separator, quote, list
}

public struct ArticleBlock: Identifiable, Sendable {
    public let id: UUID
    public var type: BlockType
    public var text: AttributedString
    public var imageData: Data?

    public init(text: String = "") {
        id = UUID()
        type = .text
        self.text = AttributedString(text)
    }

    public init(imageData: Data) {
        id = UUID()
        type = .image
        text = AttributedString()
        self.imageData = imageData
    }

    public init(type: BlockType, text: String = "") {
        id = UUID()
        self.type = type
        self.text = AttributedString(text)
    }
}
