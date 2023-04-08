//
//  MessageDetailView.swift
//  BMIMModule
//
//  Created by Noah on 2022/11/28.
//

import UIKit

private enum BubbleImageHornDirection: Int {
    case none, leading, trailing
}

/// 气泡背景图尖角宽度
private let kBubbleImageHornWidth: CGFloat = 5

//MARK: 有发送人的消息显示，包括: 发送人名字, 发送人头像, 消息预览气泡, 扩展气泡(e.g 翻译), Reaction(消息点赞), 消息状态
class MessageDetailView: UIView {
    
    private(set) lazy var nameView = UserNameView()
    
    private(set) lazy var avatarView = UserAvatarView()
    
    private lazy var bubbleForegroundImageView: UIImageView = {
        let view = UIImageView()
        insertSubview(view, aboveSubview: bubbleContainerView)
        view.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(bubbleBackgroundImageView)
        }
        if hornDirection == .leading {
            view.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        return view
    }()
    private(set) lazy var bubbleContainerView = UIView()
    private lazy var bubbleBackgroundImageView: UIImageView = {
        let view = UIImageView()
        insertSubview(view, belowSubview: bubbleContainerView)
        view.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(bubbleContainerView)
        }
        if hornDirection == .leading {
            view.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        return view
    }()
        
    private(set) lazy var sentStatusView: MessageSentStatusView = {
        let view = MessageSentStatusView(frame: CGRect(origin: .zero, size: .bubble.sentStatusSize))
        addSubview(view)
        view.snp.makeConstraints { make in
            make.bottom.equalTo(bubbleContainerView.snp.bottom)
            make.trailing.equalTo(bubbleContainerView.snp.leading).offset(-CGFloat.bubble.sentStatusBubbleSpace)
            make.size.equalTo(CGSize.bubble.sentStatusSize)
        }
        return view
    }()
        
