//
//  WhatsAppFileBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore
import BMIMLib

class WhatsAppFileBubbleModel: FileBubbleModel {
    
    override func setupBubbleContent(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleContent(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let fileContent = rcMessage.content as? UMBWhatsAppFileMessage else {
            return
        }
        
        fileType = fileContent.type
        fileSize = fileContent.size
        fileUrl = fileContent.fileUrl
    }
    
}
