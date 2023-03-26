//
//  TextBubbleModel.swift
//  String
//
//  Created by Noah on 2023/3/24.
//

import UIKit
import RongIMLib

class TextBubbleModel: BubbleModel {
    
    static let limitCount = 1000

    static let textEdge = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14)
    static let textMaxWidth = CGFloat.bubble.maxWidth - textEdge.left - textEdge.right
        
    var isLimited = false
    var messageText: String?
    lazy var attributedText = textUtil?.attributedString(limitCount: TextBubbleModel.limitCount, isLimited: &isLimited)
    
    lazy var textUtil: BubbleAttributedTextUtil? = { () -> BubbleAttributedTextUtil? in
        guard let messageText = messageText else { return nil }
        let mentionInfo = message.contentExtra?.mentionInfo
        return BubbleAttributedTextUtil(currentUserId: currentUserId, roughText: messageText, maxWidth: TextBubbleModel.textMaxWidth, isBigEmoji: true, mentionedInfo: mentionInfo)
    }()
    
    override var cellType: String {
        message.messageDirection == .send
        ? MessageCellRegister.sender
        : MessageCellRegister.receiver
    }
    
    override var bubbleViewType: BubbleView.Type {
        TextBubbleView.self
    }
    
    override func loadMessages(_ rcMessages: [RCMessage], currentUserId: String) {
        super.loadMessages(rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let textContent = rcMessage.content as? RCTextMessage else {
            return
        }
        messageText = textContent.content
        let maxSize = CGSize(width: TextBubbleModel.textMaxWidth, height: .greatestFiniteMagnitude)
        guard let textRect = attributedText?.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil) else {
            return
        }
        let width = bubbleContentSize.width + textRect.size.width + TextBubbleModel.textEdge.left + TextBubbleModel.textEdge.right
        let height = bubbleContentSize.height + textRect.size.height + TextBubbleModel.textEdge.top + TextBubbleModel.textEdge.bottom
        bubbleContentSize = CGSize(width: ceil(width), height: ceil(height))
    }
    
}
