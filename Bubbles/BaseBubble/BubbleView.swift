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
    
    func setupBubbleSubviews() { }
    
    /// 响应气泡点击事件
    /// - Parameter gesture: 事件手势
    /// - Returns: 是否已响应事件，并终止事件传递
    func onTapBubble(_ gesture: UITapGestureRecognizer) -> Bool { return false }
    
    /// 响应气泡长摁事件
    /// - Parameter gesture: 事件手势
    /// - Returns: 是否已响应事件，并终止事件传递
    func onLongPressBubble(_ gesture: UILongPressGestureRecognizer) -> Bool { return false }
    
    /// 响应气泡拖动事件
    /// - Parameter gesture: 事件手势
    /// - Returns: 是否已响应事件，并终止事件传递
    func onPanBubble(_ gesture: UIPanGestureRecognizer) -> Bool { return false }
    
}
