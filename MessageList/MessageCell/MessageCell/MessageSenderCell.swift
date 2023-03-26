//
//  MessageSenderCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import Foundation

class MessageSenderCell: MessageUserCell {
    
    override func detailView() -> MessageDetailView? { _senderDetailView }
    private lazy var _senderDetailView: MessageDetailView? = {
        guard let bubbleModel = bubbleModel else { return nil }
        return MessageDetailView(layoutMode: .sender,
                                 shownName: bubbleModel.shownSenderName,
                                 shownAvatar: bubbleModel.shownSenderName)
    }()
    
    func updateSentStatus(_ status: MessageSentStatus, deliveredProgress dScale: CGFloat = 0, readProgress rScale: CGFloat = 0) {
        _senderDetailView?.sentStatusView.updateStatus(status, deliveredProgress: dScale, readProgress: rScale)
    }
    
}
