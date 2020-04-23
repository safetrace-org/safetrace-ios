import UIKit

/// Use this class when you want to have a non-editable block of text, and add tappable links inside
/// This looks and feels like a UILabel, but borrows the URL link handling of UITextView
/// Do not use this if you actually want a UITextView for editing text
class TappableTextView: UITextView, UITextViewDelegate {

    /// This is called when you interact with a link attribute.
    /// - URL: The *URL* that the tapped link attribute contains
    var linkHandler: ((URL) -> Void)?

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)

        delegate = self
        isEditable = false
        isSelectable = true
        isScrollEnabled = false
        backgroundColor = .clear
        layoutManager.usesFontLeading = false
        textContainerInset = .zero
        linkTextAttributes = [:]
        self.textContainer.lineFragmentPadding = 0
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // Do not allow touch on parts of the UITextView that is not a link, to prevent selection behavior
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard
            let pos = closestPosition(to: point),
            let range = tokenizer.rangeEnclosingPosition(pos, with: .character, inDirection: .layout(.left))
        else {
            return false
        }
        let startIndex = offset(from: beginningOfDocument, to: range.start)
        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil
    }

    // MARK: - UITextViewDelegate

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        linkHandler?(URL)
        return false
    }
}
