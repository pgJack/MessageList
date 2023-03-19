//
//  MessageUserCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import Foundation

class MessageUserCell: MessageBaseCell {
    
    // 消息视图：发送人信息，消息内容，消息点赞，扩展消息
    private(set) lazy var detailView: MessageDetailView? = nil
    
    override func updateSubviewsOnReuse(_ bubbleModel: BubbleModel) {
        super.updateSubviewsOnReuse(bubbleModel)
        guard let detailView = detailView else { return }
        let message = bubbleModel.message
        detailView.update(name: message.senderName, userId: message.senderId)
        detailView.updateAvatar(url: message.senderAvatar, placeholder: message.senderPlaceholderAvatar)
        detailView.updateBubbleContainerView(isHidden: false, size: bubbleModel.bubbleSize)
        detailView.updateReactionContainerView(isHidden: !bubbleModel.shownThumbUp, size: .zero)
        detailView.updateExBubbleContainerView(isHidden: !bubbleModel.shownExBubble, size: bubbleModel.exBubbleSize)
    }
    
    override func add(bubbleView: BubbleView) {
        detailView?.bubbleContainerView.addSubview(bubbleView)
    }
    
    func setCheckBox(isHidden: Bool, status: CheckBoxStatus, animated: Bool) {
        baseView.setCheckBox(isHidden: isHidden, status: status, animated: animated)
    }
    
}
