//
//  MessageListCollectionViewLayout.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import UIKit

class MessageListCollectionViewLayout: UICollectionViewFlowLayout {
    
    weak var viewModel: MessageListViewModel?
    
    /// 加载完历史消息，列表显示消息保持在加载前的位置
    var addedHeight: CGFloat = 0
    
    /// 布局整体高度，所有气泡高度和
    var layoutHeight: CGFloat = 0
    /// 布局整体宽度，列表视图宽度
    var layoutWidth: CGFloat {
        collectionView?.frame.size.width ?? 0
    }
    
    /// 所有气泡 Frame
    lazy var bubbleFrames = [CGRect]()

    override func prepare() {
        super.prepare()
        viewModel?.onCollectionViewPrepareLayout()
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: layoutWidth, height: layoutHeight)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForMessage(at: indexPath)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesForMessages(in: rect)
    }
    
    override func finalizeCollectionViewUpdates() {
        guard let collectionView = collectionView else { return }
        guard addedHeight > 0 else { return }
        var offset = collectionView.contentOffset
        offset.y += addedHeight
        collectionView.contentOffset = offset
        addedHeight = 0
    }
    
}

extension MessageListCollectionViewLayout {
    
    func layoutAttributesForMessage(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard bubbleFrames.count > indexPath.row else { return nil }
        let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        layoutAttribute.frame = bubbleFrames[indexPath.row]
        return layoutAttribute
    }
    
    func layoutAttributesForMessages(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        bubbleFrames.enumerated().filter {
            !rect.intersection($0.element).isNull
        }.map {
            let indexPath = IndexPath(item: $0.offset, section: 0)
            let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            layoutAttribute.frame = $0.element
            return layoutAttribute
        }
    }
    
}
