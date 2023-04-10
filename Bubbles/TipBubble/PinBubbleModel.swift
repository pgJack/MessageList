//
//  PinBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore
import BMIMLib

class PinBubbleModel: TipBubbleModel, BubbleInfoProtocol {
    
    var cellType: String {
        MessageCellRegister.tip
    }

    var bubbleViewType: BubbleView.Type {
        BubbleView.self
    }
    
    var canTapAvatar = false
    lazy var canLongPressAvatarMention = message.conversationType == .group
    lazy var canPanReference = message.conversationType != .person_encrypted
    
    var messageString: String?
    
    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let pinnedContent = rcMessage.content as? BMIMPInnedNotificationMessage else {
            return
        }
        
        // TODO: - 获取显示内容
//        __getPinnedMessageContent(objectName: _pinndeMessage.objectName, operatorID: _pinndeMessage.operatorUserId, operatorDefaultName: _pinndeMessage.operatorNickname)

        messageString = "\(pinnedContent.operatorNickname) + \(pinnedContent.operatorUserId) + \(pinnedContent.objectName)"
        
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

