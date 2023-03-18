//
//  BubbleModel.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import UIKit

class BubbleModel: Codable {
    
    var cellType = MessageCellRegister.placeholder

    /// 当前气泡对应的 Message，聚合气泡为第一个 Message
    var message: Message! { messages.first }
    
    /// 聚合气泡包含多个 Message
    var messages: [Message]
    /// 是否为聚合气泡
    var isCombined: Bool { messages.count > 1 }
    /// 是否包含某个 Message
    func isContain(_ message: Message) -> Bool {
        messages.contains {
            message.messageId == $0.messageId
        }
    }

    /// 气泡尺寸
    var bubbleSize: CGSize
    
    /// 顶部视图
    var dateText: String?
    var shownUnreadLine = false
    
    /// 发送人视图
    var shownSenderName = false
    var shownSenderAvatar = false
    var senderName: String?
    var senderAvatar: String?
    
    /// 气泡视图
    var shownForwardTip = false
    var shownWhatsAppTip = false
    var shownBubbleImage = false
    var bubbleImageName: String?
    var timeText: String?
    var isHighlightedBubble = false

    /// 已读回执视图
    var shownReadReceipt = false
    
    /// 消息点赞视图
    var shownThumbUp = false
    
    /// 扩展气泡视图
    var shownExBubble = false
    
}
