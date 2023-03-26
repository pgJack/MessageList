//
//  MessageUnreadLineView.swift
//  String
//
//  Created by Noah on 2023/3/18.
//

import UIKit

class MessageUnreadLineView: UIView {
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard superview != nil, unreadLabel.superview == nil else {
            return
        }
        addSubview(unreadLabel)
        unreadLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    lazy var unreadLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "———— Unread Messages —————"
        return label
    }()
    
}
