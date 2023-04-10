//
//  BubbleTimeView.swift
//  BMIMModule
//
//  Created by Noah on 2022/12/2.
//

import UIKit
import BMMagazine

enum BubbleTimeBackgroundStyle: Int {
    case clear, shadow, opacity
}

enum BubbleTimeAlignment: Int {
    case none, leading, training
}

class BubbleTimeView: UIView {
    
    private var backgroundStyle = BubbleTimeBackgroundStyle.clear
    private var timeAlignment = BubbleTimeAlignment.none
    static func stackViewEdge(style: BubbleTimeBackgroundStyle) -> UIEdgeInsets {
        style == .opacity ? .bubble.opacityTimeEdge : .bubble.timeEdge
    }
    
    private(set) lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = .bubble.bubbleTimeSpacingIcon
        stackView.alignment = .center
        addSubview(stackView)
        stackView.addArrangedSubview(timeLabel)
        return stackView
    }()
    lazy var iconViews = [UIImageView]()
    lazy var timeLabel: UILabel = {
        let label = UILabel(font: .bubble.time)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.height.equalTo(CGFloat.bubble.bubbleTimeTextHeight)
        }
        return label
    }()
    lazy var opacityView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.backgroundColor = .bubble.opacityTimeBackground
        view.layer.cornerRadius = .bubble.bubbleTimeBackgroundRadius
        addSubview(view)
        sendSubviewToBack(view)
        let timeViewEdge = UIEdgeInsets.bubble.opacityTimeEdge
        view.snp.makeConstraints { make in
            make.leading.equalTo(stackView).offset(-timeViewEdge.left)
            make.trailing.equalTo(stackView).offset(timeViewEdge.right)
            make.top.equalTo(stackView).offset(-timeViewEdge.top)
            make.bottom.equalTo(stackView).offset(timeViewEdge.bottom)
        }
        return view
    }()
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        isUserInteractionEnabled = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        __updateShadowPath()
    }
    
    func update(icons:[UIImage], timeText: String?, textColor: UIColor, alignment: BubbleTimeAlignment, backgroundStyle: BubbleTimeBackgroundStyle) {
                
        iconViews.forEach(__remove(iconView:))
        icons.enumerated().forEach { (index, image) in
            __insert(image, at: index, isLast: index == icons.count - 1)
        }
        
        timeLabel.text = timeText
        timeLabel.textColor = textColor
        
        if self.backgroundStyle == backgroundStyle,
           self.timeAlignment == alignment {
            return
        }
        
        self.backgroundStyle = backgroundStyle
        self.timeAlignment = alignment
        let stackViewEdge = Self.stackViewEdge(style: backgroundStyle)
        
        opacityView.isHidden = backgroundStyle != .opacity
        
        stackView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().offset(-stackViewEdge.bottom)
            switch alignment {
            case .leading:
                make.leading.equalToSuperview().offset(stackViewEdge.left)
            default:
                make.trailing.equalToSuperview().offset(-stackViewEdge.right)
            }
        }
    }
    
    static func sizeFor(iconCount: CGFloat, timeText: String?, backgroundStyle: BubbleTimeBackgroundStyle) -> CGSize {
        let maxTextSize = CGSize(width: .greatestFiniteMagnitude, height: .bubble.bubbleTimeTextHeight)
        let timeText = timeText ?? ""
        let timeSize = BubbleAttributedTextUtil.boundingRect(NSAttributedString(string: timeText, attributes: [.font: UIFont.bubble.time]), maxSize: maxTextSize) ?? .zero
        let stackViewEdge = stackViewEdge(style: backgroundStyle)
        let iconSize = CGSize.bubble.bubbleTimeIconSize
        var iconWidth: CGFloat = 0
        if iconCount > 0 {
            iconWidth = iconSize.width * iconCount + CGFloat.bubble.bubbleTimeSpacingIcon * (iconCount - 1)
            iconWidth += CGFloat.bubble.bubbleTimeSpacingTime
        }
        let width = stackViewEdge.left + stackViewEdge.right + timeSize.width + iconWidth
        let height = stackViewEdge.top + stackViewEdge.bottom + .bubble.bubbleTimeTextHeight
        return CGSize(width: width, height: height)
    }
    
}

//MARK: Control IconViews
extension BubbleTimeView {
    
    private func __remove(iconView: UIImageView) {
        stackView.removeArrangedSubview(iconView)
        iconView.removeFromSuperview()
    }
    
    private func __insert(_ image: UIImage, at index: Int, isLast: Bool) {
        let iconView = __iconView(atIndex: index)
        iconView.image = image
        stackView.insertArrangedSubview(iconView, at: index)
        if #available(iOS 11.0, *) {
            if isLast {
                stackView.setCustomSpacing(CGFloat.bubble.bubbleTimeSpacingTime, after: iconView)
            }
        }
    }
    
    private func __iconView(atIndex index: Int) -> UIImageView {
        if iconViews.count > index {
            return iconViews[index]
        }
        let imageView = UIImageView()
        imageView.snp.makeConstraints { make in
            make.size.equalTo(CGSize.bubble.bubbleTimeIconSize)
        }
        iconViews.append(imageView)
        return imageView
    }
    
}

//MARK: Layer Method
extension BubbleTimeView {
    
    private func __updateShadowPath() {
        guard backgroundStyle == .shadow else {
            layer.shadowPath = nil
            return
        }
        
        if backgroundStyle == .opacity {
            layer.cornerRadius = 0
            layer.masksToBounds = false
        } else {
            layer.cornerRadius = 10
            layer.masksToBounds = true
        }
        
        let stackOrigin = stackView.frame.origin
        let stackSize = stackView.frame.size
        
        let shadowWidth = (stackSize.width + 100) * 2
        let shadowHeight = stackSize.height * 4.5
        
        var shadowRect = CGRect(x: stackOrigin.x - 50, y: stackOrigin.y - 5, width: shadowWidth, height: shadowHeight)
        if BMAppearance.shared().isRTL() {
            shadowRect = CGRect(x: stackOrigin.x - shadowHeight + 50, y: stackOrigin.y - 5, width: shadowWidth, height: shadowHeight)
        }
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width:0, height:0)
        layer.shadowRadius = 15
        layer.shadowOpacity = 0.3
        let shadowPath = UIBezierPath(ovalIn: shadowRect)
        layer.shadowPath = shadowPath.cgPath
    }
    
}
