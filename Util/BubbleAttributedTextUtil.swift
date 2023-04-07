//
//  BubbleAttributedTextUtil.swift
//  BMIMModule
//
//  Created by Noah on 2023/2/20.
//

import UIKit
import BMMagazine

private let kMentionedSymbol = "@"
private let kAllMentionedSymbol = kMentionedSymbol + "All"

private let kEmailScheme = "mailto"
private let kTelephonePrefix = "tel://"

private let kNormalTextColor: UIColor = .bmTheme.messageBubbleTextColor
private let kHighlightedTextColor: UIColor = .bmTheme.highlightedTextAttributes

private let kMentionedImageEdgeLeft: CGFloat = 12
private let kMentionedImageHight: CGFloat = 30

struct BubbleAttributedTextUtil {
    
    let currentUserId: String
    let roughText: String
    let maxWidth: CGFloat
    let textFont: UIFont
    let emojiConverter: Emojica
    let isBigEmoji: Bool
    let mentionedInfo: [String: String]?
    
    init(currentUserId: String, roughText: String, maxWidth: CGFloat, isBigEmoji: Bool, mentionedInfo: [String : String]?) {
        self.currentUserId = currentUserId
        self.roughText = roughText
        self.maxWidth = maxWidth
        self.isBigEmoji = isBigEmoji
        self.mentionedInfo = mentionedInfo
        textFont = .bubble.font(text: roughText, isBigEmoji: isBigEmoji)
        emojiConverter = Emojica(font: textFont)
    }
    
}

//MARK: Public Method
extension BubbleAttributedTextUtil {
    
    func attributedString(limitCount: Int = 1000, isLimited: UnsafeMutablePointer<Bool>?) -> NSAttributedString? {
        guard roughText.count > 0 else {
            return nil
        }
        let normalAttributes:[NSAttributedString.Key: Any] = [.foregroundColor: kNormalTextColor, .font: textFont]
        let attributedText = NSMutableAttributedString(string: roughText, attributes: normalAttributes)
        guard let mentionedInfo = mentionedInfo,
              textFont == UIFont.bubble.normal else {
            return _convertEmojiAndLimit(attributedText: attributedText, limitCount: limitCount, isLimited: isLimited)
        }
        let highlightAttributes:[NSAttributedString.Key: Any] = [.foregroundColor: kHighlightedTextColor, .font: textFont]
        BubbleAttributedTextUtil.enumerate(mentionedInfo: mentionedInfo, currentUserId: currentUserId) { userId, realName, isCurrentUser in
            
            let mentionedUserId = kMentionedSymbol + userId
            
            BubbleAttributedTextUtil.enumerate(attributedText.string, matches: mentionedUserId) { mentionedRange in
                let startIndex = mentionedRange.location
                attributedText.replaceCharacters(in: mentionedRange, with: "")
                
                let mentionedRealName = kMentionedSymbol + realName
                
                var mentionedAttributedText = NSMutableAttributedString(string: mentionedRealName, attributes: highlightAttributes)
                if isCurrentUser,
                   let image = BubbleAttributedTextUtil.userMentionedImage(named: mentionedRealName, maxWidth: maxWidth) {
                    let imageWidth = image.size.width
                    let imageHeight = image.size.height
                    let offsetY = (textFont.capHeight - imageHeight).rounded() / 2
                    let attachment = NSTextAttachment()
                    attachment.image = image
                    attachment.bounds = CGRectMake(0, offsetY, imageWidth, imageHeight)
                    mentionedAttributedText = NSMutableAttributedString(attachment: attachment)
                    if startIndex != 0 {
                        let placeholderAttributedText = NSAttributedString(string: " ")
                        mentionedAttributedText.insert(placeholderAttributedText, at: 0)
                    }
                }
                attributedText.insert(mentionedAttributedText, at: startIndex)
            }
        }
        return _convertEmojiAndLimit(attributedText: attributedText, limitCount: limitCount, isLimited: isLimited)
    }
    
    private func _convertEmojiAndLimit(attributedText: NSAttributedString, limitCount: Int, isLimited: UnsafeMutablePointer<Bool>?) -> NSAttributedString? {
        let finalAttributedText = emojiConverter.convert(attributedString: attributedText)
        if finalAttributedText.length > limitCount {
            isLimited?.pointee = true
            return finalAttributedText.attributedSubstring(from: NSRange(location: 0, length: limitCount))
        } else {
            isLimited?.pointee = false
            return finalAttributedText
        }
    }
    
