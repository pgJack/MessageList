//
//  GroupNotificationBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore

class GroupNotificationBubbleModel: BubbleModel, BubbleInfoProtocol {
    
    var cellType: String {
        MessageCellRegister.tip
    }

    var bubbleViewType: BubbleView.Type {
        BubbleView.self
    }
    
    var canTapAvatar = false
    lazy var canLongPressAvatarMention = message.conversationType == .group
    lazy var canPanReference = message.conversationType != .person_encrypted
    
    var operation: String?
    var operatorUserId: String?
    var dataDict: [String: Any]?
    var messageString: String?
    
    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let groupNotiMsg = rcMessage.content as? RCGroupNotificationMessage else {
            return
        }
        
        operation = groupNotiMsg.operation
        operatorUserId = groupNotiMsg.operatorUserId
        if let jsonData:Data = groupNotiMsg.data.data(using: .utf8) {
            dataDict = (try? JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)) as? [String: Any]
        }
        messageString = groupNotiMsg.message
        
        let attributedText: NSAttributedString = splicingAttributedText()
        
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
        let attributedText = NSAttributedString(string: messageString ?? "")
        return attributedText
    }
}
