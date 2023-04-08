//
//  BubbleImageProtocol.swift
//  String
//
//  Created by Noah on 2023/4/7.
//

import UIKit

//MARK: Bubble Background Image

protocol BubbleImageProtocol {
    
    /// 是否为高亮状态
    var isHighlighted: Bool { set get }
    
    /// 消息气泡背景图类型
    var bubbleForegroundImageType: BubbleImageType { get }
    var bubbleBackgroundImageType: BubbleImageType { get }
    
}
