//
//  WhatsAppTextBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import BMIMLib

class WhatsAppTextBubbleModel: TextBubbleModel {

    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let textContent = rcMessage.content as? UMBWhatsAppTextMessage else {
            return
        }
        messageText = textContent.content
        let maxSize = CGSize(width: TextBubbleModel.textMaxWidth, height: .greatestFiniteMagnitude)
        guard let textRect = attributedText?.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil) else {
            return
        }
        let width = bubbleContentSize.width + textRect.size.width + TextBubbleModel.textEdge.left + TextBubbleModel.textEdge.right
        let height = bubbleContentSize.height + textRect.size.height + TextBubbleModel.textEdge.top + TextBubbleModel.textEdge.bottom
        bubbleContentSize = CGSize(width: ceil(width), height: ceil(height))
    }
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
