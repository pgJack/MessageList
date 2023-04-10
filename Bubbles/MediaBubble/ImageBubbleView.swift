//
//  ImageBubbleView.swift
//  String
//
//  Created by 孙浩 on 2023/4/10.
//

import UIKit

class ImageBubbleView: BubbleView {

    lazy var thumbnailImgView: ThumbnailImageView = ThumbnailImageView()
    
    static let thumbnailImgEdges = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    
    override var bubbleModel: BubbleModel? {
        didSet {
            guard let mediaBubble = bubbleModel as? MediaBubbleModel else {
                return
            }
            thumbnailImgView.image = mediaBubble.thumbImage
        }
    }
    
    override func setupBubbleSubviews() {
        super.setupBubbleSubviews()
        
        addSubview(thumbnailImgView)
        thumbnailImgView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(ImageBubbleView.thumbnailImgEdges.top)
            make.leading.trailing.equalToSuperview().inset(ImageBubbleView.thumbnailImgEdges.left)
            make.bottom.equalToSuperview().offset(-ImageBubbleView.thumbnailImgEdges.bottom)
        }
    }
}
