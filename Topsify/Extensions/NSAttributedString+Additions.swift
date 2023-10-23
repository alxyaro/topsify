// Created by Alex Yaro on 2023-10-14.

import UIKit

extension NSAttributedString {

    convenience init?(
        text: String?,
        font: UIFont,
        kerning: CGFloat = 0,
        lineHeight: CGFloat = 0,
        lineBreakMode: NSLineBreakMode = .byTruncatingTail
    ) {
        guard let text else { return nil }
        let attrStr = NSMutableAttributedString(string: text)
        attrStr.font(font)
        if kerning != 0 {
            attrStr.kern(kerning)
        }
        attrStr.lineBreakMode(lineBreakMode)
        if lineHeight > 0 {
            attrStr.lineHeight(lineHeight)
        }
        self.init(attributedString: attrStr)
    }
}

extension NSMutableAttributedString {

    var fullRange: NSRange {
        NSRange(location: 0, length: length)
    }

    @discardableResult
    func font(_ font: UIFont) -> Self {
        addAttribute(.font, value: font, range: fullRange)
        return self
    }

    @discardableResult
    func kern(_ kerning: CGFloat) -> Self {
        addAttribute(.kern, value: NSNumber(value: kerning), range: fullRange)
        return self
    }

    @discardableResult
    func mutateParagraphStyle(_ updates: (NSMutableParagraphStyle) -> Void) -> Self {
        let paragraphStyle = NSMutableParagraphStyle()
        if let existingParagraphStyle = attribute(.paragraphStyle, at: 0, longestEffectiveRange: nil, in: fullRange) as? NSParagraphStyle {
            paragraphStyle.setParagraphStyle(existingParagraphStyle)
        }
        updates(paragraphStyle)
        removeAttribute(.paragraphStyle, range: fullRange)
        addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        return self
    }

    @discardableResult
    func lineBreakMode(_ mode: NSLineBreakMode) -> Self {
        mutateParagraphStyle { paragraphStyle in
            paragraphStyle.lineBreakMode = mode
        }
    }

    @discardableResult
    func lineHeight(_ lineHeight: CGFloat) -> Self {
        mutateParagraphStyle { paragraphStyle in
            paragraphStyle.minimumLineHeight = lineHeight
            paragraphStyle.maximumLineHeight = lineHeight
        }
    }
}
