//
//  MessageDetailView.swift
//  BMIMModule
//
//  Created by Noah on 2022/11/28.
//

import UIKit

enum MessageDetailLayoutMode: Int {
    case none, sender, receiver
}

//MARK: 有发送人的消息显示，包括: 发送人名字, 发送人头像, 消息预览气泡, 扩展气泡(e.g 翻译), Reaction(消息点赞), 消息状态

class MessageDetailView: UIView {
    
    private(set) lazy var nameView = UserNameView()
    
    private(set) lazy var avatarView = UserAvatarView()
        
    private(set) lazy var sentStatusView = MessageSentStatusView(frame: CGRect(origin: .zero, size: .bubble.sentStatusSize))
    
    private(set) lazy var reactionContainerView = UIView()
    
    private(set) lazy var bubbleContainerView = UIView()
    
    private(set) lazy var exBubbleContainerView = UIView()
    
    // 布局方式，未布局、发送布局、接收布局
    var layoutMode = MessageDetailLayoutMode.none {
        didSet {
            if oldValue != layoutMode {
                refreshSubviewsLayout()
                layoutIfNeeded()
            }
        }
    }
    
    // 标记是否显示头像
    private var isDisplayedAvatar = false
    private var avatarSize: CGSize {
        isDisplayedAvatar
        ? .bubble.avatarViewSize
        : .bubble.avatarViewHiddenSize
    }
    
    // 标记是否显示名字
    private var isDisplayedName = false
    private var nameHeight: CGFloat {
        isDisplayedName
        ? .bubble.nameHeight
        : .bubble.nameHiddenHeight
    }
    
    // 气泡的尺寸
    private var bubbleSize = CGSize.bubble.bubbleEmptySize
    
    // Reaction 尺寸
    private var reactionSize = CGSize.bubble.reactionEmptySize
    
    // 扩展气泡的尺寸
    private var exBubbleSize = CGSize.bubble.exBubbleEmptySize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        addSubviews()
    }

}

//MARK: Subview Control
extension MessageDetailView {
    
    func setAvatarDisplayed(_ isDisplayed: Bool, animated: Bool) {
        guard isDisplayedAvatar != isDisplayed else {
            return
        }
        isDisplayedAvatar = isDisplayed
        avatarView.snp.updateConstraints { make in
            make.width.equalTo(avatarSize.width)
            make.height.equalTo(avatarSize.height)
        }
        if isDisplayed {
            avatarView.isHidden = false
            layoutIfNeeded(animated: animated)
        } else {
            layoutIfNeeded(animated: animated) {
                self.avatarView.isHidden = true
            }
        }
    }
    
    func setNameDisplayed(_ isDisplayed: Bool, animated: Bool) {
        guard isDisplayedName != isDisplayed else {
            return
        }
        isDisplayedName = isDisplayed
        nameView.snp.updateConstraints { make in
            make.height.equalTo(nameHeight)
        }
        if isDisplayed {
            nameView.isHidden = false
            layoutIfNeeded(animated: animated)
        } else {
            layoutIfNeeded(animated: animated) {
                self.nameView.isHidden = true
            }
        }
    }
    
    // 更新名字
    func update(name: String, userId uid: String) {
        nameView.update(name: name, userId: uid)
    }
    
    // 更新头像
    func updateAvatar(image: UIImage?) {
        avatarView.updateAvatar(url: nil, placeholder: image)
    }
    func updateAvatar(url: String?, placeholder: UIImage?) {
        avatarView.updateAvatar(url: url, placeholder: placeholder)
    }
    
    // 更新气泡尺寸
    func updateBubbleView(isHidden: Bool, size: CGSize) {
        var targetSize = size
        // 隐藏或者尺寸为0, 则隐藏
        if isHidden || size == .zero {
            targetSize = .bubble.bubbleEmptySize
            bubbleContainerView.isHidden = true
        } else {
            bubbleContainerView.isHidden = false
        }
        // 尺寸与标记不同, 则刷新
        guard !bubbleSize.equalTo(targetSize) else {
            return
        }
        bubbleSize = targetSize
        bubbleContainerView.snp.updateConstraints { make in
            make.width.equalTo(bubbleSize.width)
            make.height.equalTo(bubbleSize.height)
        }
        layoutIfNeeded()
    }
    
    // 更新消息点赞视图尺寸
    func updatereactionContainerView(isHidden: Bool, size: CGSize) {
        var targetSize = size
        // 隐藏或者尺寸为0, 则隐藏
        if isHidden || size == .zero {
            targetSize = .bubble.reactionEmptySize
            reactionContainerView.isHidden = true
        } else {
            reactionContainerView.isHidden = false
        }
        // 尺寸与标记不同, 则刷新
        guard !reactionSize.equalTo(targetSize) else {
            return
        }
        reactionSize = targetSize
        reactionContainerView.snp.updateConstraints { make in
            make.width.equalTo(reactionSize.width)
            make.height.equalTo(reactionSize.height)
        }
        layoutIfNeeded()
    }
    
    // 更新扩展气泡尺寸
    func updateexBubbleContainerView(isHidden: Bool, size: CGSize) {
        var targetSize = size
        // 隐藏或者尺寸为0, 则隐藏
        if isHidden || size == .zero {
            targetSize = .bubble.exBubbleEmptySize
            exBubbleContainerView.isHidden = true
        } else {
            exBubbleContainerView.isHidden = false
        }
        // 尺寸与标记不同, 则刷新
        guard !exBubbleSize.equalTo(targetSize) else {
            return
        }
        exBubbleSize = targetSize
        exBubbleContainerView.snp.updateConstraints { make in
            make.width.equalTo(exBubbleSize.width)
            make.height.equalTo(exBubbleSize.height)
        }
        layoutIfNeeded()
    }
    
}

