//
//  ImageBubbleModel.swift
//  String
//
//  Created by Noah on 2023/3/30.
//

import UIKit
import RongIMLib

class ImageBubbleModel: MediaBubbleModel {
    
    override func setupBubbleContent(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleContent(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let imageContent = rcMessage.content as? RCImageMessage else {
            return
        }
        thumbImage = imageContent.thumbnailImage
    }
    
}


