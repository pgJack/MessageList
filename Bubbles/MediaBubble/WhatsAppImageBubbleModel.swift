//
//  WhatsAppImageBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore
import BMIMLib

class WhatsAppImageBubbleModel: MediaBubbleModel, BubbleInfoProtocol, BubbleImageProtocol {
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
              let imageContent = rcMessage.content as? UMBWhatsAppImageMessage else {
            return
        }
        
        thumbImage = imageContent.thumbnailImage
        
        let width = CGFloat.bubble.maxWidth

        // TODO: - Size 计算
//        CGSize orgImageSize = [RCMessageCellTool getOriginalImageSizeWithMessageModel:model];
//        CGSize size = [RCMessageCellTool getImageCellSize:orgImageSize.width height:orgImageSize.height textWidth:0];
        let size = thumbImage?.size
        let height: CGFloat = size?.height ?? 0
        bubbleContentSize = CGSize(width: ceil(width), height: ceil(height))
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
