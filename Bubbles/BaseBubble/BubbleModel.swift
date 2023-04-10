//
//  BubbleModel.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import UIKit
import RongIMLib

class BubbleModel: Codable {
    
    /// 当前气泡对应的 Message，聚合气泡为第一个 Message
    var message: Message { messages.first! }
    
    /// 聚合气泡包含多个 Message
    var messages: [Message]

    /// 气泡内容尺寸，不包含发送人名称、消息点赞、扩展消息视图
    var bubbleContentSize: CGSize = .zero
    var bubbleDisplaySize: CGSize {
        let contentWidth = bubbleContentSize.width + bubbleContentEdge.left + bubbleContentEdge.right
        let width = max(bubbleContainerSize.width, contentWidth)
        let contentHeight = bubbleContentSize.height + bubbleContentEdge.top + bubbleContentEdge.bottom
        let height: CGFloat = max(bubbleContainerSize.height, contentHeight)
        return CGSize(width: width, height: height)
    }
    
    /// 气泡内容边距，包含引用视图，转发标记，WhatsApp 标记，文本框
    private var bubbleContentEdge: UIEdgeInsets = .zero
    private var bubbleContainerSize: CGSize = .zero
    
    /// 当前用户id
    var currentUserId: String
    
    /// 顶部视图
    var dateText: String?
    var shownUnreadLine = false
    
    /// 时间视图
    var timeText: String?
    
    /// 已读回执视图
    var shownReadReceipt = false
    
    /// 扩展气泡视图
    var shownExBubble = false

    /// 气泡是否高亮
    var isBubbleHighlighted = false
    
    /// 是否被收藏
    var isStarred = false
    
    /// 是否被置顶
    var isPinned = false
    
