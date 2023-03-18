//
//  MessageListUtil.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import UIKit

extension BubbleModel {
    var contentUtil: BubbleContentUtil {
        BubbleContentUtil(bubble: self)
    }
    var layoutUtil: BubbleLayoutUtil {
        BubbleLayoutUtil(bubble: self)
    }
}

//MARK: Bubble Content
struct BubbleContentUtil {
    
    var shownUserAvatar: Bool {
        bubble.message.conversationType == .group
        && bubble.message.messageDirection == .receive
    }
    
    var shownUserName: Bool {
        bubble.message.conversationType == .group
        && bubble.message.messageDirection == .receive
        && !bubble.message.isFromWhatsApp
    }
    
    let bubble: BubbleModel
    
    init(bubble: BubbleModel) {
        self.bubble = bubble
    }
    
}

//MARK: Message Layout
struct BubbleLayoutUtil {
    
    var height: CGFloat {
        var height: CGFloat = bubble.bubbleSize.height
        /// 姓名框高度
        if bubble.contentUtil.shownUserName {
            height += .bubble.nameHeight
        }
        /// 点赞面板高度，聚合消息不显示点赞
        if bubble.messages.count == 1, !bubble.message.thumbUpInfo.isEmpty {
            height += .bubble.reactionTop + .bubble.reactionHeight
        }        
        /// 扩展气泡高度，翻译内容高度+上下边距
        height += exBubbleSize.height
        /// 内容边距
        height += UIEdgeInsets.bubble.contentEdge.top + UIEdgeInsets.bubble.contentEdge.bottom
        return height
    }
    
    var translateViewSize: CGSize {
        .zero
    }
    
    let exBubbleEdge = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    var exBubbleSize: CGSize {
        let contentSize = translateViewSize
        guard !contentSize.equalTo(.zero) else {
            return .zero
        }
        return CGSize(width: exBubbleEdge.left + contentSize.width + exBubbleEdge.right,
                      height: exBubbleEdge.top + contentSize.height + exBubbleEdge.bottom)
    }
    
    let bubble: BubbleModel
    
    init(bubble: BubbleModel) {
        self.bubble = bubble
    }
    
}
