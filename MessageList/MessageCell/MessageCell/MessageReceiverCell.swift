//
//  MessageReceiverCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import Foundation

class MessageReceiverCell: MessageUserCell {
    
    override var detailView: MessageDetailView? { _receiverDetailView }
    private lazy var _receiverDetailView: MessageDetailView? = {
        guard let bubbleModel = bubbleModel else { return nil }
        return MessageDetailView(layoutMode: .receiver,
                                 shownName: bubbleModel.shownSenderName,
                                 shownAvatar: bubbleModel.shownSenderName)
    }()
    
}
