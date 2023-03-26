//
//  MessageUserCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import Foundation

class MessageUserCell: MessageBaseCell {
    
    var bubbleView: BubbleView? {
        didSet {
            guard let detailView = detailView() else { return }
            baseView.detailContainerView.addSubview(detailView)
            detailView.snp.makeConstraints { make in
                make.leading.trailing.top.bottom.equalToSuperview()
            }
        }
    }
    
    // 消息视图：发送人信息，消息内容，消息点赞，扩展消息
    func detailView() -> MessageDetailView? { nil }
    
    override func updateSubviewsOnReuse(_ bubbleModel: BubbleModel) {
        super.updateSubviewsOnReuse(bubbleModel)
        guard let detailView = detailView() else { return }
        let message = bubbleModel.message
        detailView.update(name: message.senderName, userId: message.senderId)
        detailView.updateAvatar(url: message.senderAvatar, placeholder: message.senderPlaceholderAvatar)
        detailView.updateBubbleContainerView(size: bubbleModel.bubbleContentSize)
        detailView.updateReactionContainerView(isHidden: !bubbleModel.shownThumbUp, size: .zero)
        detailView.updateExBubbleContainerView(isHidden: !bubbleModel.shownExBubble, size: bubbleModel.exBubbleSize)
    }
    
    func addBubbleView(_ bubbleView: BubbleView?) {
        guard let detailView = detailView() else { return }
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