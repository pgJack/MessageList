//
//  MessageListDataSource.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import Foundation
import RongIMLib

class MessageListDataSource {
    
    private(set) var bubbleModels = [BubbleModel]()
    
    private let bubbleCache: BubbleModelCache
    
    init(userId: String) {
        bubbleCache = BubbleModelCache(userId: userId)
    }
    
    deinit {
        clearMemoryCache()
    }

}

//MARK: Cache Method
extension MessageListDataSource {
    
    func removeCache(forMessageId mId: Int) {
        bubbleCache.removeCache(forMessageId: mId)
    }
    
    func clearMemoryCache() {
        bubbleCache.clearMemoryCache()
    }
    
    func preloadContent(forMessageIds mIds: [Int]) {
        bubbleCache.preloadContent(forMessageIds: mIds)
    }
    
}
