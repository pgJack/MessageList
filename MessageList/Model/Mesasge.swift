//
//  Mesasge.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import UIKit

struct Message: MessageProtocol, Codable {
    
    let targetId: String
    let channelId: String
    let conversationType: ConversationType
    let secretKey: String?
    
    let messageId: Int
    /// 发从成功前，没有 messageUId
    var messageUId: String?
    
    let messageDirection: MessageDirection
    
    let senderId: String?
    let senderName: String?
    let senderAvatar: String?
    let senderPlaceholderAvatar: String?
    
    let forwardType: MessageForwardType
    let isFromWhatsApp: Bool

    /// 撤回后，消息类型会改变
    var messageType: MessageType

    var isSent: Bool { messageUId != nil }
    var sentTime: Int64
    var sentStatus: MessageSentStatus
    var deliveredProgress: CGFloat
    var readProgress: CGFloat
    
    // 对应本地数据库中附加信息，不会多端同步
    var messageExtra: MessageExtraInfo?
    // 对应消息流转中附加信息，发送时多端同步
    var contentExtra: MessageContentExtraInfo?
    // 对应消息扩展附加信息，设置后实时同步
    var expansionDict: [String: String]?
    
    // 点赞信息
    var thumbUps: [MessageExpansionThumbUpAction]?
    
    /// @ 信息
    var isMentionedAll: Bool
    
}