    static func linkAndPhoneNumberAttributedString(_ attributedText: NSAttributedString?, isExcludeMail: Bool) -> NSAttributedString? {
        guard let attributedText = attributedText else {
            return nil
        }
        let resultAttributedText = NSMutableAttributedString(attributedString: attributedText)
        do {
            let types: NSTextCheckingResult.CheckingType = [.phoneNumber, .link]
            let dataDetector = try NSDataDetector(types: types.rawValue)
            let text = attributedText.string
            let nsText = text as NSString
            let range = NSRange(location: 0, length: nsText.length)
            dataDetector.enumerateMatches(in: text, range: range) { result, _, _ in
                guard let result = result,
                      result.range.location != NSNotFound else {
                    return
                }
                let matchedRange = result.range
                switch result.resultType {
                case .phoneNumber:
                    guard let phoneNumber = result.phoneNumber,
                          let phoneUrl = URL(string: phoneNumber) else {
                        return
                    }
                    resultAttributedText.addAttributes([.link: phoneUrl], range: matchedRange)
                case .link:
                    guard let linkUrl = result.url else {
                        return
                    }
                    if isExcludeMail, linkUrl.scheme == kEmailScheme {
                        return
                    }
                    resultAttributedText.addAttributes([.link: linkUrl], range: matchedRange)
                default:
                    break
                }
            }
        } catch {
            print("[Message Bubble] link attributed: \(attributedText.string) error: \(error)")
        }
        return resultAttributedText
    }
    
    static func highlightMentionedAll(_ attributedText: NSAttributedString?) -> NSAttributedString? {
        highlight(kAllMentionedSymbol, in: attributedText)
    }
    
    static func highlight(_ text: String, in attributedText: NSAttributedString?) -> NSAttributedString? {
        let highlightAttributes = [NSAttributedString.Key.foregroundColor: kHighlightedTextColor]
        return attributedString(byAdding: highlightAttributes, for: text, in: attributedText)
    }
    
    static func normal(_ text: String, in attributedText: NSAttributedString?) -> NSAttributedString? {
        let highlightAttributes = [NSAttributedString.Key.foregroundColor: kNormalTextColor]
        return attributedString(byAdding: highlightAttributes, for: text, in: attributedText)
    }
    
    static func boundingRect(_ attributedText: NSAttributedString?, maxSize: CGSize) -> CGRect? {
        return attributedText?.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil)
    }
    
}

//MARK: Mention Method
extension BubbleAttributedTextUtil {
    
    private static func enumerate(mentionedInfo: [String: String], currentUserId: String, _ handler: (String, String, Bool)->()) {
        mentionedInfo.forEach { element in
            let userId = element.key
            let userName = element.value
            let isCurrentUser = userId == currentUserId
            handler(userId, userName, isCurrentUser)
        }
    }
    
    private static func userMentionedImage(named nameText: String, maxWidth: CGFloat) -> UIImage? {
        let attributedText = NSAttributedString(string: "\(nameText)", attributes: [.foregroundColor: UIColor.white, .font: UIFont.bubble.normal])
        let textSize = attributedText.size()
        let imageWidth = min(textSize.width + kMentionedImageEdgeLeft * 2, maxWidth)
        let imageSize = CGSize(width: ceil(imageWidth), height: kMentionedImageHight)
        let textWidth = imageWidth - kMentionedImageEdgeLeft * 2
        let textRect = CGRect(x: kMentionedImageEdgeLeft, y: floor((imageSize.height - textSize.height) / 2), width: textWidth, height: textSize.height)
        return kHighlightedTextColor.toImage(size: imageSize, text: attributedText, textRect: textRect, isRoundingCorners: true)
    }
    
}

//MARK: Attribute Method
extension BubbleAttributedTextUtil {
    
    private static func attributedString(byAdding attributes: [NSAttributedString.Key: Any], for targetText: String?, in attributedText: NSAttributedString?) -> NSAttributedString? {
        guard let attributedText = attributedText,
              let targetText = targetText,
              targetText.count > 0 else {
            return attributedText
        }
        let resultAttributedText = NSMutableAttributedString(attributedString: attributedText)
        enumerate(resultAttributedText.string, matches: targetText) { range in
            resultAttributedText.addAttributes(attributes, range: range)
        }
        return resultAttributedText
    }
    
    private static func enumerate(_ text: String, matches targetText: String, handler: (NSRange) -> Void) {
        do {
            let expression = try NSRegularExpression(pattern: targetText)
            let nsText = text as NSString
            let range = NSRange(location: 0, length: nsText.length)
            expression.enumerateMatches(in: text, range: range) { result, _, _ in
                guard let result = result, result.range.location != NSNotFound else {
                    return
                }
                handler(result.range)
            }
        } catch {
            print("[Message Bubble] enumerate text: \(text) matches: \(targetText) error: \(error)")
        }
    }
    
}
