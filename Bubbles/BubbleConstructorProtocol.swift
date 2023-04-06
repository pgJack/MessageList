//
//  BubbleConstructorProtocol.swift
//  String
//
//  Created by Noah on 2023/4/6.
//

import Foundation

protocol BubbleConstructorProtocol {
    
    /// 对应 Cell 类型
    var cellType: String { get }
    
    /// 对应气泡类型
    var bubbleViewType: BubbleView.Type { get }
    
}
