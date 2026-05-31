//
// Copyright © 2024 Alexander Romanov
// ArticleBlock.swift, created on 03.03.2024
//

import Foundation

public enum BlockType: Sendable {
    case text, image, separator, quote, list, numberedList
}

public struct ArticleBlock: Identifiable, @unchecked Sendable {
    public let id: UUID
    public var type: BlockType
    public var text: NSAttributedString
    public var imageData: Data?

    public init(text: String = "") {
        id = UUID()
        type = .text
        self.text = NSAttributedString(string: text)
    }

    public init(imageData: Data) {
        id = UUID()
        type = .image
        text = NSAttributedString()
        self.imageData = imageData
    }

    public init(type: BlockType, text: String = "") {
        id = UUID()
        self.type = type
        self.text = NSAttributedString(string: text)
    }

    init(id: UUID, type: BlockType, text: NSAttributedString) {
        self.id = id
        self.type = type
        self.text = text
    }
}
