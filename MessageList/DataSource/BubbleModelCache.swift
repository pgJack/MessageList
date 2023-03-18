//
//  BubbleModelCache.swift
//  String
//
//  Created by Noah on 2023/3/18.
//

import Foundation
import BMMagazine

struct BubbleModelCache {
    
    let userId: String
    var recorder: BMKVRecorder
    
    init(userId: String) {
        self.userId = userId
        recorder = BMKVRecorder(functionName:"BubbleContent", storeId:userId)
    }
    
    func cache(_ bubble: BubbleModel, forMessageId mId:Int) {
        guard mId > 0 else {
            return
        }
        do {
            let bubbleData = try JSONEncoder().encode(bubble)
            self.recorder.setRecord(NSData(data: bubbleData), forKey: "\(mId)")
        } catch {
            print("[Bubble] cache encode error: \(error)")
        }
    }
    
    func bubbleModel<T: BubbleModel>(forMessageId mId: Int, bubbleClass: T.Type) -> T? {
        guard let bubbleData = recorder.getRecordOf(NSData.self, forKey: "\(mId)") as? Data else {
            return nil
        }
        var bubble: T? = nil
        do {
            bubble = try JSONDecoder().decode(bubbleClass, from: bubbleData)
        } catch {
            print("[Bubble] cache decode error: \(error)")
        }
        return bubble
    }
    
    func removeCache(forMessageId mId: Int) {
        recorder.removeRecord(forKey: "\(mId)")
    }
    
    func clearMemoryCache() {
        recorder.clearMemoryCache()
    }
    
    func preloadContent(forMessageIds mIds: [Int]) {
        recorder.preloadRecords(of: NSData.self, forKeys: mIds.map{ "\($0)" })
    }
    
}
