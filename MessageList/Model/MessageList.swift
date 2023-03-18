//
//  MessageList.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import Foundation

struct Conversation: ConversationProtocol, Codable {
    var targetId: String
    var channelId: String
    var conversationType: ConversationType
    var secretKey: String?
    
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
    var anchorMessageId: Int
    var isFirstUnreadMessage: Bool
    var highlightedText: String?
    var isHighlightedBackground: Bool
    
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
    
    var currentUserId: String
    var conversation: ConversationProtocol
    var listType: MessageListType
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
