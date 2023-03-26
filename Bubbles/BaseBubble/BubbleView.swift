//
//  BubbleView.swift
//  BMIMModule
//
//  Created by Noah on 2022/11/28.
//

import UIKit

class BubbleView: UIView {
    
    var bubbleModel: BubbleModel?
    
    required init?(bubble: BubbleModel?) {
        guard let bubble = bubble else { return nil }
        bubbleModel = bubble
        super.init(frame: CGRect(origin: .zero, size: bubble.bubbleContentSize))
        setupBubbleSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    func setupBubbleSubviews() {
        
    }
    
}
