//
//  SightBubbleModel.swift
//  String
//
//  Created by Noah on 2023/3/30.
//

import UIKit
import RongIMLib

class SightBubbleModel: MediaBubbleModel {
    
    override func setupBubbleContent(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleContent(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let imageContent = rcMessage.content as? RCSightMessage else {
            return
        }
        thumbImage = imageContent.thumbnailImage
    }
    
}

