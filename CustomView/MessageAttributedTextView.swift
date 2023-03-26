//
//  MessageAttributedTextView.swift
//  String
//
//  Created by Noah on 2023/3/25.
//

import UIKit

public class MessageAttributedTextView: UITextView {
    
    public var messageId: Int = 0
    public var tapAction: ((NSAttributedString?) -> Void)?
    private let clickTapGesture = UITapGestureRecognizer()
    
    public convenience init(maxWidth: CGFloat) {
        self.init(frame: CGRect(x: 0, y: 0, width: maxWidth, height: 0), textContainer: nil)
        configTextView()
    }
    
    public override var frame: CGRect {
        set {
            let x = newValue.origin.x.isNaN ? 0 : newValue.origin.x
            let y = newValue.origin.y.isNaN ? 0 : newValue.origin.y
            let w = newValue.size.width.isNaN ? 0 : newValue.size.width
            let h = newValue.size.height.isNaN ? 0 : newValue.size.height
            super.frame = CGRect(x: x, y: y, width: w, height: h)
        }
        get {
            super.frame
        }
    }
    
    open func configTextView() {
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
        /// 链接颜色需要单独设置
        linkTextAttributes = [.foregroundColor:UIColor.bmTheme.linkTextAttributes, .underlineStyle: NSUnderlineStyle.single.rawValue, .underlineColor: UIColor.bmTheme.linkTextAttributes]
        backgroundColor = .clear
        isSelectable = false
        isScrollEnabled = false
        isEditable = false
        
//        /// 请勿删除，iOS 16.0 将 TextKit 2 回退到 TextKit 1 的方法，具体可以看 layoutManager 的官方注释
//        let _ = layoutManager
        
        clickTapGesture.addTarget(self, action: #selector(didClickInteractLink(_:)))
        self.addGestureRecognizer(clickTapGesture)
    }
    
    public func asyncRender(_ attributedText: NSAttributedString?, isMentionedAll: Bool, forMessageId messageId: Int) {
        guard let attributedText = attributedText else { return }
        self.messageId = messageId
        DispatchQueue.global().async {
            var highlightedText: NSAttributedString? = attributedText
            if isMentionedAll {
                highlightedText = BubbleAttributedTextUtil.highlightMentionedAll(highlightedText)
            }
            highlightedText = BubbleAttributedTextUtil.linkAndPhoneNumberAttributedString(highlightedText, isExcludeMail: true)
            guard let highlightedText = highlightedText else { return }
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self, messageId == self.messageId else { return }
                self.attributedText = highlightedText
            }
        }
    }
    
    @objc func didClickInteractLink(_ sender: UITapGestureRecognizer) {
        guard sender.view == self else { return }
        
        // location of tap in myTextView coordinates and taking the inset into account
        var location = sender.location(in: self)
        location.x -= textContainerInset.left;
        location.y -= textContainerInset.top;
        
        /// 获取点击字符在 string 中的位置 Index
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        /// 判断是有效角标
        guard characterIndex < textStorage.length else {
            return
        }
        
        /// 获取字符字形的point
        let characterPoint = layoutManager.location(forGlyphAt: characterIndex)
        
        /// 获取当前 Index 位置字符的占用区域
        guard var stringRect = rect(forStringRange: NSRange(location: characterIndex, length: 1)) else {
            return
        }
        stringRect.origin.x = min(stringRect.minX, characterPoint.x)
        
        // 如果点击的 point 落在了字符占用的范围内 表示选中了
        // 如果点击的 point 落在了字形的开始位置带字符的长度之间 表示选中了
        guard location.x >= stringRect.minX, location.x <= stringRect.maxX else {
            return
        }
        
        // 回调点击事件
        let selectedAttributedText = textStorage.attributedSubstring(from: NSRange(location: characterIndex, length: 1))
        tapAction?(selectedAttributedText)
    }
}

extension UITextView {
    
    /// 查找文本范围所在的矩形范围
    ///
    /// - Parameter range: 文本范围
    /// - Returns: 文本范围所在的矩形范围
    func rect(forStringRange range: NSRange) -> CGRect? {
        guard let start = position(from: beginningOfDocument, offset: range.location) else { return nil }
        guard let end = position(from: start, offset: range.length) else { return nil }
        guard let textRange = textRange(from: start, to: end) else { return nil }
        let rect = firstRect(for: textRange)
        return self.convert(rect, from: textInputView)
    }
    
}


