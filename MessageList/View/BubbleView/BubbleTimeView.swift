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
    
    private(set) lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = .bubble.bubbleTimeSpacing
        stackView.alignment = .center
        addSubview(stackView)
        stackView.addArrangedSubview(timeLabel)
        return stackView
    }()
    lazy var iconViews = [UIImageView]()
    lazy var timeLabel: UILabel = {
        let label = UILabel(font: BMFont(10))
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
        let timeViewEdge = UIEdgeInsets.bubble.bubbleTimeBackgroundEdge
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
    
    func update(icons:[UIImage], timeText: String, textColor: UIColor, alignment: BubbleTimeAlignment, backgroundStyle: BubbleTimeBackgroundStyle) {
                
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
        
        opacityView.isHidden = backgroundStyle != .opacity
        
        var bottomEdgeBottom = CGFloat.bubble.bubbleTimeEdgeBottom
        var bottomEdgeLeading = CGFloat.bubble.bubbleTimeEdgeLeading
        var bottomEdgeTrailing = CGFloat.bubble.bubbleTimeEdgeTrailing
                
        switch backgroundStyle {
        case .opacity:
            bottomEdgeBottom = 0
            bottomEdgeLeading = UIEdgeInsets.bubble.bubbleTimeBackgroundEdge.left
            bottomEdgeTrailing = UIEdgeInsets.bubble.bubbleTimeBackgroundEdge.right
        default:
            break
        }
        
        stackView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().offset(-bottomEdgeBottom)
            switch alignment {
            case .leading:
                make.leading.equalToSuperview().offset(bottomEdgeLeading)
            default:
                make.trailing.equalToSuperview().offset(-bottomEdgeTrailing)
            }
        }
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
