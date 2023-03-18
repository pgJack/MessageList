//
//  MessageUnreadLineView.swift
//  String
//
//  Created by Noah on 2023/3/18.
//

import UIKit

class MessageUnreadLineView: UIView {
    
    lazy var unreadLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = "———— Unread Messages ————"
        addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return label
    }()
    
}
