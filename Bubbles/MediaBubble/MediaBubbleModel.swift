//
//  MediaBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/7.
//

import UIKit
import RongIMLibCore

class MediaBubbleModel: BubbleModel {
    
    var fileName: String?
    var fileUrl: String?
    var localPath: String?
    
    
    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let mediaContent = rcMessage.content as? RCMediaMessageContent else {
            return
        }
        
        fileName = mediaContent.name
        fileUrl = mediaContent.remoteUrl
        localPath = mediaContent.localPath
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
