//
//  MessageProtocol.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import Foundation

@objc public enum MessageType: Int, Codable {
    case tip, text, voice, image, sight, gif, sticker, file, onlineFile, reference, recall, unknown
}

@objc public enum MessageDirection: Int, Codable {
    case send, receive
}

@objc public enum MessageTranslateStatus: Int, Codable {
    case none, loading, success, failure
}

/// 转发类型： none 不是转发消息，mine 转发自己的消息，others 转发别人的消息
@objc public enum MessageForwardType: Int, Codable {
    case none, mine, others
}

@objc public enum MessageSentStatus: Int, Codable {
    case none, sending, fail, groupSent, privateSent, delivered, readProgress, read
}

public protocol MessageProtocol: ConversationProtocol {
    var messageId: Int { get }
    var messageUId: String? { get }
    var messageType: MessageType { get }
    var messageDirection: MessageDirection { get }
    
    /// 发送状态
    var sentTime: Int64 { get }
    var sentStatus: MessageSentStatus { get }
    var deliveredProgress: CGFloat { get }
    var readProgress: CGFloat { get }
    
    ///  发送人信息
    var senderId: String? { get }
    var senderName: String? { get }
    var senderAvatar: String? { get }
    var senderPlaceholderAvatar: String? { get }
        
    /// 转发类型
    var forwardType: MessageForwardType { get }
    
    /// 是否为 WhatsApp 导入消息
    var isFromWhatsApp: Bool { get }
    
    // 对应本地数据库中附加信息，不会多端同步
    var messageExtra: MessageExtraInfo? { get }
    // 对应消息流转中附加信息，发送时多端同步
    var contentExtra: MessageContentExtraInfo? { get }
    // 对应消息扩展附加信息，通过 SDK 设置后实时同步
    var expansionDict: [String: String]? { get }
    
    // 点赞信息
    var thumbUps: [MessageExpansionThumbUpAction]? { get }
}
