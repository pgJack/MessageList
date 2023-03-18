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
    let messageDirection: MessageDirection
    
    let forwardType: MessageForwardType
    let isFromWhatsApp: Bool

    /// 撤回后，消息类型会改变
    var messageType: MessageType

    /// 发从成功前，没有 messageUId
    var messageUId: String?
    var sentTime: Int64
    var isSent: Bool { messageUId != nil }
    var sentStatus: MessageSentStatus
    var deliveredProgress: CGFloat
    var readProgress: CGFloat
    
    var translateStatus: MessageTranslateStatus
    var translatedText: String?
    
    var thumbUpInfo: [String : Int]
    var thumbUpDetailInfo: [String : [String : TimeInterval]]
    
}
