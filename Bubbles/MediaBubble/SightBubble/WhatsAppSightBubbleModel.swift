//
//  WhatsAppSightBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore
import BMIMLib

class WhatsAppSightBubbleModel: SightBubbleModel {
    
    override func setupBubbleContent(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleContent(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let imageContent = rcMessage.content as? UMBWhatsAppSightMessage else {
            return
        }
        thumbImage = imageContent.thumbnailImage
    }
    
}
