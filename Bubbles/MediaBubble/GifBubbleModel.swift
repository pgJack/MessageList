//
//  GifBubbleModel.swift
//  String
//
//  Created by Noah on 2023/3/30.
//

import UIKit
import RongIMLib
import YYImage

class GifBubbleModel: MediaBubbleModel, BubbleInfoProtocol, BubbleImageProtocol {
    var cellType: String {
        message.messageDirection == .send
        ? MessageCellRegister.sender
        : MessageCellRegister.receiver
    }
    
    var bubbleViewType: BubbleView.Type {
        ImageBubbleView.self
    }
    
    var canTapAvatar: Bool = true
    lazy var canLongPressAvatarMention = message.conversationType == .group
    lazy var canPanReference = message.conversationType != .person_encrypted
    
    
    //MARK: Bubble Background Image
    var isHighlighted: Bool = false
    var bubbleForegroundImageType: BubbleImageType {
        return .none
    }
    var bubbleBackgroundImageType: BubbleImageType {
        switch message.messageDirection {
        case .send:
            return isHighlighted ? .purple_v2 : .purple_v1
        default:
            return isHighlighted ? .gray : .white
        }
    }
    
    
    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
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
        
        let width = CGFloat.bubble.maxWidth

        let height: CGFloat = CGFloat(gifContent.height)
        bubbleContentSize = CGSize(width: ceil(width), height: ceil(height))
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}

