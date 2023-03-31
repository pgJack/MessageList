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
    
    /// 气泡模型数据源，在主队列使用
    var bubbleModels = [BubbleModel]()
    
    // 是否聚合
    let needCombine = true
    // 最小聚合单元
    let combineUnit = 4
    // 允许聚合的消息类型
    let combineType = [RCImageMessage.self, RCSightMessage.self, RCGIFMessage.self]
    
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

    // 数据源标记，在 _sourceQueue 队列中使用
    /// 是否存在更多未加载的历史消息
    private var _hasMoreOlderMessages = true
    /// 是否存在更多未加载的最新消息
    private var _hasMoreLaterMessages = true
    
    /// 历史消息加载中
    private var _isLoadingOlderMessage = false
    /// 新消息加载中
    private var _isLoadingLaterMessage = false

    /// 历史消息网络请求标记
    private var _olderRequestSentTime: Int64?
    
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

//MARK: Public Var
extension MessageDataSource {
    
    var unreadCount: Int32 {
        _rcManager.getUnreadCount(_rcConversation.conversationType, targetId: _rcConversation.targetId, channelId: _rcConversation.channelId)
    }
        
}

//MARK: Public Method
extension MessageDataSource {
    
    func anchor(atMessageId mid: Int, animated: Bool = false) {
        self._startLoadingLaterSign()
        self._startLoadingOlderSign()
        _sourceQueue.async { [weak self] in
            guard let `self` = self else { return }
            defer {
                self._endloadingOlderSign()
                self._endloadingLaterSign()
            }
            guard let message = RCCoreClient.shared().getMessage(mid) else { return }
            /// 重置加载标记
            self._resetHasMoreSign()
            let messages = self._anchor(at: message)
            self._reset(messages: messages, anchorMessageId: message.messageId, animated: animated)
        }
    }
    
    func anchorAtFirstUnreadMessage() {
        self._startLoadingLaterSign()
        self._startLoadingOlderSign()
        _sourceQueue.async { [weak self] in
            guard let `self` = self else { return }
            defer {
                self._endloadingOlderSign()
                self._endloadingLaterSign()
            }
            /// 重置加载标记
            self._resetHasMoreSign()
            guard let firstUnreadMessage = self._rcManager.getFirstUnreadMessage(self._rcConversation.conversationType, targetId: self._rcConversation.targetId, channelId: self._rcConversation.channelId) else {
                let messages = self._latestMessages()
                self._reset(messages: messages)
                return
            }
            let messages = self._anchor(at: firstUnreadMessage)
            let firstUnreadMessageId = firstUnreadMessage.messageId
            self._reset(messages: messages, firstUnreadMessageId: firstUnreadMessageId, anchorMessageId: firstUnreadMessageId)
        }
    }
    
    func loadMoreOlderMessages() {
        guard let firstMessage = self.bubbleModels.first?.message else { return }
        guard !_isLoadingOlderMessage else { return }
        _startLoadingOlderSign()
        _sourceQueue.async { [weak self] in
            guard let `self` = self else { return }
            
            // 取消标记
            defer { self._endloadingOlderSign() }
            
            // 没有更多历史消息，不处理
            guard self._hasMoreOlderMessages else { return }
                          
            // 加载历史消息
            let olderMessages = self._loadMoreOlderMessages(beforeSentTime: firstMessage.sentTime, messageId: firstMessage.messageId)
            self._insertOlder(messages: olderMessages)
        }
    }
        
    func loadMoreLaterMessages() {
        guard let lastMessage = bubbleModels.last?.messages.last else { return }
        guard !_isLoadingLaterMessage else { return }
        _startLoadingLaterSign()
        _sourceQueue.async { [weak self] in
            guard let `self` = self else { return }
            
            // 取消标记
            defer { self._endloadingLaterSign() }
            
            // 没有新消息，不处理
            guard self._hasMoreLaterMessages else { return }
            
            // 加载新消息
            let laterMessages = self._messagesLaterThan(messageId: lastMessage.messageId)
            self._insertLater(messages: laterMessages)
            
            // 新消息数量小于拉取个数，则没有新的消息
            if let laterMessages = laterMessages,
               laterMessages.count < kQuantumCount {
                self._hasMoreLaterMessages = false
            }
        }
    }
    
}


//MARK: Modify DataSource
private extension MessageDataSource {
    
    func _reset(messages: [RCMessage]?, firstUnreadMessageId: Int? = nil, anchorMessageId: Int? = nil, animated: Bool = false) {
        DispatchQueue.mainAction { [weak self] in
            guard let `self` = self else { return }
            guard let messages = messages else {
                self.bubbleModels = []
                self._viewModel?.dataSourceDidReset()
                return
            }
            let bubbles = self.convert(messages, firstUnreadMessageId: firstUnreadMessageId)
            self.bubbleModels = bubbles
            self._viewModel?.dataSourceDidReset()
            if let anchorMessageId = anchorMessageId {
                self._viewModel?.scrollToCenter(messageId: anchorMessageId, animated: animated)
            }
        }
    }
    
