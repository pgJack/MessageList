//
//  BubbleInfoProtocol.swift
//  String
//
//  Created by Noah on 2023/4/6.
//

import Foundation

protocol BubbleInfoProtocol {
    
    //MARK: Bind View
    
    /// 对应 Cell 类型
    var cellType: String { get }
    
    /// 对应气泡类型
    var bubbleViewType: BubbleView.Type { get }
    
    //MARK: Action Control
    
    /// 是否允许响应点击头像
    var canTapAvatar: Bool { set get }
    
    /// 是否允许长摁头像 @ 用户
    var canLongPressAvatarMention: Bool { set get }
    
    /// 是否允许右滑引用
    var canPanReference: Bool { set get }
    
}
