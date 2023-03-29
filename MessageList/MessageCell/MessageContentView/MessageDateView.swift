//
//  MessageDateView.swift
//  BMIMModule
//
//  Created by Noah on 2022/11/28.
//

import UIKit

class MessageDateView: UIView {
    
    //MARK: 设置日期文本
    var dateText: String? {
        didSet {
            dateLabel.text = dateText
        }
    }
    
    private(set) lazy var dateBackgroundView: UIView = {
        let bgView = UIView()
        bgView.backgroundColor = .bubble.dateBackground
        bgView.layer.cornerRadius = .bubble.dateBackgroundRadius
        bgView.layer.masksToBounds = true
        addSubview(bgView)
        return bgView
    }()
    
    private(set) lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .bubble.dateText
        label.font = .bubble.date
        addSubview(label)
        dateBackgroundView.snp.makeConstraints { make in
            make.leading.equalTo(label).offset(-UIEdgeInsets.bubble.dateBackgroundEdge.left)
            make.top.equalTo(label).offset(-UIEdgeInsets.bubble.dateBackgroundEdge.top)
            make.trailing.equalTo(label).offset(UIEdgeInsets.bubble.dateBackgroundEdge.right)
            make.bottom.equalTo(label).offset(UIEdgeInsets.bubble.dateBackgroundEdge.bottom)
        }
        bringSubviewToFront(label)
        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.bubble.dateBackgroundTop + UIEdgeInsets.bubble.dateBackgroundEdge.top)
            make.centerX.equalToSuperview()
            make.height.equalTo(CGFloat.bubble.dateHeight)
        }
        return label
    }()
        
}
