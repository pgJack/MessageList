//
//  RCGenerator.swift
//  String
//
//  Created by Noah on 2023/3/18.
//

import Foundation
import RongIMLib
import BMIMLib

private let kEncryptIdSeparator = ";;;"

private let kWhatsAppMessageObjectNamePrefix = "UMB:WhatsApp"
private let kExtraActionForward = "forward"

//MARK: 消息模型
extension Message {
    
    init?(_ rcMessage: RCMessage) {
        guard let conversation = Conversation(rcMessage),
              let objectName = rcMessage.objectName else {
            return nil
        }
        targetId = conversation.targetId
        channelId = conversation.channelId
        conversationType = conversation.conversationType
        secretKey = conversation.secretKey
        
        messageId = rcMessage.messageId
        messageUId = rcMessage.messageUId
        
        switch rcMessage.messageDirection {
        case .MessageDirection_RECEIVE:
            messageDirection = .receive
        default:
            messageDirection = .send
        }
        
        sentTime = rcMessage.sentTime
        senderId = rcMessage.senderUserId
        senderName = rcMessage.content?.senderUserInfo?.name
        senderAvatar = rcMessage.content?.senderUserInfo?.portraitUri
        senderPlaceholderAvatar = nil
        
        isFromWhatsApp = objectName.hasPrefix(kWhatsAppMessageObjectNamePrefix)
        switch rcMessage.content {
        case let whatsAppContent as UMBWhatsAppTextMessage:
            whatsAppSentTime = whatsAppContent.originalTime
            whatsAppSender = whatsAppContent.originalSender
        case let whatsAppContent as UMBWhatsAppFileMessage:
            whatsAppSentTime = whatsAppContent.originalTime
            whatsAppSender = whatsAppContent.originalSender
        case let whatsAppContent as UMBWhatsAppSightMessage:
            whatsAppSentTime = whatsAppContent.originalTime
            whatsAppSender = whatsAppContent.originalSender
        case let whatsAppContent as UMBWhatsAppImageMessage:
            whatsAppSentTime = whatsAppContent.originalTime
            whatsAppSender = whatsAppContent.originalSender
        default:
            whatsAppSentTime = nil
            whatsAppSender = nil
        }
        
        contentExtra = MessageContentExtraInfo.info(rcMessage.content?.extra)
        if contentExtra?.action == kExtraActionForward {
            switch contentExtra?.forward {
            case true:
                forwardType = .others
            case false:
                forwardType = .mine
            default:
                forwardType = .none
            }
        } else {
            forwardType = .none
        }
        
        messageExtra = MessageExtraInfo.info(rcMessage.extra)
        expansionDict = rcMessage.expansionDic
        thumbUps = rcMessage.expansionDic?.compactMap { element in
            let key = element.key
            let value = element.value
            guard var thumbUpInfo = MessageExpansionThumbUpAction.info(value) else {
                return nil
            }
            thumbUpInfo.userId = key
            return thumbUpInfo
        }
        
        messageType = rcMessage.content?.messageType ?? .unknown
        
        deliveredProgress = 1
        readProgress = 1
        sentStatus = MessageSentStatus.init(conversationType: conversationType, targetId: targetId, rcSentStatus: rcMessage.sentStatus, messageDirection: rcMessage.messageDirection, senderUserId: senderId, deliverProgress: deliveredProgress, readProgress: readProgress)
        
        isMentionedAll = rcMessage.content?.mentionedInfo?.type == .mentioned_All
    }
    
}

extension RCMessageContent {
    var messageType: MessageType {
        switch Self.self {
        case is RCTextMessage.Type:
            return .text
        default:
            return .unknown
        }
    }
}

//MARK: 消息发送状态
extension MessageSentStatus {
    
    init(conversationType: ConversationType, targetId: String, rcSentStatus: RCSentStatus, messageDirection: RCMessageDirection, senderUserId: String?, deliverProgress: CGFloat, readProgress: CGFloat) {
        // 以下情况不显示发送状态
        // 1.会话类型不支持已读回执
        // 2.设置为单聊不收发已读回执
        // 3.与自己的会话
        // 4.接收的他人消息
        let validType = [ConversationType.person, .person_encrypted, .group]
        guard messageDirection == .MessageDirection_SEND,
              validType.contains(conversationType),
              let senderUserId = senderUserId,
              targetId != senderUserId else {
            self = .none
            return
        }
        switch rcSentStatus {
        case .SentStatus_SENDING:
            self = .sending
        case .SentStatus_RECEIVED:
            self = .delivered
        case .SentStatus_READ:
            self = .read
        case .SentStatus_FAILED, .SentStatus_CANCELED:
            self = .fail
        case .SentStatus_SENT:
            guard conversationType == .group else {
                self = .privateSent
                break
            }
            guard deliverProgress > 0 || readProgress > 0 else {
                self = .groupSent
                break
            }
            if readProgress == 1 {
                self = .read
            } else {
                self = .readProgress
            }
        default:
            self = .none
            break
        }
    }
    
}

//MARK: 会话模型
extension Conversation {
    
    init?(_ rcConversation: RCConversationDescriptionProtocol) {
        guard let channelId = rcConversation.channelId else {
            return nil
        }
        var targetId: String? = rcConversation.targetId
        var conversationType: ConversationType = .unknown
        var secretKey: String? = nil
        switch rcConversation.conversationType {
        case .ConversationType_PRIVATE:
            let isRobot = rcConversation.targetId == "BeemGlobalRobot"
            if isRobot {
                conversationType = .robot
            } else {
                conversationType = .person
            }
        case .ConversationType_GROUP:
            conversationType = .group
        case .ConversationType_Encrypted:
            conversationType = .person_encrypted
            let targeInfo = targetId?.components(separatedBy: kEncryptIdSeparator)
            targetId = targeInfo?.last
            secretKey = targeInfo?.first
        default:
            break
        }
        guard let targetId = targetId, conversationType != .unknown else {
            return nil
        }
        self.targetId = targetId
        self.channelId = channelId
        self.conversationType = conversationType
        self.secretKey = secretKey
    }
    
}

extension ConversationProtocol {
    
    var rcConversation: RCConversationDescriptionProtocol? {
        let rcConversation =  RCConversation()
        rcConversation.targetId = targetId
        rcConversation.channelId = channelId
        switch conversationType {
        case .group:
            rcConversation.conversationType = .ConversationType_GROUP
        case .person:
            rcConversation.conversationType = .ConversationType_PRIVATE
        case .person_encrypted:
            guard let secretKey = secretKey else { return nil }
            rcConversation.conversationType = .ConversationType_Encrypted
            rcConversation.targetId = [secretKey, targetId].joined(separator: kEncryptIdSeparator)
        default:
            return nil
        }
        return rcConversation
    }
    
}

public protocol RCConversationDescriptionProtocol {
    var channelId: String? { get set }
    var targetId: String { get set }
    var conversationType: RCConversationType { get set }
    
    var chatId: String { get }
}
public extension RCConversationDescriptionProtocol {
    var chatId: String {
        "\(targetId)_\(channelId ?? "")_\(conversationType)"
    }
}

extension RCConversation: RCConversationDescriptionProtocol {}
extension RCMessage: RCConversationDescriptionProtocol {}
