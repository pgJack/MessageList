//
//  GifBubbleModel.swift
//  String
//
//  Created by Noah on 2023/3/30.
//

import UIKit
import RongIMLib
import YYImage

class GifBubbleModel: MediaBubbleModel {

    override func setupBubbleContent(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleContent(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let gifContent = rcMessage.content as? RCGIFMessage else {
            return
        }
        
        // TODO: - gifSize 计算
//        let gifSize = [RCMessageCellTool getImageCellSize:((RCGIFMessage *)model.content).width height:((RCGIFMessage *)model.content).height textWidth:0];
        if let string = message.contentExtra?.gifFirstFrame, let data = Data(base64Encoded: string) {
            thumbImage = YYImage(data:data)
        } else {
            thumbImage = .bubble.gifDefaultImage
        }
    }
    
}

