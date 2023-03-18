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
    
    /// 消息翻译状态
    var translateStatus: MessageTranslateStatus { get }
    var translatedText: String? { get }
    
    /// 转发类型
    var forwardType: MessageForwardType { get }
    
    /// 是否为 WhatsApp 导入消息
    var isFromWhatsApp: Bool { get }
    
    /// 消息点赞
    var thumbUpInfo: [String: Int] { set get }
    var thumbUpDetailInfo: [String: [String: TimeInterval]] { set get }
}
