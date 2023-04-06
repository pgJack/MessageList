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
    case chat, pin, star, search, detail
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
    
    // 是否当前会话为只读，不可发送消息
    var readonly: Bool { get set }
    init?(currentUserInfo: UserInfoProtocol, rcConversation: RCConversationDescriptionProtocol, listType: MessageListType, anchorMessage: AnchorMessageProtocol?)
}

public protocol UserInfoProtocol {
    var userId: String { get }
    var userName: String? { get }
    var userAvatar: String? { get }
    var userPlaceholderAvatar: String? { get }
}
