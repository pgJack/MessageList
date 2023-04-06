//
//  BubbleModel.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import UIKit
import RongIMLib

class BubbleModel: Codable {
    
    /// 当前气泡对应的 Message，聚合气泡为第一个 Message
    var message: Message { messages.first! }
    
    /// 聚合气泡包含多个 Message
    var messages: [Message]

    /// 气泡内容尺寸，不包含发送人名称、消息点赞、扩展消息视图
    var bubbleContentSize: CGSize = .zero
    
    /// 当前用户id
    var currentUserId: String
    
    /// 顶部视图
    var dateText: String?
    var shownUnreadLine = false
    
    /// 气泡视图
    var isBubbleHighlighted = false

    /// 已读回执视图
    var shownReadReceipt = false
    
    /// 扩展气泡视图
    var shownExBubble = false
    
    //MARK: Override Method
    required init?(rcMessages: [RCMessage], currentUserId: String) {
        guard rcMessages.count > 0 else { return nil }
        self.currentUserId = currentUserId
        messages = rcMessages.compactMap(Message.init)
    }
    
}

//MARK: Computed Properties
extension BubbleModel {
    
    /// 是否为聚合气泡
    var isCombined: Bool { messages.count > 1 }
    /// 是否包含某个 Message
    func isContain(_ message: Message) -> Bool {
        messages.contains {
            message.messageId == $0.messageId
        }
    }
    
    var bubbleSize: CGSize {
        CGSize(width: bubbleContentSize.width, height: bubbleHeight)
    }
    
    var bubbleHeight: CGFloat {
        var height: CGFloat = bubbleContentSize.height
        /// 姓名框高度
        if shownSenderName {
            height += .bubble.nameHeight
        }
        /// 点赞面板高度，聚合消息不显示点赞
        if messages.count == 1, shownThumbUp {
            height += .bubble.reactionTop + .bubble.reactionHeight
        }
        /// 扩展气泡高度，翻译内容高度+上下边距
        height += exBubbleSize.height
        /// 内容边距
        height += UIEdgeInsets.bubble.contentEdge.top + UIEdgeInsets.bubble.contentEdge.bottom
        return height
    }
    
    var translateViewSize: CGSize {
        .zero
    }
    
    var exBubbleSize: CGSize {
        let contentSize = translateViewSize
        guard !contentSize.equalTo(.zero) else {
            return .zero
        }
        let exBubbleEdge = UIEdgeInsets.bubble.exBubbleEdge
        return CGSize(width: exBubbleEdge.left + contentSize.width + exBubbleEdge.right,
                      height: exBubbleEdge.top + contentSize.height + exBubbleEdge.bottom)
    }
    
    var shownSenderAvatar: Bool {
        message.conversationType == .group
        && message.messageDirection == .receive
    }
    
    var shownSenderName: Bool {
        message.conversationType == .group
        && message.messageDirection == .receive
        && !message.isFromWhatsApp
    }
    
    /// 消息点赞视图
    var shownThumbUp: Bool {
        guard let thumbUps = message.thumbUps else {
            return false
        }
        return thumbUps.count > 0
    }

    /// 气泡视图
    var shownBubbleImage: Bool { false }
    var bubbleImageName: String? { nil }
    var timeText: String? { nil }
    var shownForwardTip: Bool {
        message.forwardType == .others
    }
    var shownWhatsAppTip: Bool {
        message.isFromWhatsApp
    }
    
}
