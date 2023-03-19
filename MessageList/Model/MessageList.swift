//
//  MessageList.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import Foundation

struct Conversation: ConversationProtocol, Codable {
    let targetId: String
    let channelId: String
    let conversationType: ConversationType
    let secretKey: String?
    
    init(targetId: String, channelId: String, conversationType: ConversationType, secretKey: String?) {
        self.targetId = targetId
        self.channelId = channelId
        self.conversationType = conversationType
        self.secretKey = secretKey
    }
    
    init(_ conversation: ConversationProtocol) {
        targetId = conversation.targetId
        channelId = conversation.channelId
        conversationType = conversation.conversationType
        secretKey = conversation.secretKey
    }
}

struct AnchorMessage: AnchorMessageProtocol, Codable {
    let anchorMessageId: Int
    let isFirstUnreadMessage: Bool
    let highlightedText: String?
    let isHighlightedBackground: Bool
    
    init(anchorMessageId: Int, isFirstUnreadMessage: Bool, highlightedText: String?, isHighlightedBackground: Bool) {
        self.anchorMessageId = anchorMessageId
        self.isFirstUnreadMessage = isFirstUnreadMessage
        self.highlightedText = highlightedText
        self.isHighlightedBackground = isHighlightedBackground
    }
    
    init?(_ anchorMessage: AnchorMessageProtocol?) {
        guard let anchorMessage = anchorMessage else { return nil }
        anchorMessageId = anchorMessage.anchorMessageId
        isFirstUnreadMessage = anchorMessage.isFirstUnreadMessage
        highlightedText = anchorMessage.highlightedText
        isHighlightedBackground = anchorMessage.isHighlightedBackground
    }
}

struct MessageList: MessageListProtocol, Codable {
    
    private enum CodingKeys: CodingKey {
        case currentUserId
        case conversation
        case listType
        case anchorMessage
    }
    
    let currentUserId: String
    let conversation: ConversationProtocol
    let listType: MessageListType
    
    // 滚动定位到某条消息，滚动完毕后置空
    var anchorMessage: AnchorMessageProtocol?
    
    init(currentUserId: String, conversation: ConversationProtocol, listType: MessageListType, anchorMessage: AnchorMessageProtocol?) {
        self.currentUserId = currentUserId
        self.conversation = conversation
        self.listType = listType
        self.anchorMessage = anchorMessage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentUserId = try container.decode(String.self, forKey: .currentUserId)
        conversation = try container.decode(Conversation.self, forKey: .conversation)
        listType = try container.decode(MessageListType.self, forKey: .listType)
        anchorMessage = try? container.decode(AnchorMessage.self, forKey: .anchorMessage)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentUserId, forKey: .currentUserId)
        try container.encode(listType, forKey: .listType)
        let conversation = Conversation(conversation)
        try container.encode(conversation, forKey: .conversation)
        let anchorMessage = AnchorMessage(anchorMessage)
        try container.encode(anchorMessage, forKey: .anchorMessage)
    }
        
}
