//
//  MessageListCollectionViewLayout.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import UIKit

class MessageListCollectionViewLayout: UICollectionViewFlowLayout {
    
    weak var viewModel: MessageListViewModel?
    
    private var messageListContentSize: CGSize {
        guard let viewModel = viewModel else {
            return .zero
        }
        return CGSize(width: viewModel.collectionViewSize.width,
                      height: viewModel.messagesTotalHeight)
    }
    
    public override func prepare() {
        super.prepare()
        viewModel?.onCollectionViewPrepareLayout()
    }
    
    public override var collectionViewContentSize: CGSize {
        return messageListContentSize
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return viewModel?.layoutAttributesForMessage(at: indexPath)
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return viewModel?.layoutAttributesForMessages(in: rect)
    }
    
}
