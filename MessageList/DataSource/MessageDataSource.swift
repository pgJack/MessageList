//
//  MessageDataSource.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import Foundation
import RongIMLib

private let kQuantumCount: Int32 = 20

class MessageDataSource {
            
    private let sourceQueue = DispatchQueue.init(label: "com.message.list.source")
    
    private let rcConversation: RCConversationDescriptionProtocol
    private var rcManager: RCChannelClient { RCChannelClient.sharedChannelManager() }
    
    init?(rcConversation: RCConversationDescriptionProtocol?) {
        guard let rcConversation = rcConversation else { return nil }
        self.rcConversation = rcConversation
    }
    
}

//MARK: Query Method
extension MessageDataSource {
    
    func initMessages(_ anchorMessage: AnchorMessageProtocol?) -> [RCMessage]? {
        if let anchorMessage = anchorMessage {
            return messagesAround(sentTime: anchorMessage.anchorMessageSentTime)
        } else {
            return latestMessages()
        }
    }
    
}

private extension MessageDataSource {
        
    func latestMessages() -> [RCMessage]? {
        rcManager.getLatestMessages(rcConversation.conversationType, targetId: rcConversation.targetId, channelId: rcConversation.channelId, count: kQuantumCount)
    }
    
    func messagesAround(sentTime: Int64) -> [RCMessage]? {
        rcManager.getHistoryMessages(rcConversation.conversationType, targetId: rcConversation.targetId, channelId: rcConversation.channelId, sentTime: sentTime, beforeCount: kQuantumCount, afterCount: kQuantumCount)
    }
    
    func messagesOlderThan(messageId: Int) -> [RCMessage]? {
        rcManager.getHistoryMessages(rcConversation.conversationType, targetId: rcConversation.targetId, channelId: rcConversation.channelId, objectName: nil, oldestMessageId: messageId, count: kQuantumCount)
    }
    
    func messagesLaterThan(messageId: Int) -> [RCMessage]? {
        rcManager.getHistoryMessages(rcConversation.conversationType, targetId: rcConversation.targetId, channelId: rcConversation.channelId, objectName: nil, baseMessageId: messageId, isForward: false, count: kQuantumCount)
    }
    
}