    func _insertOlder(messages: [RCMessage]?) {
        guard let messages = messages, messages.count > 0 else { return }
        DispatchQueue.mainAction { [weak self] in
            guard let `self` = self else { return }
            let bubbles = self.convert(messages)
            self.bubbleModels.insert(contentsOf: bubbles, at: 0)
            self._viewModel?.dataSourceDidInsert(bubbles, at: 0)
            self._isLoadingOlderMessage = false
        }
    }
    
    func _insertLater(messages: [RCMessage]?) {
        guard let messages = messages, messages.count > 0 else { return }
        DispatchQueue.mainAction { [weak self] in
            guard let `self` = self else { return }
            let bubbles = self.convert(messages)
            let index = self.bubbleModels.count
            self.bubbleModels += bubbles
            self._viewModel?.dataSourceDidInsert(bubbles, at: index)
            self._isLoadingLaterMessage = false
        }
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

//MARK: Load Sign
private extension MessageDataSource {
    
    // 重置是否可以加载更多标记，_sourceQueue 中维护
    private func _resetHasMoreSign() {
        _hasMoreOlderMessages = true
        _hasMoreLaterMessages = true
        _olderRequestSentTime = nil
    }
    
    // 历史消息记载中
    private func _startLoadingOlderSign() {
        DispatchQueue.mainAction { [weak self] in
            guard let `self` = self else { return }
            self._isLoadingOlderMessage = true
        }
    }
    
    // 历史消息未加载中
    private func _endloadingOlderSign() {
        DispatchQueue.mainAction { [weak self] in
            guard let `self` = self else { return }
            self._isLoadingOlderMessage = false
        }
    }
    
    // 新消息
    private func _startLoadingLaterSign() {
        DispatchQueue.mainAction { [weak self] in
            guard let `self` = self else { return }
            self._isLoadingLaterMessage = true
        }
    }
    
    // 新消息未在加载中
    private func _endloadingLaterSign() {
        DispatchQueue.mainAction { [weak self] in
            guard let `self` = self else { return }
            self._isLoadingLaterMessage = false
        }
    }
    
}

//MARK: Load RCMessage
private extension MessageDataSource {
    
    func _anchor(at message: RCMessage) -> [RCMessage] {
        var messages = [message]
        if let laterMessages = _messagesLaterThan(messageId: message.messageId) {
            messages += laterMessages
        }
        let olderMessages = _loadMoreOlderMessages(beforeSentTime: message.sentTime, messageId: message.messageId)
        if let olderMessages = olderMessages {
            messages.insert(contentsOf: olderMessages, at: 0)
        }
        return messages
    }
    
    func _loadMoreOlderMessages(beforeSentTime sentTime: Int64, messageId: Int) -> [RCMessage]? {
        let olderMessages = _messagesOlderThan(messageId: messageId)
        // 历史消息数量小于拉取个数，则拉取远端历史
        let localCount = olderMessages?.count ?? 0
        guard localCount < kQuantumCount else { return olderMessages }
        let firstSentTime = olderMessages?.first?.sentTime ?? sentTime
        self._loadMoreOlderMessagesFromRemote(beforeSentTime: firstSentTime)
        return olderMessages
    }
    
    func _loadMoreOlderMessagesFromRemote(beforeSentTime sentTime: Int64) {
        _olderRequestSentTime = sentTime
        _requestRemoteOlderMessages(beforeSentTime: sentTime) { [weak self] isSuccess, olderMessages, hasMore in
            guard isSuccess else { return }
            self?._sourceQueue.async { [weak self] in
                guard let `self` = self else { return }
                // 请求参数与标记不匹配，不处理
                guard self._olderRequestSentTime != sentTime else { return }
                // 处理远端历史消息
                self._hasMoreOlderMessages = hasMore
                self._insertOlder(messages: olderMessages)
            }
        }
    }
    
}

//MARK: RCMessage Api
private extension MessageDataSource {
    
    func _latestMessages() -> [RCMessage]? {
        _rcManager.getLatestMessages(_rcConversation.conversationType, targetId: _rcConversation.targetId, channelId: _rcConversation.channelId, count: kQuantumCount)?.reversed()
    }
    
    func _messagesOlderThan(messageId: Int) -> [RCMessage]? {
        _rcManager.getHistoryMessages(_rcConversation.conversationType, targetId: _rcConversation.targetId, channelId: _rcConversation.channelId, objectName: nil, oldestMessageId: messageId, count: kQuantumCount)?.reversed()
    }
    
    func _messagesLaterThan(messageId: Int) -> [RCMessage]? {
        _rcManager.getHistoryMessages(_rcConversation.conversationType, targetId: _rcConversation.targetId, channelId: _rcConversation.channelId, objectName: nil, baseMessageId: messageId, isForward: false, count: kQuantumCount)
    }
    
    func _requestRemoteOlderMessages(beforeSentTime sentTime: Int64, then: @escaping (Bool, [RCMessage]?, Bool)->()) {
        _rcManager.getRemoteHistoryMessages(_rcConversation.conversationType, targetId: _rcConversation.targetId, channelId: _rcConversation.channelId, recordTime: sentTime, count: kQuantumCount, success: { messages, hasMore in
            then(true, messages.reversed(), hasMore)
        }, error: { errorO in
            then(false, [], false)
        })
    }
    
}
