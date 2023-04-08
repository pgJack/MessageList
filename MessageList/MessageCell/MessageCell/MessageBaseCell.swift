//
//  MessageBaseCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import UIKit

class MessageBaseCell: UICollectionViewCell {
    
    var bubbleModel: BubbleModel?
    var bubbleView: BubbleView?
    
    lazy var baseView: MessageBaseView = {
        let view = MessageBaseView()
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        return view
    }()
        
    func willDisplayForReuse(_ bubbleModel: BubbleModel, bubbleView: BubbleView?) {
        self.bubbleModel = bubbleModel
        self.bubbleView = bubbleView
        baseView.setUnreadLine(isHidden: !bubbleModel.shownUnreadLine)
        baseView.setMessageDate(dateText: bubbleModel.dateText)
    }
    
    func didEndDisplayingForReuse() {
        bubbleModel = nil
        bubbleView?.removeFromSuperview()
        bubbleView = nil
    }
    
}
