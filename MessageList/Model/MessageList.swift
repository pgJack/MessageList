//
//  MessageList.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import Foundation
import BMProtocols

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
    let highlightedText: String?
    let isHighlightedBackground: Bool
    
    init(anchorMessageId: Int, highlightedText: String?, isHighlightedBackground: Bool) {
        self.anchorMessageId = anchorMessageId
        self.highlightedText = highlightedText
        self.isHighlightedBackground = isHighlightedBackground
    }
    
    init?(_ anchorMessage: AnchorMessageProtocol?) {
        guard let anchorMessage = anchorMessage else { return nil }
        anchorMessageId = anchorMessage.anchorMessageId
        highlightedText = anchorMessage.highlightedText
        isHighlightedBackground = anchorMessage.isHighlightedBackground
    }
}

struct MessageList: MessageListProtocol, Codable {
    
    private enum CodingKeys: CodingKey {
        case currentUserInfo
        case conversation
        case listType
    }
    
    let currentUserInfo: UserInfoProtocol
    let conversation: ConversationProtocol
    let listType: MessageListType
    
    init(currentUserInfo: UserInfoProtocol, conversation: ConversationProtocol, listType: MessageListType) {
        self.currentUserInfo = currentUserInfo
        self.conversation = conversation
        self.listType = listType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentUserInfo = try container.decode(UserInfo.self, forKey: .currentUserInfo)
        conversation = try container.decode(Conversation.self, forKey: .conversation)
        listType = try container.decode(MessageListType.self, forKey: .listType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let userInfo = UserInfo(currentUserInfo)
        try container.encode(userInfo, forKey: .currentUserInfo)
        try container.encode(listType, forKey: .listType)
        let conversation = Conversation(conversation)
        try container.encode(conversation, forKey: .conversation)
    }
        
}

struct UserInfo: UserInfoProtocol, Codable {
    var userId: String
    var userName: String
    var userAvatar: String?
    var userPlaceholderAvatar: String?
    
    init(userId: String, userName: String) {
        self.userId = userId
        self.userName = userName
        userAvatar = nil
        userPlaceholderAvatar = nil
    }
    
    init(_ userInfo: UserInfoProtocol) {
        userId = userInfo.userId
        userName = userInfo.userName
        userAvatar = userInfo.userAvatar
        userPlaceholderAvatar = userInfo.userPlaceholderAvatar
    }
}
