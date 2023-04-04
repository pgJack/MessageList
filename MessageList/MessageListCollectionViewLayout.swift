//
//  MessageListCollectionViewLayout.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import UIKit

class MessageListCollectionViewLayout: UICollectionViewFlowLayout {
    
    weak var viewModel: MessageListViewModel?
    
    /// 所有气泡 Frame
    lazy var bubbleLayouts = [UICollectionViewLayoutAttributes]()
    
    /// 布局整体高度，所有气泡高度和
    private var _layoutHeight: CGFloat = 0
    /// 布局整体宽度，列表视图宽度
    private var _layoutWidth: CGFloat {
        collectionView?.frame.size.width ?? 0
    }
    
    override func prepare() {
        super.prepare()
        resetBubbleLayouts()
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: _layoutWidth, height: _layoutHeight)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return bubbleLayouts[indexPath.row]
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return bubbleLayouts.filter { !rect.intersection($0.frame).isNull }
    }
    
}

extension MessageListCollectionViewLayout {
    
    func resetBubbleLayouts() {
        _layoutHeight = 0
        bubbleLayouts = []
        guard let bubbles = viewModel?.dataSource?.bubbleModels else { return }
        let x: CGFloat = 0
        let width = _layoutWidth
        bubbleLayouts = bubbles.enumerated().map { item in
            let bubble = item.element
            let index = item.offset
            let y = _layoutHeight
            let height = _messageCellHeight(for: bubble)
            let frame = CGRect(x: x, y: y, width: width, height: height)
            let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            layoutAttribute.frame = frame
            _layoutHeight += height
            return layoutAttribute
        }
    }
    
    /// 重置气泡布局，并计算出指定气泡的偏移量
    func insertBubbleLayouts(for bubbles: [BubbleModel], at index: Int, offsetForIndex baseIndex: Int?) -> CGFloat {
        guard bubbleLayouts.count >= index else { return 0 }
        var lastMaxY: CGFloat = index > 0 ? bubbleLayouts[index - 1].frame.maxY : 0
        let x: CGFloat = 0
        let width = _layoutWidth
        var addedHeight: CGFloat = 0
        let addedLayouts = bubbles.map { bubble in
            let y = lastMaxY
            let height = _messageCellHeight(for: bubble)
            lastMaxY += height
            addedHeight += height
            let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: index, section: 0))
            layoutAttribute.frame = CGRect(x: x, y: y, width: width, height: height)
            return layoutAttribute
        }
        _layoutHeight += addedHeight
        var baseViewOffset = CGPoint.zero
        bubbleLayouts[index...].enumerated().forEach {
            let index = $0.offset
            let layout = $0.element
            var frame = layout.frame
            frame.origin.y += addedHeight
            layout.frame = frame
            if baseIndex == index {
                baseViewOffset = CGPoint(x: 0, y: addedHeight)
            }
        }
        bubbleLayouts.insert(contentsOf: addedLayouts, at: index)
        return baseViewOffset.y
    }
    
    private func _messageCellHeight(for bubble: BubbleModel) -> CGFloat {
        /// 气泡内容高度
        var height = bubble.bubbleHeight
        /// 显示 unreadLine，高度增加
        if bubble.shownUnreadLine {
            height += .bubble.unreadLineHeight
        }
        /// 显示 date，高度增加
        if bubble.dateText != nil {
            height += .bubble.dateViewHeight
        }
        return height
    }
    
}
