//
//  MessageUserCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import Foundation

class MessageUserCell: MessageBaseCell {
    
    private(set) lazy var detailView = MessageDetailView()
    
    override func updateSubviewsOnReuse(_ bubbleModel: BubbleModel?) {
        super.updateSubviewsOnReuse(bubbleModel)
    }
    
    override func add(bubbleView: BubbleView) {
        detailView.bubbleContainerView.addSubview(bubbleView)
    }
    
}
