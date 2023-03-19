//
//  MessageSenderCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import Foundation

class MessageSenderCell: MessageUserCell {
    
    private lazy var _senderDetailView: MessageDetailView? = {
        guard let bubbleModel = bubbleModel else { return nil }
        return MessageDetailView(layoutMode: .sender,
                                 shownName: bubbleModel.shownSenderName,
                                 shownAvatar: bubbleModel.shownSenderName)
    }()
    override var detailView: MessageDetailView? {
        get { _senderDetailView }
        set { _senderDetailView = newValue }
    }
    
    override func updateSubviewsOnReuse(_ bubbleModel: BubbleModel) {
        super.updateSubviewsOnReuse(bubbleModel)
    }
    
    func setSentStatus(_ status: MessageSentStatus, deliveredProgress dScale: CGFloat = 0, readProgress rScale: CGFloat = 0) {
        detailView?.sentStatusView.updateStatus(status, deliveredProgress: dScale, readProgress: rScale)
    }
    
}
