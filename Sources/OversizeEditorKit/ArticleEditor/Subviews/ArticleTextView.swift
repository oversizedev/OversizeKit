//
// Copyright © 2024 Alexander Romanov
// ArticleTextView.swift
//

#if canImport(UIKit)
import SwiftUI
import UIKit

struct ArticleTextView: UIViewRepresentable {
    var text: NSAttributedString
    var isFocused: Bool
    var isFocusTransferring: Bool = false
    var defaultFont: UIFont = .preferredFont(forTextStyle: .body)
    var defaultTextColor: UIColor = .label
    var onTextChange: (NSAttributedString) -> Void
    var onSelectionChange: (NSRange, [NSAttributedString.Key: Any]) -> Void
    var onReturn: () -> Void
    var onDeleteWhenEmpty: () -> Void
    var onFocus: (UITextView) -> Void
    var onBlur: (UITextView) -> Void
    var onRegister: (UITextView) -> Void = { _ in }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.font = defaultFont
        textView.textColor = defaultTextColor
        textView.attributedText = text
        onRegister(textView)
        return textView
    }

    func updateUIView(_ textView: UITextView, context _: Context) {
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0

        if textView.attributedText != text {
            let range = textView.selectedRange
            textView.attributedText = text
            let safeRange = NSRange(
                location: min(range.location, textView.attributedText.length),
                length: 0
            )
            textView.selectedRange = safeRange
        }
        if isFocused, !textView.isFirstResponder {
            DispatchQueue.main.async {
                textView.becomeFirstResponder()
            }
        } else if !isFocused, textView.isFirstResponder, !isFocusTransferring {
            textView.resignFirstResponder()
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UITextView, context _: Context) -> CGSize? {
        let width = proposal.width ?? uiView.bounds.width
        guard width > 0 else { return nil }
        let lineHeight = (uiView.font ?? defaultFont).lineHeight
        let height = uiView.attributedText.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        ).height
        return CGSize(width: width, height: ceil(max(height, lineHeight)))
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: ArticleTextView

        init(_ parent: ArticleTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.onTextChange(textView.attributedText)
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.onSelectionChange(textView.selectedRange, textView.typingAttributes)
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            parent.onFocus(textView)
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            parent.onBlur(textView)
        }

        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText text: String
        ) -> Bool {
            if text == "\n" {
                parent.onReturn()
                return false
            }
            if text.isEmpty, range.length == 0, range.location == 0, textView.text.isEmpty {
                parent.onDeleteWhenEmpty()
                return false
            }
            return true
        }
    }
}
#endif
