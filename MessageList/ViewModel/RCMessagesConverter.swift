//
//  RCMessagesConverter.swift
//  String
//
//  Created by Noah on 2023/3/24.
//

import Foundation
import RongIMLib

private let kBubbleModelClassTable: [String: BubbleModel.Type] = [
    RCTextMessage.getObjectName(): TextBubbleModel.self
]

struct RCMessagesConverter {
    
    // 是否聚合
    var needCombine = false
    // 最小聚合单元
    var combineUnit = 4
    // 允许聚合的气泡类型
    var combineType = [BubbleModel.Type]()
    
    /// 消息数据源缓存
    var _bubbleModelCache: BubbleModelCache?
    
    func convert(_ messages:[RCMessage], currentUserId: String) -> [BubbleModel] {
        return messages.compactMap { message -> BubbleModel? in
            guard let objectName = message.objectName,
                  let bubbleClass = kBubbleModelClassTable[objectName] else {
                return nil
            }
            if let cachedBubble = _bubbleModelCache?.bubbleModel(forMessageId: message.messageId, bubbleClass: bubbleClass),
               cachedBubble.message.messageType == message.content?.messageType {
                return cachedBubble
            }
            guard let bubbleModel = bubbleClass.init(rcMessages:[message], currentUserId: currentUserId) else {
                return nil
            }
            _bubbleModelCache?.cache(bubbleModel, forMessageId: message.messageId)
            return bubbleModel
        }
    }
    
}
