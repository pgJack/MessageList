//
//  MessageReceiverCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import Foundation

class MessageReceiverCell: MessageUserCell {
    
    private lazy var _receiverDetailView: MessageDetailView? = {
        guard let bubbleModel = bubbleModel else { return nil }
        return MessageDetailView(layoutMode: .receiver,
                                 shownName: bubbleModel.shownSenderName,
                                 shownAvatar: bubbleModel.shownSenderName)
    }()
    override var detailView: MessageDetailView? {
        get { _receiverDetailView }
        set { _receiverDetailView = newValue }
    }
    
}
