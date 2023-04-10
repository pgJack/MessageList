//
//  MediaBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/7.
//

import UIKit
import RongIMLibCore

class MediaBubbleModel: BubbleModel, BubbleInfoProtocol, BubbleImageProtocol {
    
    var fileName: String?
    var fileUrl: String?
    var localPath: String?
    var thumbImage: UIImage?
    
    //MARK: Bubble Info
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
    var bubbleForegroundImageType: BubbleImageType {
        return .none
    }
    var bubbleBackgroundImageType: BubbleImageType {
        switch message.messageDirection {
        case .send:
            return isBubbleHighlighted ? .purple_v2 : .purple_v1
        default:
            return isBubbleHighlighted ? .gray : .white
        }
    }
    
    override func setupBubbleContent(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleContent(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let mediaContent = rcMessage.content as? RCMediaMessageContent else {
            return
        }
        fileName = mediaContent.name
        fileUrl = mediaContent.remoteUrl
        localPath = mediaContent.localPath
    }
    
    override func setupBubbleSize(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleSize(rcMessages: rcMessages, currentUserId: currentUserId)
        let width = CGFloat.bubble.maxWidth
//        CGSize orgImageSize = [RCMessageCellTool getOriginalImageSizeWithMessageModel:model];
//        CGSize size = [RCMessageCellTool getImageCellSize:orgImageSize.width height:orgImageSize.height textWidth:0];
        let size = thumbImage?.size
        let height: CGFloat = size?.height ?? 0
        bubbleContentSize = CGSize(width: ceil(width), height: ceil(height))
    }
    
}
