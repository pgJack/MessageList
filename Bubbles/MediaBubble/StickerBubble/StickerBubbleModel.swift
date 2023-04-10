//
//  StickerBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore
import BMIMLib

class StickerBubbleModel: MediaBubbleModel {
    
    static let stickerSize = CGSize(width: 150, height: 150)
    static let stickerBottomMargin: CGFloat = 20
    
    override func setupBubbleContent(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleContent(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let stickerContent = rcMessage.content as? UMBStickerMessage else {
            return
        }
        print("sticker: \(String(describing: stickerContent.remoteUrl))")
        thumbImage = nil
        let width = CGFloat.bubble.maxWidth
        let height: CGFloat = StickerBubbleModel.stickerSize.height + StickerBubbleModel.stickerBottomMargin
        bubbleContentSize = CGSize(width: ceil(width), height: ceil(height))
    }
    
}
