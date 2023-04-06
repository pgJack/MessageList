//
//  ContactCardBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLib
import BMIMLib

class ContactCardBubbleModel: BubbleModel {
    private enum CodingKeys: CodingKey {
        case cardName
        case portraitUrl
        case orgId
    }

    static let cellHeight: CGFloat = 110
    
    var cardName: String?
    var portraitUrl: String?
    var orgId: String?

    override var cellType: String {
        message.messageDirection == .send
        ? MessageCellRegister.sender
        : MessageCellRegister.receiver
    }

    override var bubbleViewType: BubbleView.Type {
        ContactCardBubbleView.self
    }

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

    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cardName = try container.decode(String.self, forKey: .cardName)
        portraitUrl = try container.decode(String.self, forKey: .portraitUrl)
        orgId = try container.decode(String.self, forKey: .orgId)
    }

    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cardName, forKey: .cardName)
        try container.encode(portraitUrl, forKey: .portraitUrl)
        try container.encode(orgId, forKey: .orgId)
    }
}
