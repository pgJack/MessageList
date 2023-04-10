//
//  OnlineDocumentBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore
import BMIMLib

class OnlineDocumentBubbleModel: BubbleModel, BubbleInfoProtocol, BubbleImageProtocol {
    
    var cellType: String {
        message.messageDirection == .send
        ? MessageCellRegister.sender
        : MessageCellRegister.receiver
    }

    var bubbleViewType: BubbleView.Type {
        OnlineDocumentBubbleView.self
    }
    
    var canTapAvatar = true
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
    
    static let cellHeight: CGFloat = 131
    static let thumbnailViewHeight: CGFloat = CGFloat.bubble.maxWidth / 16.0 * 9.0
    static let fileInfoViewEdges = UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 2)
    static let thumbnailTopMargin = 2
    static let lineEdges = UIEdgeInsets(top: 24, left: 10, bottom: 0, right: 10)
    static let openButtonEdges = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    
    var fileName: String?
    var thumbnailViewUrl: String?
    
    var thumbnailIconView: UIImage?
    var erroString: String?

    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let onlineDocContent = rcMessage.content as? BMOnlineDocumentMessage else {
            return
        }
        
        fileName = onlineDocContent.content.name

        let height = OnlineDocumentBubbleModel.cellHeight + OnlineDocumentBubbleModel.thumbnailViewHeight
        bubbleContentSize = CGSize(width: ceil(CGFloat.bubble.maxWidth), height: ceil(height))
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
