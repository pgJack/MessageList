//
//  MessageDataSource.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import Foundation
import RongIMLib

private let kQuantumCount: Int32 = 20

private let kBubbleModelClassTable: [String: BubbleModel.Type] = [
    RCTextMessage.getObjectName(): TextBubbleModel.self
]

class MessageDataSource {
    
    /// 气泡模型数据源
    var bubbleModels = [BubbleModel]()
    
    // 是否聚合
    var needCombine = false
    // 最小聚合单元
    var combineUnit = 4
    // 允许聚合的气泡类型
    var combineType = [BubbleModel.Type]()
    
    /// 消息列表 ViewModel
    private weak var _viewModel: MessageListViewModel?
    
    /// 消息数据源缓存
    private var _bubbleModelCache: BubbleModelCache?
                
    /// 会话属性
    private let _currentUserId: String
    private let _rcConversation: RCConversationDescriptionProtocol
    private var _rcManager: RCChannelClient { RCChannelClient.sharedChannelManager() }
    
    /// 数据源处理队列
    private let _sourceQueue = DispatchQueue.init(label: "com.message.list.source")
    
    init?(viewModel: MessageListViewModel, messageList: MessageListProtocol?) {
        guard let messageList = messageList,
              let rcConversation = messageList.conversation.rcConversation else {
            return nil
        }
        _viewModel = viewModel
        _rcConversation = rcConversation
        let currentUserId = messageList.currentUserInfo.userId
        _currentUserId = currentUserId
        _bubbleModelCache = BubbleModelCache.init(userId: currentUserId)
    }
    
}

//MARK: Anchor Method
extension MessageDataSource {
    
    func anchor(at anchorMessage: AnchorMessageProtocol) {
        guard let rcMessages = messagesAround(sentTime: anchorMessage.anchorMessageSentTime),
              !rcMessages.isEmpty else {
            return
        }
        bubbleModels = convert(rcMessages)
        _viewModel?.dataSourceDidReset()
    }
    
    func anchorAtFirstUnreadMessage() {
        var rcMessages: [RCMessage]? = nil
        var firstUnreadMessageId: Int? = nil
        var unreadCount: Int32 = 0
        if let firstUnreadMessage = _rcManager.getFirstUnreadMessage(_rcConversation.conversationType, targetId: _rcConversation.targetId, channelId: _rcConversation.channelId) {
            rcMessages = messagesAround(sentTime: firstUnreadMessage.sentTime)
            firstUnreadMessageId = firstUnreadMessage.messageId
            unreadCount = _rcManager.getUnreadCount(_rcConversation.conversationType, targetId: _rcConversation.targetId, channelId: _rcConversation.channelId)
        } else {
            rcMessages = latestMessages()
        }
        guard let rcMessages = rcMessages,
              !rcMessages.isEmpty else {
            return
        }
        bubbleModels = convert(rcMessages, firstUnreadMessageId: firstUnreadMessageId)
        _viewModel?.dataSourceDidReset(unreadCount: unreadCount)
    }
    
}

//MARK: RCMessage -> Bubble
private extension MessageDataSource {
    
    func convert(_ messages:[RCMessage], firstUnreadMessageId: Int? = nil, lastBubble: BubbleModel? = nil) -> [BubbleModel] {
        var lastBubble = lastBubble
        let bubbles = messages.compactMap { message -> BubbleModel? in
            guard let objectName = message.objectName,
                  let bubbleClass = kBubbleModelClassTable[objectName] else {
                return nil
            }
            guard let bubble = bubbleClass.init(rcMessages:[message], currentUserId: _currentUserId) else {
                return nil
            }
            if let firstUnreadMessageId = firstUnreadMessageId,
               bubble.message.messageId == firstUnreadMessageId {
                bubble.shownUnreadLine = true
            }
            updateDateText(bubble, lastBubble: lastBubble)
            lastBubble = bubble
            return bubble
        }
        return bubbles
    }
    
    
    func updateDateText(_ bubble: BubbleModel, lastBubble: BubbleModel?) {
        let date = NSDate(timeIntervalSince1970: TimeInterval(bubble.message.sentTime) / 1000)
        guard let lastBubble = lastBubble else {
            bubble.dateText = date.beautyTime()
            return
        }
        bubble.dateText = nil
        let lastSentTime = lastBubble.message.sentTime
        let previousDate = Date(timeIntervalSince1970: TimeInterval(lastSentTime) / 1000)
        guard !date.isSameDay(previousDate) else {
            bubble.dateText = nil
            return
        }
        bubble.dateText = date.beautyTime()
    }
    
}

//MARK: Query RCMessage
private extension MessageDataSource {
        
    func latestMessages() -> [RCMessage]? {
        _rcManager.getLatestMessages(_rcConversation.conversationType, targetId: _rcConversation.targetId, channelId: _rcConversation.channelId, count: kQuantumCount)?.reversed()
    }
    
    func messagesAround(sentTime: Int64) -> [RCMessage]? {
        _rcManager.getHistoryMessages(_rcConversation.conversationType, targetId: _rcConversation.targetId, channelId: _rcConversation.channelId, sentTime: sentTime, beforeCount: kQuantumCount, afterCount: kQuantumCount)
    }
    
    func messagesOlderThan(messageId: Int) -> [RCMessage]? {
        _rcManager.getHistoryMessages(_rcConversation.conversationType, targetId: _rcConversation.targetId, channelId: _rcConversation.channelId, objectName: nil, oldestMessageId: messageId, count: kQuantumCount)
    }
    
    func messagesLaterThan(messageId: Int) -> [RCMessage]? {
        _rcManager.getHistoryMessages(_rcConversation.conversationType, targetId: _rcConversation.targetId, channelId: _rcConversation.channelId, objectName: nil, baseMessageId: messageId, isForward: false, count: kQuantumCount)
    }
    
}
