//
//  WhatsAppImageBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore
import BMIMLib

class WhatsAppImageBubbleModel: ImageBubbleModel {

    override func setupBubbleContent(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleContent(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let imageContent = rcMessage.content as? UMBWhatsAppImageMessage else {
            return
        }
        thumbImage = imageContent.thumbnailImage
    }
    
}
