//
//  MessageListProtocol.swift
//  String
//
//  Created by Noah on 2023/3/16.
//

import UIKit

@objc public enum ConversationType: Int, Codable {
    case unknown, person, person_encrypted, group, robot
}

@objc public enum MessageListType: Int, Codable {
    case chat, pin, star, search
}

public protocol ConversationProtocol {
    var targetId: String { get }
    var channelId: String { get }
    var conversationType: ConversationType { get }
    
    /// type == person_encrypted 时，secretKey 有值
    var secretKey: String? { get }
}

public protocol AnchorMessageProtocol {
    var anchorMessageId: Int { get }
    var anchorMessageSentTime: Int64 { get }
    var highlightedText: String? { get }
    var isHighlightedBackground: Bool { get }
}

public protocol MessageListProtocol {
    var currentUserInfo: UserInfoProtocol { get }
    var conversation: ConversationProtocol { get }
    var listType: MessageListType { get }
}

public protocol MessageListControllerProtocol: NSObjectProtocol {
    var controller: UIViewController { get }
    var collectionView: UICollectionView { get }
    var messageList: MessageListProtocol { get }
    init?(currentUserInfo: UserInfoProtocol, rcConversation: RCConversationDescriptionProtocol, listType: MessageListType, anchorMessage: AnchorMessageProtocol?)
}

public protocol UserInfoProtocol {
    var userId: String { get }
    var userName: String { get }
    var userAvatar: String? { get }
    var userPlaceholderAvatar: String? { get }
}
