//
//  UserNameView.swift
//  BMIMModule
//
//  Created by Noah on 2022/11/28.
//

import UIKit

class UserNameView: UIView {
    
    func update(name: String?, userId uid: String?) {
        nameLabel.text = name
        nameLabel.textColor = .bubble.nameColor(forUserId: uid)
    }
    
    private(set) lazy var nameLabel: UILabel = {
        let lbl = UILabel(font: .bubble.senderName)
        addSubview(lbl)
        lbl.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
        }
        return lbl
    }()
    
}
