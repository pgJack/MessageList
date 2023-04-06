//
//  MessageBaseCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import UIKit

private let kPanSafeSpace: CGFloat = 60

class MessageBaseCell: UICollectionViewCell {
    
    var bubbleModel: BubbleModel?
    
    lazy var baseView: MessageBaseView = {
        let view = MessageBaseView()
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }
        return view
    }()
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
        setupGesture()
    }
    
    func updateSubviewsOnReuse(_ bubbleModel: BubbleModel) {
        self.bubbleModel = bubbleModel
        baseView.setUnreadLine(isHidden: !bubbleModel.shownUnreadLine)
        baseView.setMessageDate(dateText: bubbleModel.dateText)
    }
    
}

//MARK: Gesture Delegate
extension MessageBaseCell: UIGestureRecognizerDelegate {
    
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
        let isRTL = view.semanticContentAttribute == .forceRightToLeft
        let viewWidth = view.frame.width
        let location = gestureRecognizer.location(in: view)
        let inSafeEdge = isRTL ? (location.x < viewWidth - kPanSafeSpace) : location.x > kPanSafeSpace
        guard inSafeEdge else { return false }
        
        // 垂直拖动不处理
        let velocity = gestureRecognizer.velocity(in: view)
        guard abs(velocity.x) > abs(velocity.y) else { return false }
        
        return true
    }
    
}

//MARK: Gesture
@objc extension MessageBaseCell {
    
    func setupGesture() {
        addGestureRecognizer(_tapGesture)
        addGestureRecognizer(_longPressGesture)
        addGestureRecognizer(_panGesutre)
    }
    
    func onTapMessageCell(_ gesture: UITapGestureRecognizer) { }
    
    func onLongPressMessageCell(_ gesture: UILongPressGestureRecognizer) { }
    
    func onPanMessageCell(_ gesture: UIPanGestureRecognizer) { }
    
}
