//
//  MessageCellRegister.swift
//  String
//
//  Created by Noah on 2023/3/19.
//

import UIKit

extension String {
    static let cellType = MessageCellRegister.self
}

struct MessageCellRegister {
    
    static let placeholder = "bm_empty_msg_cell"
    static let unknown = "bm_unknown_msg_cell"
    static let tip = "bm_tip_msg_cell"
    static let sender = "bm_rev_msg_cell"
    static let receiver = "bm_send_msg_cell"
        
    static func registerCells(for collectionView: UICollectionView) {
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: placeholder)
        collectionView.register(MessageUnknownCell.self, forCellWithReuseIdentifier: unknown)
        collectionView.register(MessageTipCell.self, forCellWithReuseIdentifier: tip)
        collectionView.register(MessageUserCell.self, forCellWithReuseIdentifier: sender)
        collectionView.register(MessageUserCell.self, forCellWithReuseIdentifier: receiver)
    }
    
}
