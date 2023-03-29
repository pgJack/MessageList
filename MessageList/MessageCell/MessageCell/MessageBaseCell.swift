//
//  MessageBaseCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import UIKit

class MessageBaseCell: UICollectionViewCell {
    
    var bubbleModel: BubbleModel?
    
    lazy var baseView: MessageBaseView = {
        let view = MessageBaseView()
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        return view
    }()
    
    func updateSubviewsOnReuse(_ bubbleModel: BubbleModel) {
        self.bubbleModel = bubbleModel
        baseView.setUnreadLine(isHidden: !bubbleModel.shownUnreadLine)
        baseView.setMessageDate(dateText: bubbleModel.dateText)
    }
    
}
