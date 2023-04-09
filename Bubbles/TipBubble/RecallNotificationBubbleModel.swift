//
//  RecallNotificationBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore

class RecallNotificationBubbleModel: TipBubbleModel, BubbleInfoProtocol {
    
    var cellType: String {
        MessageCellRegister.tip
    }

    var bubbleViewType: BubbleView.Type {
        BubbleView.self
    }
    
    var canTapAvatar = false
    lazy var canLongPressAvatarMention = message.conversationType == .group
    lazy var canPanReference = message.conversationType != .person_encrypted
    
    var canReedit: Bool = false
    var originalObjectName: String?
    var recallContent: String?
    var recallActionTime: Int64 = 0
    
    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let recallMsg = rcMessage.content as? RCRecallNotificationMessage else {
            return
        }
        
        originalObjectName = recallMsg.originalObjectName
        recallContent = recallMsg.recallContent
        recallActionTime = recallMsg.recallActionTime
        
        
        let cTime = Int64(Date().timeIntervalSince1970 * 1000)
        let interval = cTime - recallActionTime
        let reeditDuration = MessageListGlobalConfig.shared.reeditDuration * 1000;
        if reeditDuration > 0 && interval > 0 && interval <= reeditDuration && message.messageDirection == .send {
            canReedit = true
        }
        
        let attributedText = splicingAttributedText()
        
        let maxSize = CGSize(width: CGFloat.bubble.maxWidth, height: .greatestFiniteMagnitude)
        if let rect = BubbleAttributedTextUtil.boundingRect(attributedText, maxSize: maxSize) {
            bubbleContentSize = CGSize(width: ceil(CGFloat.bubble.maxWidth), height: ceil(rect.size.height))
        }
        
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    private func splicingAttributedText() -> NSAttributedString {
        // TODO: - 拼接富文本
        let attributedText = NSAttributedString(string: recallContent ?? "")
        return attributedText
    }
}
