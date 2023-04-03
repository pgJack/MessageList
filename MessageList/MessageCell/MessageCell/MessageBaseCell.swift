//
//  MessageBaseCell.swift
//  BMIMModule
//
//  Created by Noah on 2023/3/13.
//

import UIKit

protocol MessageCellActionDelegate: UIGestureRecognizerDelegate {
    func onTapMessageCell<T: MessageBaseCell>(_ messageCell: T, gesture: UITapGestureRecognizer)
    func onLongPressMessageCell<T: MessageBaseCell>(_ messageCell: T, gesture: UILongPressGestureRecognizer)
    func onPanMessageCell<T: MessageBaseCell>(_ messageCell: T, gesture: UIPanGestureRecognizer)
}

extension MessageCellActionDelegate {
    func onTapMessageCell<T: MessageBaseCell>(_ messageCell: T, gesture: UITapGestureRecognizer) { }
    func onLongPressMessageCell<T: MessageBaseCell>(_ messageCell: T, gesture:  UILongPressGestureRecognizer) { }
    func onPanMessageCell<T: MessageBaseCell>(_ messageCell: T, gesture: UIPanGestureRecognizer) { }
}

class MessageBaseCell: UICollectionViewCell {
    
    var bubbleModel: BubbleModel?
    weak var actionDelegate: MessageCellActionDelegate? {
        didSet {
            _tapGesture.delegate = actionDelegate
            _longPressGesture.delegate = actionDelegate
            _panGesutre.delegate = actionDelegate
        }
    }
    
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

//MARK: Gesture
@objc extension MessageBaseCell {
    
    func setupGesture() {
        addGestureRecognizer(_tapGesture)
        addGestureRecognizer(_longPressGesture)
        addGestureRecognizer(_panGesutre)
    }
    
    func onTapMessageCell(_ gesture: UITapGestureRecognizer) {
        guard let actionDelegate = actionDelegate else { return }
        actionDelegate.onTapMessageCell(self, gesture: gesture)
    }
    
    func onLongPressMessageCell(_ gesture: UILongPressGestureRecognizer) {
        guard let actionDelegate = actionDelegate else { return }
        actionDelegate.onLongPressMessageCell(self, gesture: gesture)
    }
    
    func onPanMessageCell(_ gesture: UIPanGestureRecognizer) {
        guard let actionDelegate = actionDelegate else { return }
        actionDelegate.onPanMessageCell(self, gesture: gesture)
    }
    
}
