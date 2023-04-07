//
//  VoiceProgressView.swift
//  String
//
//  Created by 孙浩 on 2023/4/7.
//

import UIKit
import RongIMLibCore

class VoiceProgressView: UIView {

    static let progressHeight: CGFloat = 42
    private static let pointerSideWidth: CGFloat = 10
    
    var milestones: [UIView] = []
    var soundSource: MessageDirection? = nil {
        didSet {
//            let stoneColor = DYCOLOR(HEXCOLOR(0x7565D0), HEXCOLOR(0xffffff));
            let stoneColor = UIColor.red
            milestones.forEach { stone in
                stone.backgroundColor = stoneColor
            }
        }
    }
    lazy var pointer: UIView = {
        let view = UIView()
        view.frame = CGRect(x: VoiceProgressView.pointerSideWidth / 2, y: (VoiceProgressView.progressHeight - VoiceProgressView.pointerSideWidth) / 2, width: VoiceProgressView.pointerSideWidth, height: VoiceProgressView.pointerSideWidth)
        view.layer.cornerRadius = VoiceProgressView.pointerSideWidth / 2
        view.layer.masksToBounds = true
//        view.backgroundColor = DYCOLOR(HEXCOLOR(0x7565D0), HEXCOLOR(0xFFFFFF));
        return view
    }()
    
    
    func proceed(rate: CGFloat) {
//        let pointerX = self.frame.size.width * ([RCKitUtility isRTL] ? (1 - rate) : rate) - kPointerSideWidth/2;
        let pointerX = self.frame.size.width * rate - VoiceProgressView.pointerSideWidth / 2;
        var pointerFrame = pointer.frame;
        let currentX = pointerFrame.origin.x;
//        if ([RCKitUtility isRTL] && currentX <= - kPointerSideWidth/2) {
//            currentX = self.frame.size.width - kPointerSideWidth/2;
//        }
        pointerFrame.origin.x = pointerX
        if pointerX > currentX {
            UIView.animate(withDuration: 0.1) {
                self.pointer.frame = pointerFrame
            }
        } else {
            self.pointer.frame = pointerFrame;
        }

        milestones.forEach { stone in
//            BOOL isPlay = (![RCKitUtility isRTL] && CGRectGetMinX(stone.frame) > pointerX) || ([RCKitUtility isRTL] && CGRectGetMinX(stone.frame) < pointerX);
            let isPlay = (stone.frame.minX > pointerX) || (stone.frame.minX < pointerX)
            if (isPlay && rate != 1) {
                stone.alpha = 0.23;
            } else {
                stone.alpha = 1;
            }
        }
    }
    
    func resetStonesSite(width: CGFloat) {
//        self.pointer.frame = CGRectMake([RCKitUtility isRTL] ? self.frame.size.width -kPointerSideWidth/2 : -kPointerSideWidth/2, (Progress_Height - kPointerSideWidth)/2, kPointerSideWidth, kPointerSideWidth);
        pointer.frame = CGRect(x: VoiceProgressView.pointerSideWidth / 2, y: (VoiceProgressView.progressHeight - VoiceProgressView.pointerSideWidth) / 2, width: VoiceProgressView.pointerSideWidth, height: VoiceProgressView.pointerSideWidth)
        
        milestones.forEach { stone in
            stone.removeFromSuperview()
        }
        
        var stones = [UIView]()

        for i in 0..<(Int(width)/5) {
            stones.append(stoneWithIndex(index: i))
        }
        milestones = stones
    }
    
    private func stoneWithIndex(index: Int) -> UIView {
        let margin = 3.0
        let width = 2.0
        let viewHeight = VoiceProgressView.progressHeight;
        let stoneHeight = stoneHeight(index: index);

        let stone = UIView()
        stone.backgroundColor = .white
        stone.layer.cornerRadius = 1
        stone.frame = CGRectMake(Double(index) * (margin + width), (viewHeight - stoneHeight) / 2.0, width, stoneHeight);
        addSubview(stone)
        return stone;
    }
    
    private func stoneHeight(index: Int) -> CGFloat {
        return [7,8,6,10,14,16,10,8,14,16,14,10,6,10,14,16,10,8,14,10][index % 20]
    }
}
