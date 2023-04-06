//
//  TextBubbleModel.swift
//  String
//
//  Created by Noah on 2023/3/24.
//

import UIKit
import RongIMLib

class TextBubbleModel: BubbleModel, BubbleInfoProtocol {
    
    private enum CodingKeys: CodingKey {
        case messageText
        case isLimited
    }
        
    static let limitCount = 1000

    static let textEdge = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14)
    static let textMaxWidth = CGFloat.bubble.maxWidth - textEdge.left - textEdge.right
        
    var isLimited = false
    var messageText: String?
    lazy var attributedText = textUtil?.attributedString(limitCount: TextBubbleModel.limitCount, isLimited: &isLimited)
    
    lazy var textUtil: BubbleAttributedTextUtil? = {
        guard let messageText = messageText else { return nil }
        let mentionInfo = message.contentExtra?.mentionInfo
        return BubbleAttributedTextUtil(currentUserId: currentUserId, roughText: messageText, maxWidth: TextBubbleModel.textMaxWidth, isBigEmoji: true, mentionedInfo: mentionInfo)
    }()
    
    //MARK: Bind View
    /// 对应 Cell 类型
    var cellType: String {
        message.messageDirection == .send
        ? MessageCellRegister.sender
        : MessageCellRegister.receiver
    }
    var bubbleViewType: BubbleView.Type {
        TextBubbleView.self
    }
    
    //MARK: Action Control
    /// 是否允许响应点击头像
    var canTapAvatar = true
    /// 是否允许长摁头像 @ 用户
    lazy var canLongPressAvatarMention = message.conversationType == .group
    /// 是否允许右滑引用
    lazy var canPanReference = message.conversationType != .person_encrypted
    
    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let textContent = rcMessage.content as? RCTextMessage else {
            return
        }
        messageText = textContent.content
        let maxSize = CGSize(width: TextBubbleModel.textMaxWidth, height: .greatestFiniteMagnitude)
        guard let textRect = attributedText?.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil) else {
            return
        }
        let width = textRect.size.width + TextBubbleModel.textEdge.left + TextBubbleModel.textEdge.right
        let height = textRect.size.height + TextBubbleModel.textEdge.top + TextBubbleModel.textEdge.bottom
        bubbleContentSize = CGSize(width: ceil(width), height: ceil(height))
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        messageText = try container.decode(String.self, forKey: .messageText)
        isLimited = try container.decode(Bool.self, forKey: .isLimited)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(messageText, forKey: .messageText)
        try container.encode(isLimited, forKey: .isLimited)
    }
    
}
