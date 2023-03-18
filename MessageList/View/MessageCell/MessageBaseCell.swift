//
//  MessageBaseCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import UIKit

class MessageBaseCell: UICollectionViewCell {
    
    lazy var baseView: MessageBaseView = {
        let view = MessageBaseView()
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        return view
    }()
    var detailContainerView: UIView {
        baseView.detailContainerView
    }
    
    func updateSubviewsOnReuse(_ bubbleModel: BubbleModel?) {
        guard let bubbleModel = bubbleModel else { return }
        baseView.setUnreadLine(isHidden: !bubbleModel.shownUnreadLine)
        baseView.setMessageDate(dateText: bubbleModel.dateText)
    }
    
    func add(bubbleView: BubbleView) {
        detailContainerView.addSubview(bubbleView)
    }
    
}
