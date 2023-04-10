//
//  TextBubbleModel.swift
//  String
//
//  Created by Noah on 2023/3/24.
//

import UIKit
import RongIMLib

class TextBubbleModel: BubbleModel, BubbleInfoProtocol, BubbleImageProtocol {
             
    //MARK: Bind View
    /// 对应 Cell 类型
    var cellType: String {
        message.messageDirection == .send
        ? MessageCellRegister.sender
        : MessageCellRegister.receiver
    }
    var bubbleViewType: BubbleView.Type {
        BubbleView.self
    }
    
    //MARK: Action Control
    /// 是否允许响应点击头像
    var canTapAvatar = true
    /// 是否允许长摁头像 @ 用户
    lazy var canLongPressAvatarMention = message.conversationType == .group
    /// 是否允许右滑引用
    lazy var canPanReference = message.conversationType != .person_encrypted
    
    //MARK: Bubble Background Image
    var bubbleForegroundImageType: BubbleImageType {
        guard let textUtil = textUtil, textUtil.isFullEmoji else { return .none }
        switch message.messageDirection {
        case .send:
            return isBubbleHighlighted ? .square_opaque : .none
        default:
            return isBubbleHighlighted ? .square_opaque : .none
        }
    }
    var bubbleBackgroundImageType: BubbleImageType {
        guard let textUtil = textUtil, !textUtil.isFullEmoji else { return .none }
        switch message.messageDirection {
        case .send:
            return isBubbleHighlighted ? .purple_v2 : .purple_v1
        default:
            return isBubbleHighlighted ? .gray : .white
        }
    }
    
    //MARK: Text View
    override var isBigEmoji: Bool { true }
    
    //MARK: Time View
    override var timeAlignment: BubbleTimeAlignment {
        guard let textUtil = textUtil, textUtil.isFullEmoji, message.messageDirection == .receive else { return .training }
        return .leading
    }
    override var timeBackgroundStyle: BubbleTimeBackgroundStyle {
        guard let textUtil = textUtil, textUtil.isFullEmoji else { return .clear }
        return .opacity
    }
    
    //MARK: Init Method
    override func setupBubbleContent(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleContent(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first else { return }
        guard let textContent = rcMessage.content as? RCTextMessage else { return }
        guard let messageText = textContent.content as? String else { return }
        bubbleText = messageText
    }

}
