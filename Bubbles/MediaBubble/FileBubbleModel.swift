//
//  FileBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore

class FileBubbleModel: MediaBubbleModel, BubbleInfoProtocol, BubbleImageProtocol {
    var cellType: String {
        message.messageDirection == .send
        ? MessageCellRegister.sender
        : MessageCellRegister.receiver
    }
    
    var bubbleViewType: BubbleView.Type {
        FileBubbleView.self
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
            return isHighlighted ? .purple_v2 : .purple_v1
        default:
            return isHighlighted ? .gray : .white
        }
    }
    
    static let fileViewEdge = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    static let fileViewHeight = FileInfoView.typeIconSize.height + FileInfoView.typeIconEdges.top + FileInfoView.typeIconEdges.bottom
    
    var fileType: String?
    var fileSize: Int64 = 0
    var thumbnailImageUrl: String?
    var placeholderImage: UIImage?
    
    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let fileContent = rcMessage.content as? RCFileMessage else {
            return
        }
        
        fileType = fileContent.type
        fileSize = fileContent.size
        fileUrl = fileContent.fileUrl
        
        let width = CGFloat.bubble.maxWidth

        let height = FileBubbleModel.fileViewHeight
        bubbleContentSize = CGSize(width: ceil(width), height: ceil(height))
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
