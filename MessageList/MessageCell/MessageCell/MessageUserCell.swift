//
//  MessageUserCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import UIKit

class MessageUserCell: MessageBaseCell {
    
    var bubbleView: BubbleView?
    var bubbleInfo: BubbleInfoProtocol? { bubbleModel as? BubbleInfoProtocol }
    
    lazy var referenceTipView: UIView = {
        let view = UIView()
        guard let bubbleView = bubbleView else { return view }
        view.backgroundColor = .blue
        view.alpha = 0
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.leading.equalTo(bubbleView).offset(CGFloat.bubble.referenceTipLeading)
            make.centerY.equalTo(bubbleView)
            make.size.equalTo(CGSize.bubble.referenceTipSize)
        }
        return view
    }()
    
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

extension MessageUserCell {
    
    override func onTapMessageCell(_ gesture: UITapGestureRecognizer) {
        guard let isFinished = bubbleView?.onTapBubble(gesture), !isFinished else { return }
        switch gesture.state {
        case .ended:
            /// 点击头像
            _avatarTapAction(gesture)
        default:
            break
        }
    }
    
    override func onLongPressMessageCell(_ gesture: UILongPressGestureRecognizer) {
        guard let isFinished = bubbleView?.onLongPressBubble(gesture), !isFinished else { return }
        switch gesture.state {
        case .began:
            /// 长摁 @ 成员
            _avatarMentionAction(gesture)
        default:
            break
        }
       
    }
    
    override func onPanMessageCell(_ gesture: UIPanGestureRecognizer) {
        guard let isFinished = bubbleView?.onPanBubble(gesture), !isFinished else { return }
        switch gesture.state {
        case .began:
            break
        case .changed:
            /// 开始引用
            _startReferenceAction(gesture)
        default:
            /// 结束引用
            _endReferenceAction(gesture)
        }
    }
    
}

//MARK: Avatar Action
private extension MessageUserCell {
    
    func _avatarTapAction(_ gesture: UITapGestureRecognizer) {
        guard let isValid = bubbleInfo?.canTapAvatar, isValid else { return }
        guard let userInfo = _userInfoForAvatarAction(gesture) else { return }
        let name = userInfo.userName ?? "-"
        UIView.toastText("Tap: \(name)")
    }
    
    func _avatarMentionAction(_ gesture: UILongPressGestureRecognizer) {
        guard let isValid = bubbleInfo?.canLongPressAvatarMention, isValid else { return }
        guard let userInfo = _userInfoForAvatarAction(gesture) else { return }
        let name = userInfo.userName ?? "-"
        UIView.toastText("Press: \(name)")
    }
    
    func _userInfoForAvatarAction(_ gesture: UIGestureRecognizer) -> UserInfo? {
        guard let detailView = detailView else { return nil }
        let point = gesture.location(in: detailView)
        guard detailView.avatarView.frame.contains(point) else { return nil }
        guard let message = bubbleModel?.message else { return nil }
        guard let userId = message.senderId else { return nil }
        var user = UserInfo(userId: userId)
        user.userName = message.senderName
        user.userAvatar = message.senderAvatar
        user.userPlaceholderAvatar = message.senderPlaceholderAvatar
        return user
    }
    
}


//MARK: Reference Action
private extension MessageUserCell {
 
    func _startReferenceAction(_ gesture: UIPanGestureRecognizer) {
        guard let isValid = bubbleInfo?.canPanReference, isValid else { return }
        let translation = gesture.translation(in: self)
        guard let moveView = detailView else { return }
        let tipView = referenceTipView
        let viewX = moveView.frame.minX
        let viewOffsetX = moveView.transform.tx
        guard viewX == viewOffsetX else {
            tipView.alpha = 0
            return
        }
        let maxTranslationX = moveView.frame.width / 4
        var targetX: CGFloat = 0
        var alpha: CGFloat = 0
        if moveView.semanticContentAttribute == .forceRightToLeft {
            targetX = max(min(translation.x, 0), -maxTranslationX)
            alpha = -targetX / maxTranslationX
        } else {
            targetX = min(max(translation.x, 0), maxTranslationX)
            alpha = targetX / maxTranslationX
        }
        moveView.transform = CGAffineTransformMakeTranslation(targetX, 0)
        tipView.alpha = alpha
    }
    
    func _endReferenceAction(_ gesture: UIPanGestureRecognizer) {
        guard let isValid = bubbleInfo?.canPanReference, isValid else { return }
        let tipView = referenceTipView
        guard tipView.alpha != 0 else { return }
        guard let moveView = detailView else { return }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            moveView.transform = .identity
            tipView.alpha = 0
        }
    }
    
}
