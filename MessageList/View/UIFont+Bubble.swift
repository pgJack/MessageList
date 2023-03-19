//
//  UIFont+Bubble.swift
//  String
//
//  Created by Noah on 2023/3/18.
//

import Foundation
import BMMagazine

extension UIFont {
    static let bubble = BubbleFont()
}

struct BubbleFont {
    // 消息日期字体
    var date: UIFont { BMFont(11) }
    // 发送人名称字体
    var senderName: UIFont { BMFont(12) }
}
