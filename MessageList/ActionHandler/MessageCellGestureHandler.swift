//
//  MessageCellActionHandler.swift
//  String
//
//  Created by Noah on 2023/4/2.
//

import UIKit

private let kSafeEdge = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 60)

class MessageCellGestureHandler: NSObject, MessageCellActionDelegate {
    
    /// 消息列表 ViewModel
    private weak var _viewModel: MessageListViewModel?
    
    private var _isPanning = false
    
    init?(viewModel: MessageListViewModel) {
        _viewModel = viewModel
    }
    
    func onTapMessageCell<T>(_ messageCell: T, gesture: UITapGestureRecognizer) where T : MessageBaseCell {
        
    }
    
    func onLongPressMessageCell<T>(_ messageCell: T, gesture: UILongPressGestureRecognizer) where T : MessageBaseCell {
        
    }
    
    func onPanMessageCell<T>(_ messageCell: T, gesture: UIPanGestureRecognizer) where T : MessageBaseCell {
        switch gesture.state {
        case .changed:
            if let userCell = messageCell as? MessageUserCell {
                let translation = gesture.translation(in: userCell)
                _panning(userCell: userCell, translationX: translation.x)
            }
        default:
            if let userCell = messageCell as? MessageUserCell {
                _resetUserCell(userCell: userCell)
            }
        }
    }
    
}

extension MessageCellGestureHandler {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        switch gestureRecognizer {
        case let gestureRecognizer as UIPanGestureRecognizer:
            return _isVaildPanAction(gestureRecognizer)
        default:
            return true
        }
    }
    
    func _isVaildPanAction(_ gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        guard let collectionView = _viewModel?.collectionView else { return true }
        guard let view = gestureRecognizer.view else { return true }
        
        // 列表滚动时不处理
        guard !collectionView.isDragging else { return false }
        
        // 靠近边缘不处理，以免影响右滑返回
        let isRTL = view.semanticContentAttribute == .forceRightToLeft
        let viewWidth = view.frame.width
        let location = gestureRecognizer.location(in: view)
        let inSafeEdge = isRTL ? (location.x < viewWidth - kSafeEdge.right) : location.x > kSafeEdge.left
        guard inSafeEdge else { return false }
        
        // 垂直拖动不处理
        let velocity = gestureRecognizer.velocity(in: view)
        guard abs(velocity.x) > abs(velocity.y) else { return false }
        
        return true
    }
    
}

extension MessageCellGestureHandler {
 
    func _panning<T: MessageUserCell>(userCell: T, translationX: CGFloat) {
        guard let moveView = userCell.detailView else { return }
        let tipView = userCell.forwardTipView
        let viewX = moveView.frame.minX
        let viewOffsetX = moveView.transform.tx
        guard viewX == viewOffsetX else {
            tipView.alpha = 0
            return
        }
        let maxTranslationX = moveView.frame.width / 4
        var targetX: CGFloat = 0
        var alpha: CGFloat = 0
        if moveView.semanticContentAttribute == .forceRightToLeft {
            targetX = max(min(translationX, 0), -maxTranslationX)
            alpha = -targetX / maxTranslationX
        } else {
            targetX = min(max(translationX, 0), maxTranslationX)
            alpha = targetX / maxTranslationX
        }
        moveView.transform = CGAffineTransformMakeTranslation(targetX, 0)
        tipView.alpha = alpha
    }
    
    func _resetUserCell<T: MessageUserCell>(userCell: T) {
        let tipView = userCell.forwardTipView
        guard tipView.alpha != 0 else { return }
        guard let moveView = userCell.detailView else { return }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            moveView.transform = .identity
            tipView.alpha = 0
        }
    }
    
}
