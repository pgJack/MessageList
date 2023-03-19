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
    
    private(set) lazy var bubbleContainerView = UIView()
        
    private(set) lazy var sentStatusView: MessageSentStatusView = {
        let view = MessageSentStatusView(frame: CGRect(origin: .zero, size: .bubble.sentStatusSize))
        addSubview(view)
        view.snp.remakeConstraints { make in
            make.bottom.equalTo(bubbleContainerView.snp.bottom)
            make.trailing.equalTo(bubbleContainerView.snp.leading).offset(-CGFloat.bubble.sentStatusBubbleSpace)
            make.size.equalTo(CGSize.bubble.sentStatusSize)
        }
        return view
    }()
        
    private(set) lazy var reactionContainerView: UIView = {
        let view = UIView()
        addSubview(view)
        view.snp.remakeConstraints { make in
            make.top.equalTo(bubbleContainerView.snp.bottom).offset(CGFloat.bubble.reactionTop)
            make.size.equalTo(reactionSize)
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
        return view
    }()
        
    private(set) lazy var exBubbleContainerView: UIView = {
        let view = UIView()
        addSubview(view)
        view.snp.remakeConstraints { make in
            make.top.equalTo(reactionContainerView.snp.bottom).offset(CGFloat.bubble.exBubbleTop)
            make.size.equalTo(exBubbleSize)
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
        return view
    }()
    
    // 布局方式，未布局、发送布局、接收布局
    private var layoutMode = MessageDetailLayoutMode.none
    
    // 标记是否显示头像
    private var isHiddenAvatar = true
    private var avatarSize: CGSize {
        isHiddenAvatar
        ? .bubble.avatarViewHiddenSize
        : .bubble.avatarViewSize
    }
    private var avatarMaxX: CGFloat {
        avatarSize.width
    }
    
    // 标记是否显示名字
    private var isHiddenName = true
    private var nameMaxY: CGFloat {
        .bubble.nameTop + nameHeight
    }
    private var nameHeight: CGFloat {
        isHiddenName
        ? .bubble.nameHiddenHeight
        : .bubble.nameHeight
    }
    
    // 气泡的尺寸
    private var isHiddenBubble = false
    private var bubbleSize = CGSize.bubble.bubbleEmptySize
    
    // Reaction 尺寸
    private var isHiddenReaction = true
    private var reactionSize = CGSize.bubble.reactionEmptySize
    
    // 扩展气泡的尺寸
    private var isHiddenExBubble = true
    private var exBubbleSize = CGSize.bubble.exBubbleEmptySize
    
    convenience init(layoutMode: MessageDetailLayoutMode, shownName: Bool, shownAvatar: Bool) {
        self.init(frame: .zero)
        self.layoutMode = layoutMode
        self.isHiddenName = shownName
        self.isHiddenAvatar = shownAvatar
        setupNameView()
        setupAvatarView()
        setupBubbleView()
    }
    
    func setupNameView() {
        guard isHiddenName else { return }
        addSubview(nameView)
        let nameViewOffset = CGFloat.bubble.nameAvatarSpace + avatarSize.width
        nameView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.bubble.nameTop)
            make.height.equalTo(nameHeight)
            make.width.equalToSuperview().multipliedBy(CGFloat.bubble.maxWidthRatio)
            // 根据布局模式，设置约束
            switch layoutMode {
            case .sender:
                make.trailing.equalToSuperview()
                    .offset(-nameViewOffset)
            case .receiver:
                make.leading.equalToSuperview()
                    .offset(nameViewOffset)
            default :
                break
            }
        }
    }
    
    func setupAvatarView() {
        guard isHiddenAvatar else { return }
        addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
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
    
    func setupBubbleView() {
        addSubview(bubbleContainerView)
        bubbleContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(nameMaxY)
            make.size.equalTo(bubbleSize)
            // 根据布局模式，设置约束
            switch layoutMode {
            case .sender:
                make.trailing.equalToSuperview().offset(-avatarMaxX)
            case .receiver:
                make.leading.equalToSuperview().offset(avatarMaxX)
            default :
                break
            }
        }
    }

}

//MARK: Subview Control
extension MessageDetailView {
    
    // 更新名字
    func update(name: String?, userId uid: String) {
        nameView.update(name: name, userId: uid)
    }
    
    // 更新头像
    func updateAvatar(url: String?, placeholder: String?) {
        var image: UIImage?
        if let placeholder = placeholder {
            image = UIImage(named: placeholder)
        }
        avatarView.updateAvatar(url: url, placeholder: image)
    }
    
    // 更新气泡尺寸
    func updateBubbleContainerView(isHidden: Bool, size: CGSize = .bubble.bubbleEmptySize) {
        if isHiddenBubble != isHidden {
            isHiddenBubble = isHidden
            bubbleContainerView.isHidden = isHidden
        }
        let realSize = isHiddenBubble ? .bubble.bubbleEmptySize : size
        if bubbleSize != realSize {
            bubbleSize = realSize
            bubbleContainerView.snp.updateConstraints { make in
                make.size.equalTo(realSize)
            }
        }
    }
    
    // 更新消息点赞视图
    func updateReactionContainerView(isHidden: Bool, size: CGSize = .bubble.reactionEmptySize) {
        if isHiddenReaction != isHidden {
            isHiddenReaction = isHidden
            reactionContainerView.isHidden = isHidden
        }
        let realSize = isHiddenReaction ? .bubble.reactionEmptySize : size
        if reactionSize != realSize {
            reactionSize = realSize
            reactionContainerView.snp.updateConstraints { make in
                make.size.equalTo(realSize)
            }
        }
    }
    
    // 更新扩展气泡尺寸
    func updateExBubbleContainerView(isHidden: Bool, size: CGSize = .bubble.exBubbleEmptySize) {
        if isHiddenExBubble != isHidden {
            isHiddenExBubble = isHidden
            exBubbleContainerView.isHidden = isHidden
        }
        let realSize = isHiddenExBubble ? .bubble.exBubbleEmptySize : size
        if exBubbleSize != realSize {
            exBubbleSize = realSize
            exBubbleContainerView.snp.updateConstraints { make in
                make.size.equalTo(realSize)
            }
        }
    }
    
}

