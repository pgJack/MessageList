//
//  MessageUserCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import Foundation

class MessageUserCell: MessageBaseCell {
    
    var bubbleView: BubbleView?
    
    // 消息视图：发送人信息，消息内容，消息点赞，扩展消息
    var detailView: MessageDetailView? { nil }
    
    override func updateSubviewsOnReuse(_ bubbleModel: BubbleModel) {
        super.updateSubviewsOnReuse(bubbleModel)
        guard let detailView = detailView else { return }
        if detailView.superview == nil {
            baseView.setupDetailView(detailView)
        }
        let message = bubbleModel.message
        detailView.update(name: "\(message.messageId)", userId: message.senderId)
        detailView.updateAvatar(url: message.senderAvatar, placeholder: message.senderPlaceholderAvatar)
        detailView.updateBubbleContainerView(size: bubbleModel.bubbleContentSize)
        detailView.updateReactionContainerView(isHidden: !bubbleModel.shownThumbUp, size: .zero)
        detailView.updateExBubbleContainerView(isHidden: !bubbleModel.shownExBubble, size: bubbleModel.exBubbleSize)
    }
    
    func addBubbleView(_ bubbleView: BubbleView?) {
        guard let detailView = detailView else { return }
        guard let bubbleView = bubbleView else { return }
        self.bubbleView = bubbleView
        detailView.bubbleContainerView.addSubview(bubbleView)
    }
    
    func removeBubbleView() {
        bubbleView?.removeFromSuperview()
    }
    
    func updateCheckBox(isHidden: Bool, status: CheckBoxStatus, animated: Bool) {
        baseView.setCheckBox(isHidden: isHidden, status: status, animated: animated)
    }
    
}
