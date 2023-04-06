//
//  LocationBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLib
import RongLocation

class LocationBubbleModel: BubbleModel {
    
    private enum CodingKeys: CodingKey {
        case locationName
        case addressName
        case latitude
        case longitude
    }

    static let nameEdge = UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 12)
    static let addressEdge = UIEdgeInsets(top: 4, left: 12, bottom: 0, right: 12)
    static let bubbleWidth: CGFloat = 326
    static let thumbnailHeight: CGFloat = 326 / 2
    static let textMaxWidth = bubbleWidth - addressEdge.left - addressEdge.right
    
    var locationName: String?
    var addressName: String?
    var latitude: Double = 0
    var longitude: Double = 0
    
    // TODO: - 缩略图处理
    var thumbnailImage: UIImage?
    
    override var cellType: String {
        message.messageDirection == .send
        ? MessageCellRegister.sender
        : MessageCellRegister.receiver
    }
    
    override var bubbleViewType: BubbleView.Type {
        LocationBubbleView.self
    }
    
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
    
    public required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        locationName = try container.decode(String.self, forKey: .locationName)
        addressName = try container.decode(String.self, forKey: .addressName)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
    }
    
    override func encode(to encoder: Encoder) throws {
        try super.encode(to: encoder)
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(locationName, forKey: .locationName)
        try container.encode(addressName, forKey: .addressName)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}
