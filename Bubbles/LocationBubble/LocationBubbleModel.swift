//
//  LocationBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLib
import RongLocation

class LocationBubbleModel: BubbleModel, BubbleInfoProtocol, BubbleImageProtocol {
    var cellType: String {
        message.messageDirection == .send
        ? MessageCellRegister.sender
        : MessageCellRegister.receiver
    }
    
    var bubbleViewType: BubbleView.Type {
        LocationBubbleView.self
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

    static let nameEdge = UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 12)
    static let addressEdge = UIEdgeInsets(top: 4, left: 12, bottom: 21, right: 12)
    static let bubbleWidth: CGFloat = .bubble.maxWidth
    static let thumbnailHeight: CGFloat = bubbleWidth / 2
    static let textMaxWidth = bubbleWidth - addressEdge.left - addressEdge.right
    
    var locationName: String?
    var addressName: String?
    var latitude: Double = 0
    var longitude: Double = 0
    
    // TODO: - 缩略图处理
    var thumbnailImage: UIImage?
    
    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let locationContent = rcMessage.content as? RCLocationMessage else {
            return
        }
        latitude = locationContent.location.latitude
        longitude = locationContent.location.longitude
        
        locationName = locationContent.locationName
        thumbnailImage = locationContent.thumbnailImage
        addressName = message.contentExtra?.locationName
        
        let maxSize = CGSize(width: LocationBubbleModel.textMaxWidth, height: .greatestFiniteMagnitude)
        guard let nameRect = locationName?.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil),
        let addressRect = addressName?.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, context: nil) else {
            return
        }
        
        let width = LocationBubbleModel.bubbleWidth
        
        let titleHeight = nameRect.size.height > 44 ? 44 : nameRect.size.height;
        let addressHeight = addressRect.size.height > 34 ? 34 : addressRect.size.height;
        let height = LocationBubbleModel.thumbnailHeight + titleHeight + LocationBubbleModel.nameEdge.top + LocationBubbleModel.nameEdge.bottom + addressHeight + LocationBubbleModel.addressEdge.top + LocationBubbleModel.addressEdge.bottom
        bubbleContentSize = CGSize(width: ceil(width), height: ceil(height))
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
}
