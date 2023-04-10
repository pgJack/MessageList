//
//  StickerBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore
import BMIMLib

class StickerBubbleModel: MediaBubbleModel, BubbleInfoProtocol, BubbleImageProtocol {
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
    
    
    static let stickerSize = CGSize(width: 150, height: 150)
    static let stickerBottomMargin: CGFloat = 20
    
    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
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
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
