//
//  ContactCardBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLib
import BMIMLib

class ContactCardBubbleModel: BubbleModel, BubbleInfoProtocol {
    
    var cellType: String {
        message.messageDirection == .send
        ? MessageCellRegister.sender
        : MessageCellRegister.receiver
    }

    var bubbleViewType: BubbleView.Type {
        ContactCardBubbleView.self
    }
    
    var canTapAvatar = true
    lazy var canLongPressAvatarMention = message.conversationType == .group
    lazy var canPanReference = message.conversationType != .person_encrypted
    
    
    static let cellHeight: CGFloat = 110
    
    var cardName: String?
    var portraitUrl: String?
    var orgId: String?

    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let contactCardContent = rcMessage.content as? RCContactCardMessage else {
            return
        }
        cardName = contactCardContent.name
        portraitUrl = contactCardContent.portraitUri
        orgId = message.contentExtra?.profileOid

        bubbleContentSize = CGSize(width: ceil(CGFloat.bubble.maxWidth), height: ceil(ContactCardBubbleModel.cellHeight))
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