    private(set) lazy var reactionContainerView: UIView = {
        let view = UIView()
        addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalTo(bubbleContainerView.snp.bottom).offset(CGFloat.bubble.reactionTop)
            make.size.equalTo(reactionSize)
            // 根据布局模式，设置约束
            switch layoutMode {
            case .send:
                make.leading.lessThanOrEqualTo(bubbleContainerView.snp.leading)
                make.trailing.lessThanOrEqualTo(bubbleContainerView.snp.trailing)
            case .receive:
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
        view.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-UIEdgeInsets.bubble.contentEdge.bottom)
            make.size.equalTo(exBubbleSize)
            // 根据布局模式，设置约束
            switch layoutMode {
            case .send:
                make.trailing.equalTo(bubbleContainerView.snp.trailing).offset(-CGFloat.bubble.exBubbleOffset)
            case .receive:
                make.leading.equalTo(bubbleContainerView.snp.leading).offset(CGFloat.bubble.exBubbleOffset)
            default :
                break
            }
        }
        return view
    }()
    
    // 布局方式，未布局、发送布局、接收布局
    private var layoutMode = MessageDirection.send
    
    // 气泡视图尖角方向，与 RTL 有关，需满足以下条件后使用
    // 1. 已添加到父控件后
    // 2. 设置完背景图类型
    // 3. 设置完布局方式
    private var hornDirection: BubbleImageHornDirection {
        guard backgroundImageType != .none else { return .none }
        /// 默认为箭头朝右，接收端或者阿语模式满足其中一个，箭头朝左
        let isForSender = layoutMode == .send
        let isLTR = !bubbleContainerView.isRTL
        return isForSender == isLTR ? .trailing : .leading
    }
    
    // 消息气泡图片类型
    /// 在气泡上层，一般为蒙层
    private var foregroundImageType = BubbleImageType.none
    /// 在气泡下层，一般为底色
    private var backgroundImageType = BubbleImageType.none
    
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
    private var bubbleSize = CGSize.bubble.bubbleEmptySize
    
    // Reaction 尺寸
    private var isHiddenReaction = true
    private var reactionSize = CGSize.bubble.reactionEmptySize
    
    // 扩展气泡的尺寸
    private var isHiddenExBubble = true
    private var exBubbleSize = CGSize.bubble.exBubbleEmptySize
    
    convenience init(layoutMode: MessageDirection, shownName: Bool, shownAvatar: Bool) {
        self.init(frame: .zero)
        self.layoutMode = layoutMode
        self.backgroundImageType = backgroundImageType
        self.isHiddenName = !shownName
        self.isHiddenAvatar = !shownAvatar
        _setupNameView()
        _setupAvatarView()
        _setupBubbleView()
    }

    private func _setupNameView() {
        guard !isHiddenName else { return }
        addSubview(nameView)
        let nameViewOffset = CGFloat.bubble.nameAvatarSpace + avatarSize.width
        nameView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.bubble.nameTop)
            make.height.equalTo(nameHeight)
            make.width.lessThanOrEqualToSuperview().multipliedBy(CGFloat.bubble.maxWidthRatio)
            // 根据布局模式，设置约束
            switch layoutMode {
            case .send:
                make.trailing.equalToSuperview()
                    .offset(-nameViewOffset)
            case .receive:
                make.leading.equalToSuperview()
                    .offset(nameViewOffset)
            default :
                break
            }
        }
    }
    
    private func _setupAvatarView() {
        guard !isHiddenAvatar else { return }
        addSubview(avatarView)
        avatarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.bubble.avatarTop)
            make.width.equalTo(avatarSize.width)
            make.height.equalTo(avatarSize.height)
            // 根据布局模式，设置约束
            switch layoutMode {
            case .send:
                make.trailing.equalToSuperview()
            case .receive:
                make.leading.equalToSuperview()
            default :
                break
            }
        }
    }
    
    private func _setupBubbleView() {
        addSubview(bubbleContainerView)
        bubbleContainerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(nameMaxY)
            make.size.equalTo(bubbleSize)
            // 根据布局模式，设置约束
            switch layoutMode {
            case .send:
                make.trailing.equalToSuperview().offset(-avatarMaxX)
            case .receive:
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
    func update(name: String?, userId uid: String?) {
        guard !isHiddenName else { return }
        nameView.update(name: name, userId: uid)
    }
    
    // 更新头像
    func updateAvatar(url: String?, placeholder: String?) {
        guard !isHiddenAvatar else { return }
        var image: UIImage?
        if let placeholder = placeholder {
            image = UIImage(named: placeholder)
        }
        avatarView.updateAvatar(url: url, placeholder: image)
    }
    
    // 更新消息气泡
    func update(bubbleView: UIView?,
                size: CGSize,
                foregroundImageType: BubbleImageType,
                backgroundImageType: BubbleImageType) {
        var containerSize = CGSize.bubble.bubbleEmptySize
        if let bubbleView = bubbleView {
            bubbleContainerView.addSubview(bubbleView)
            containerSize = size
        }
        var extraWidth: CGFloat = 0
        if backgroundImageType != .none {
            extraWidth = kBubbleImageHornWidth
        }
        containerSize.width += extraWidth
        _updateBubbleContainerView(size: containerSize)
        _updateBubbleForegroundImage(type: foregroundImageType)
        _updateBubbleBackgroundImage(type: backgroundImageType)
        if extraWidth > 0,
           hornDirection == .leading {
            bubbleView?.transform = CGAffineTransform(translationX: extraWidth, y: 0)
        } else {
            bubbleView?.transform = .identity
        }
    }
    private func _updateBubbleContainerView(size: CGSize) {
        guard bubbleSize != size else { return }
        bubbleSize = size
        bubbleContainerView.snp.updateConstraints { make in
            make.size.equalTo(size)
        }
    }
    private func _updateBubbleBackgroundImage(type: BubbleImageType) {
        guard backgroundImageType != type else { return }
        backgroundImageType = type
        bubbleBackgroundImageView.image = _bubbleImage(for: type)
    }
    private func _updateBubbleForegroundImage(type: BubbleImageType) {
        guard foregroundImageType != type else { return }
        foregroundImageType = type
        bubbleForegroundImageView.image = _bubbleImage(for: type)
    }
    private func _bubbleImage(for type: BubbleImageType) -> UIImage? {
        guard var image = UIImage.bubble.bubbleImage(type) else { return nil }
        let height = image.size.height
        let width = image.size.width
        /// 图片拉伸方式，取中间区域渲染
        image = image.resizableImage(withCapInsets: .init(top: height / 2, left: width / 2, bottom: height / 2, right: width / 2))
        return image
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

