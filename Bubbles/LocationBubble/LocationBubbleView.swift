//
//  LocationBubbleView.swift
//  String
//
//  Created by 孙浩 on 2023/4/6.
//

import UIKit

class LocationBubbleView: BubbleView {

    lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.image = .bubble.defaultLocationThumbnail
        return imageView
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = .bubble.normal
//        label.textAlignment = [RCKitUtility isRTL] ? NSTextAlignmentRight : NSTextAlignmentLeft
//        label.textColor = BMThemeUtil.messageDateHeaderTitleColor
        return label
    }()

    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12)
//        label.textAlignment = [RCKitUtility isRTL] ? NSTextAlignmentRight : NSTextAlignmentLeft
//        label.textColor = BMThemeUtil.messageDigestTitleColor;
        return label
    }()
    

    override var bubbleModel: BubbleModel? {
        didSet {
            guard let locationBubble = bubbleModel as? LocationBubbleModel else {
                thumbnailImageView.image = nil
                nameLabel.text = nil
                addressLabel.text = nil
                return
            }
            thumbnailImageView.image = locationBubble.thumbnailImage
            nameLabel.text = locationBubble.locationName
            addressLabel.text = locationBubble.addressName
        }
    }
    
    override func setupBubbleSubviews() {
        super.setupBubbleSubviews()
        addSubview(thumbnailImageView)
        addSubview(nameLabel)
        addSubview(addressLabel)
        thumbnailImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(LocationBubbleModel.thumbnailHeight)
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(LocationBubbleModel.nameEdge.left)
            make.trailing.equalToSuperview().offset(LocationBubbleModel.nameEdge.right)
            make.top.equalTo(thumbnailImageView.snp.bottom).offset(LocationBubbleModel.nameEdge.top)
        }

        addressLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(LocationBubbleModel.addressEdge.top)

        }
    }
}
