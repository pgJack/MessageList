//
//  TextBubbleView.swift
//  String
//
//  Created by Noah on 2023/3/24.
//

import UIKit

class TextBubbleView: BubbleView {
    
    lazy var attributedTextView = MessageAttributedTextView(maxWidth: 0)
    
    override var bubbleModel: BubbleModel? {
        didSet {
            guard let textBubble = bubbleModel as? TextBubbleModel else {
                attributedTextView.attributedText = nil
                return
            }
            attributedTextView.asyncRender(textBubble.attributedText, isMentionedAll: textBubble.message.isMentionedAll, forMessageId: textBubble.message.messageId)
        }
    }
    
    override func setupBubbleSubviews() {
        super.setupBubbleSubviews()
        addSubview(attributedTextView)
        attributedTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(TextBubbleModel.textEdge.left)
            make.trailing.equalToSuperview().offset(-TextBubbleModel.textEdge.right)
            make.top.equalToSuperview().offset(TextBubbleModel.textEdge.top)
        }
    }
    
}
