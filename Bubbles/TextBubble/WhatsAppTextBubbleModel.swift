//
//  WhatsAppTextBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import BMIMLib

class WhatsAppTextBubbleModel: TextBubbleModel {
    
    //MARK: Action Control
    /// 是否允许响应点击头像
    override var canTapAvatar: Bool {
        get { return false }
        set { }
    }
     
    /// 是否允许长摁头像 @ 用户
    override var canLongPressAvatarMention: Bool {
        get { return false }
        set { }
    }
    
    //MARK: Bubble Background Image
    override var bubbleForegroundImageType: BubbleImageType { .none }
    override var bubbleBackgroundImageType: BubbleImageType {
        switch message.messageDirection {
        case .send:
            return isBubbleHighlighted ? .purple_v2 : .purple_v1
        default:
            return isBubbleHighlighted ? .gray : .white
        }
    }
    
    //MARK: Text View
    override var isBigEmoji: Bool { false }
    
    //MARK: Time View
    override var timeAlignment: BubbleTimeAlignment { .training }
    override var timeBackgroundStyle: BubbleTimeBackgroundStyle { .clear }
    
}