//MARK: Subview Layout
extension MessageDetailView {
        
    private func refreshSubviewsLayout() {
        refreshAvatarLayout()
        refreshNameLayout()
        refreshBubbleLayout()
        refreshStatusLayout()
        refreshReactionLayout()
        refreshExbubbleLayout()
    }
    
    private func refreshAvatarLayout() {
        guard layoutMode != .none else {
            avatarView.snp.removeConstraints()
            return
        }
        avatarView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.bubble.avatarTop)
            make.width.equalTo(avatarSize.width)
            make.height.equalTo(avatarSize.height)
            // 根据布局模式，设置约束
            switch layoutMode {
            case .sender:
                make.trailing.equalToSuperview()
            case .receiver:
                make.leading.equalToSuperview()
            default :
                break
            }
        }
    }
    
    private func refreshNameLayout() {
        guard layoutMode != .none else {
            nameView.snp.removeConstraints()
            return
        }
        nameView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.bubble.nameTop)
            make.height.equalTo(nameHeight)
            make.width.equalToSuperview().multipliedBy(CGFloat.bubble.maxWidthRatio)
            // 根据布局模式，设置约束
            switch layoutMode {
            case .sender:
                make.trailing.equalTo(avatarView.snp.leading)
                    .offset(-CGFloat.bubble.nameAvatarSpace)
            case .receiver:
                make.leading.equalTo(avatarView.snp.trailing)
                    .offset(CGFloat.bubble.nameAvatarSpace)
            default :
                break
            }
        }
    }
    
    private func refreshBubbleLayout() {
        guard layoutMode != .none else {
            bubbleContainerView.snp.removeConstraints()
            return
        }
        bubbleContainerView.snp.remakeConstraints { make in
            make.top.equalTo(nameView.snp.bottom)
            make.width.equalTo(bubbleSize.width)
            make.height.equalTo(bubbleSize.height)
            // 根据布局模式，设置约束
            switch layoutMode {
            case .sender:
                make.trailing.equalTo(avatarView.snp.leading)
                    .offset(-CGFloat.bubble.bubbleAvatarSpace)
            case .receiver:
                make.leading.equalTo(avatarView.snp.trailing)
                    .offset(CGFloat.bubble.bubbleAvatarSpace)
            default :
                break
            }
        }
    }
    
    private func refreshStatusLayout() {
        sentStatusView.snp.remakeConstraints { make in
            make.bottom.equalTo(bubbleContainerView.snp.bottom)
            // 根据布局模式，设置约束
            switch layoutMode {
            case .sender:
                make.trailing.equalTo(bubbleContainerView.snp.leading).offset(-CGFloat.bubble.sentStatusBubbleSpace)
            case .receiver:
                make.leading.equalTo(bubbleContainerView.snp.trailing).offset(CGFloat.bubble.sentStatusBubbleSpace)
            default :
                break
            }
            make.size.equalTo(CGSize.bubble.sentStatusSize)
        }
    }
    
    private func refreshReactionLayout() {
        guard layoutMode != .none else {
            reactionContainerView.snp.removeConstraints()
            return
        }
        reactionContainerView.snp.remakeConstraints { make in
            make.top.equalTo(bubbleContainerView.snp.bottom).offset(CGFloat.bubble.reactionTop)
            make.width.equalTo(reactionSize.width)
            make.height.equalTo(reactionSize.height)
            // 根据布局模式，设置约束
            switch layoutMode {
            case .sender:
                make.leading.lessThanOrEqualTo(bubbleContainerView.snp.leading)
                make.trailing.lessThanOrEqualTo(bubbleContainerView.snp.trailing)
            case .receiver:
                make.leading.greaterThanOrEqualTo(bubbleContainerView.snp.leading)
                make.trailing.greaterThanOrEqualTo(bubbleContainerView.snp.trailing)
            default :
                break
            }
        }
    }
    
    private func refreshExbubbleLayout() {
        guard layoutMode != .none else {
            exBubbleContainerView.snp.removeConstraints()
            return
        }
        exBubbleContainerView.snp.remakeConstraints { make in
            make.top.equalTo(reactionContainerView.snp.bottom).offset(CGFloat.bubble.exBubbleTop)
            make.width.equalTo(exBubbleSize.width)
            make.height.equalTo(exBubbleSize.height)
            // 根据布局模式，设置约束
            switch layoutMode {
            case .sender:
                make.trailing.equalTo(bubbleContainerView.snp.trailing).offset(-CGFloat.bubble.exBubbleOffset)
            case .receiver:
                make.leading.equalTo(bubbleContainerView.snp.leading).offset(CGFloat.bubble.exBubbleOffset)
            default :
                break
            }
        }
    }
    
}

//MARK: Setup Subview
extension MessageDetailView {
    
    private func addSubviews() {
        nameView.isHidden = true
        avatarView.isHidden = true
        sentStatusView.isHidden = true
        reactionContainerView.isHidden = true
        exBubbleContainerView.isHidden = true
        
        addSubview(nameView)
        addSubview(avatarView)
        addSubview(sentStatusView)
        addSubview(bubbleContainerView)
        addSubview(reactionContainerView)
        addSubview(exBubbleContainerView)
    }
    
}

