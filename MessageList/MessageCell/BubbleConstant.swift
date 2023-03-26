//
//  MessageListLayoutConstant.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import UIKit

extension CGFloat {
    static let bubble = BubbleFloatConstant.self
}

extension CGSize {
    static let bubble = BubbleSizeConstant.self
}

extension UIEdgeInsets {
    static let bubble = BubbleEdgeInsetsConstant.self
}

struct BubbleFloatConstant {
    
    static var maxWidthRatio: CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width
        return screenWidth > 320 ? 0.77 : 0.6
    }
    static var maxWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.size.width
        let ratio = maxWidthRatio
        return round(screenWidth*ratio)
    }
        
    static let unreadLineHeight: CGFloat = 37

    static let dateHeight: CGFloat = 16
    static let dateBackgroundTop: CGFloat = 32
    static let dateBackgroundHeight: CGFloat = UIEdgeInsets.bubble.dateBackgroundEdge.top+dateHeight+UIEdgeInsets.bubble.dateBackgroundEdge.bottom
    static let dateBackgroundRadius: CGFloat = dateBackgroundHeight / 2
    static let dateViewHeight: CGFloat = dateBackgroundTop+dateBackgroundHeight+12
    
    static let checkBoxImageTrailing: CGFloat = 7
    static let checkBoxWidth: CGFloat = 8+CGSize.bubble.checkBoxImageSize.width+checkBoxImageTrailing
    
    static let avatarTop: CGFloat = 0
    static let avatarRadius: CGFloat = CGSize.bubble.avatarSize.height / 2

    static let nameAvatarSpace: CGFloat = 4
    static let nameTop: CGFloat = 0
    static let nameHeight: CGFloat = 16
    static let nameHiddenHeight: CGFloat = 0
    
    static let bubbleAvatarSpace: CGFloat = 0
    static let bubbleTop: CGFloat = 0
    static let bubbleBottom: CGFloat = 0
    
    static let sentStatusBubbleSpace: CGFloat = 8

    static let reactionTop: CGFloat = -2
    static let reactionHeight: CGFloat = 28
    
    static let exBubbleTop: CGFloat = 0
    static let exBubbleOffset: CGFloat = 5
    
    static let bubbleTimeTextHeight: CGFloat = 14
    static let bubbleTimeSpacing: CGFloat = 4
    static let bubbleTimeSpacingTime: CGFloat = 2
    static let bubbleTimeEdgeLeading: CGFloat = 10
    static let bubbleTimeEdgeTrailing: CGFloat = 10
    static let bubbleTimeEdgeBottom: CGFloat = 6
    static let bubbleTimeBackgroundHeight: CGFloat = 16
    static let bubbleTimeBackgroundRadius: CGFloat = 4
    
}

struct BubbleSizeConstant {
    
    static let checkBoxImageSize: CGSize = CGSize(width: 20, height: 20)

    static let avatarSize: CGSize = CGSize(width: 32, height: 32)
    static let avatarViewSize: CGSize = CGSize(width: 40, height: 32)
    static let avatarViewHiddenSize: CGSize = CGSize(width: 6, height: 32)
    
    static let bubbleEmptySize: CGSize = CGSize(width: 36, height: 36)
    
    static let sentStatusSize: CGSize = CGSize(width: 17, height: 17)
    
    static let reactionEmptySize: CGSize = CGSize(width: 0, height: 2)
    
    static let exBubbleEmptySize: CGSize = .zero
    
    static let bubbleTimeIconSize: CGSize = CGSize(width: 9, height: 9)

    static let centerMediaLoadingSize: CGSize = CGSize(width: 40, height: 40)
    
}

struct BubbleEdgeInsetsConstant {
    
    static let contentEdge = UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0)
    
    static let dateBackgroundEdge = UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
    
    static let bubbleTimeBackgroundEdge = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
    
    static let exBubbleEdge = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

}
