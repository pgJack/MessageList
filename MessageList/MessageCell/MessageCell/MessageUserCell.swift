//
//  MessageUserCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import UIKit

private let kPanSafeSpace: CGFloat = 60

class MessageUserCell: MessageBaseCell {
    
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
    lazy var detailView: MessageDetailView? = {
        guard let bubbleModel = bubbleModel else { return nil }
        let view = MessageDetailView(layoutMode: bubbleModel.message.messageDirection,
                                     shownName: bubbleModel.shownSenderName,
                                     shownAvatar: bubbleModel.shownSenderName)
        baseView.setupDetailView(view)
        return view
    }()
    
    // 手势事件
    private lazy var _tapGesture: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapMessageCell))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        return tap
    }()
    
    private lazy var _longPressGesture: UILongPressGestureRecognizer = {
        let press = UILongPressGestureRecognizer.init(target: self, action: #selector(onLongPressMessageCell))
        press.numberOfTapsRequired = 0
        press.numberOfTouchesRequired = 1
        return press
    }()
    
    private lazy var _panGesutre: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(onPanMessageCell))
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        pan.delegate = self
        return pan
    }()
    
    override func willDisplayForReuse(_ bubbleModel: BubbleModel, bubbleView: BubbleView?) {
        super.willDisplayForReuse(bubbleModel, bubbleView: bubbleView)
        guard let detailView = detailView else { return }
        let message = bubbleModel.message
        detailView.update(name: "\(message.messageId)", userId: message.senderId)
        detailView.updateAvatar(url: message.senderAvatar, placeholder: message.senderPlaceholderAvatar)
        detailView.updateReactionContainerView(isHidden: !bubbleModel.shownThumbUp, size: .zero)
        detailView.updateExBubbleContainerView(isHidden: !bubbleModel.shownExBubble, size: bubbleModel.exBubbleSize)        
        var foregroundImageType = BubbleImageType.none
        var backgroundImageType = BubbleImageType.none
        if let bubbleImageInfo = bubbleModel as? BubbleImageProtocol {
            foregroundImageType = bubbleImageInfo.bubbleForegroundImageType
            backgroundImageType = bubbleImageInfo.bubbleBackgroundImageType
        }
        detailView.update(bubbleView: bubbleView, size: bubbleModel.bubbleDisplaySize, foregroundImageType: foregroundImageType, backgroundImageType: backgroundImageType)
    }

    func updateCheckBox(isHidden: Bool, status: CheckBoxStatus, animated: Bool) {
        baseView.setCheckBox(isHidden: isHidden, status: status, animated: animated)
    }
    
    func updateSentStatus(_ status: MessageSentStatus, deliveredProgress dScale: CGFloat = 0, readProgress rScale: CGFloat = 0) {
        detailView?.sentStatusView.updateStatus(status, deliveredProgress: dScale, readProgress: rScale)
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        setupGesture()
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


//MARK: Gesture Delegate
extension MessageUserCell: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        switch gestureRecognizer {
        case let gestureRecognizer as UIPanGestureRecognizer where gestureRecognizer == _panGesutre:
            return _isVaildPanAction(gestureRecognizer)
        default:
            return true
        }
    }
    
    func _isVaildPanAction(_ gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        guard let view = gestureRecognizer.view else { return true }

        // 靠近边缘不处理，以免影响右滑返回
        let isRTL = view.isRTL
        let viewWidth = view.frame.width
        let location = gestureRecognizer.location(in: view)
        let inSafeEdge = location.x < viewWidth - kPanSafeSpace && location.x > kPanSafeSpace
        guard inSafeEdge else { return false }
        
        // 垂直拖动不处理
        let velocity = gestureRecognizer.velocity(in: view)
        guard abs(velocity.x) > abs(velocity.y) else { return false }
        
        return true
    }
    
}

//MARK: Gesture
@objc extension MessageUserCell {
    
    func setupGesture() {
        addGestureRecognizer(_tapGesture)
        addGestureRecognizer(_longPressGesture)
        addGestureRecognizer(_panGesutre)
    }
    
    func onTapMessageCell(_ gesture: UITapGestureRecognizer) {
        guard let isFinished = bubbleView?.onTapBubble(gesture), !isFinished else { return }
        switch gesture.state {
        case .ended:
            /// 点击头像
            _avatarTapAction(gesture)
        default:
            break
        }
    }
    
    func onLongPressMessageCell(_ gesture: UILongPressGestureRecognizer) {
        guard let isFinished = bubbleView?.onLongPressBubble(gesture), !isFinished else { return }
        switch gesture.state {
        case .began:
            /// 长摁 @ 成员
            _avatarMentionAction(gesture)
        default:
            break
        }
    }
    
    func onPanMessageCell(_ gesture: UIPanGestureRecognizer) {
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