    //MARK: Text View
    private static let textLimitCount = 1000
    private static let textEdge = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14)
    private static let textMaxWidth = CGFloat.bubble.maxWidth - textEdge.left - textEdge.right
    
    /// 气泡底部文本，如果设置，不需要子类给 timeText 赋值，也不需要子类设置 timeView
    var bubbleText: String? {
        didSet {
            bubbleText = bubbleText?.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    var bubbleTextEdge: UIEdgeInsets {
        guard isBigEmoji else { return Self.textEdge }
        guard let textUtil = textUtil else { return .zero }
        return textUtil.isFullEmoji ? .zero : Self.textEdge
    }
    
    /// 纯 Emoji 文本是否需要方法
    var isBigEmoji: Bool { false }
    /// 文本是否单行
    lazy var isSingleLineText = true
    /// 气泡底部富文本
    lazy var attributedText = textUtil?.attributedString(limitCount: TextBubbleModel.textLimitCount, isLimited: &isTextLimited)
    /// 文本是否被限制长度
    var isTextLimited = false
    /// 富文本转换工具类
    lazy var textUtil: BubbleAttributedTextUtil? = { () -> BubbleAttributedTextUtil? in
        guard let bubbleText = bubbleText else { return nil }
        let mentionInfo = message.contentExtra?.mentionInfo
        return BubbleAttributedTextUtil(currentUserId: currentUserId, roughText: bubbleText, maxWidth: BubbleModel.textMaxWidth, isBigEmoji: isBigEmoji, mentionedInfo: mentionInfo)
    }()
    
    //MARK: Time View
    /// 时间视图背景模式，e.g 无背景，半透明，阴影
    var timeBackgroundStyle: BubbleTimeBackgroundStyle { .clear }
    /// 时间视图背景对齐方式
    var timeAlignment: BubbleTimeAlignment { .training }
    
    //MARK: Override Method
    required init?(rcMessages: [RCMessage], currentUserId: String) {
        guard rcMessages.count > 0 else { return nil }
        let messages = rcMessages.compactMap(Message.init)
        self.currentUserId = currentUserId
        self.messages = messages
    }
    
    func setupBubbleContent(rcMessages: [RCMessage], currentUserId: String) {
        timeText = BubbleModel.sentTimeText(message: messages.first!)
    }
    
    func setupBubbleSize(rcMessages: [RCMessage], currentUserId: String) {
        let textSize = _setupTextSize()
        bubbleContentEdge = UIEdgeInsets(top: 0, left: 0, bottom: textSize.height, right: 0)
        bubbleContainerSize = textSize
    }
    
}

//MARK: Bubble Container View
private extension BubbleModel {
    
    func _setupTextSize() -> CGSize {
        guard bubbleText != nil else { return .zero }
        let maxTextSize = CGSize(width: BubbleModel.textMaxWidth, height: .greatestFiniteMagnitude)
        guard let textRect = BubbleAttributedTextUtil.boundingRect(attributedText, maxSize: maxTextSize) else { return .zero }        
        let width = textRect.size.width + bubbleTextEdge.left
        let height = textRect.size.height + bubbleTextEdge.top
        var textSize = CGSize(width: width, height: height)
        guard let timeText = timeText, !timeText.isEmpty else { return textSize }
        
        let iconCount = [isPinned, isStarred].reduce(0) { partialResult, isExist in
            return partialResult + (isExist ? 1 : 0)
        }
        let timeBackgroundStyle = self.timeBackgroundStyle
        let timeSize = BubbleTimeView.sizeFor(iconCount: CGFloat(iconCount), timeText: timeText, backgroundStyle: timeBackgroundStyle)
        let overMaxWidth = timeSize.width + textSize.width > .bubble.maxWidth
        isSingleLineText = timeBackgroundStyle == .clear && !overMaxWidth
        if isSingleLineText {
            textSize.width += timeSize.width
            textSize.height += bubbleTextEdge.bottom
        } else {
            textSize.width = max(textSize.width, timeSize.width) + bubbleTextEdge.right
            textSize.height += timeSize.height
        }
        return CGSize(width: ceil(textSize.width), height: ceil(textSize.height))
    }
    
}

//MARK: Bubble Size
extension BubbleModel {
    
    var bubbleSize: CGSize {
        return CGSize(width: bubbleDisplaySize.width, height: bubbleHeight)
    }
    
    var bubbleHeight: CGFloat {
        var height: CGFloat = bubbleDisplaySize.height
        /// 姓名框高度
        if shownSenderName {
            height += .bubble.nameHeight
        }
        /// 点赞面板高度，聚合消息不显示点赞
        if messages.count == 1, shownThumbUp {
            height += .bubble.reactionTop + .bubble.reactionHeight
        }
        /// 扩展气泡高度，翻译内容高度+上下边距
        height += exBubbleSize.height
        /// 内容边距
        height += UIEdgeInsets.bubble.contentEdge.top + UIEdgeInsets.bubble.contentEdge.bottom
        return height
    }
    
}

//MARK: ExBubble
extension BubbleModel {
    
    var translateViewSize: CGSize {
        .zero
    }
    
    var exBubbleSize: CGSize {
        let contentSize = translateViewSize
        guard !contentSize.equalTo(.zero) else {
            return .zero
        }
        let exBubbleEdge = UIEdgeInsets.bubble.exBubbleEdge
        return CGSize(width: exBubbleEdge.left + contentSize.width + exBubbleEdge.right,
                      height: exBubbleEdge.top + contentSize.height + exBubbleEdge.bottom)
    }
    
}

//MARK: Computed Properties
extension BubbleModel {
    
    /// 是否为聚合气泡
    var isCombined: Bool { messages.count > 1 }
    
    /// 是否包含某个 Message
    func isContain(_ message: Message) -> Bool {
        messages.contains {
            message.messageId == $0.messageId
        }
    }
    
    /// 是否显示发送人头像
    var shownSenderAvatar: Bool {
        message.conversationType == .group
        && message.messageDirection == .receive
    }
    
    /// 是否显示发送人名称
    var shownSenderName: Bool {
        message.conversationType == .group
        && message.messageDirection == .receive
        && !message.isFromWhatsApp
    }
    
    /// 是否显示转发标记
    var shownForwardTip: Bool {
        message.forwardType == .others
    }
    
    /// 是否显示 WhatsApp 转发标记
    var shownWhatsAppTip: Bool {
        message.isFromWhatsApp
    }
    
    /// 消息点赞视图
    var shownThumbUp: Bool {
        guard let thumbUps = message.thumbUps else {
            return false
        }
        return thumbUps.count > 0
    }
    
    /// 是否 @ 所有人
    var isMentionedAll: Bool {
        message.isMentionedAll
    }
    
    private static func sentTimeText(message: Message) -> String? {
        let sentTime = message.sentTime
        guard let timeText = MessageListGlobalConfig.shared.text(sentTime: sentTime) else { return nil }
        guard message.isFromWhatsApp,
              let whatsAppTimeText = message.whatsAppSentTime else {
            return timeText
        }
        let finalText = whatsAppTimeText+" imported "+timeText
        guard finalText.count > 35 else {
            return finalText
        }
        return whatsAppTimeText+"..."+timeText
    }
    
}
