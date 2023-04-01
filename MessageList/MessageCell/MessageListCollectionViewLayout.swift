//
//  MessageListCollectionViewLayout.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import UIKit

class MessageListCollectionViewLayout: UICollectionViewFlowLayout {
    
    weak var viewModel: MessageListViewModel?
    
    /// 布局整体高度，所有气泡高度和
    var layoutHeight: CGFloat = 0
    /// 布局整体宽度，列表视图宽度
    var layoutWidth: CGFloat {
        collectionView?.frame.size.width ?? 0
    }
    
    /// 所有气泡 Frame
    lazy var bubbleFrames = [CGRect]()

    public override func prepare() {
        super.prepare()
        viewModel?.onCollectionViewPrepareLayout()
    }
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: layoutWidth, height: layoutHeight)
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForMessage(at: indexPath)
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributesForMessages(in: rect)
    }
    
    override func finalizeCollectionViewUpdates() {
        print("---> layout end")
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
