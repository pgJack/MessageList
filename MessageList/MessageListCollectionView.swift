//
//  MessageListCollectionView.swift
//  String
//
//  Created by Noah on 2023/4/3.
//

import UIKit

class MessageListCollectionView: UICollectionView {
    
    weak var viewModel: MessageListViewModel?
        
    override func reloadData() {
        super.reloadData()
        updateVisibleItemsNow()
    }
    
    func updateVisibleItemsNow() {
        let tempBounds = bounds;
        bounds = CGRectOffset(tempBounds, 0, 0.1)
        bounds = tempBounds
        layoutSubviews()
    }
    
}
