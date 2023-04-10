//
//  BubbleView.swift
//  BMIMModule
//
//  Created by Noah on 2022/11/28.
//

import UIKit

class BubbleView: UIView {
    
    // 文本组件
    lazy var attributedTextView = MessageAttributedTextView(maxWidth: 0)
    lazy var readMoreButton = UIButton()
    
    // 时间组件
    lazy var timeView = BubbleTimeView(frame: .zero)
    
    // 子类视图组件
    lazy var contentView = UIView()
    
    var bubbleModel: BubbleModel?
    
    required init?(bubble: BubbleModel?) {
        guard let bubble = bubble else { return nil }
        bubbleModel = bubble
        super.init(frame: CGRect(origin: .zero, size: bubble.bubbleDisplaySize))
        setupBubbleSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    func setupBubbleSubviews() {
        setupTextView()
    }
    
    private func setupTextView() {
        guard let bubbleModel = bubbleModel else { return }
        guard let attributedText = bubbleModel.attributedText else { return }
        let textEdge = bubbleModel.bubbleTextEdge
        addSubview(attributedTextView)
        addSubview(timeView)
        attributedTextView.asyncRender(attributedText, isMentionedAll: bubbleModel.message.isMentionedAll, forMessageId: bubbleModel.message.messageId)
        attributedTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(textEdge.left)
            if bubbleModel.isSingleLineText {
                make.bottom.equalToSuperview().offset(-textEdge.bottom)
            } else {
                make.trailing.equalToSuperview().offset(-textEdge.right)
                make.bottom.equalTo(timeView.snp.top)
            }
        }
        var timeIcons = [UIImage]()
        if #available(iOS 13.0, *) {
            if bubbleModel.isPinned,
               let pinImage = UIImage(systemName: "star") {
                timeIcons.append(pinImage)
            }
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *) {
            if bubbleModel.isStarred,
               let starImage = UIImage(systemName: "star") {
                timeIcons.append(starImage)
            }
        } else {
            // Fallback on earlier versions
        }
        let timeBackgroundStyle = bubbleModel.timeBackgroundStyle
        let timeStackViewEdge = BubbleTimeView.stackViewEdge(style: timeBackgroundStyle)
        let timeTextHeight = CGFloat.bubble.bubbleTimeTextHeight
        timeView.update(icons: timeIcons, timeText: bubbleModel.timeText, textColor: .bubble.timeText, alignment: bubbleModel.timeAlignment, backgroundStyle: timeBackgroundStyle)
        timeView.snp.makeConstraints { make in
            make.height.equalTo(timeStackViewEdge.top + timeStackViewEdge.bottom + timeTextHeight)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    /// 响应气泡点击事件
    /// - Parameter gesture: 事件手势
    /// - Returns: 是否已响应事件，并终止事件传递
    func onTapBubble(_ gesture: UITapGestureRecognizer) -> Bool { return false }
    
    /// 响应气泡长摁事件
    /// - Parameter gesture: 事件手势
    /// - Returns: 是否已响应事件，并终止事件传递
    func onLongPressBubble(_ gesture: UILongPressGestureRecognizer) -> Bool { return false }
    
    /// 响应气泡拖动事件
    /// - Parameter gesture: 事件手势
    /// - Returns: 是否已响应事件，并终止事件传递
    func onPanBubble(_ gesture: UIPanGestureRecognizer) -> Bool { return false }
    
}
