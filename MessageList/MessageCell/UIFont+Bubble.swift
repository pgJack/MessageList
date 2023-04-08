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
    
    var normal: UIFont { .systemFont(ofSize: 16) }
    var fullEmoji: UIFont { .systemFont(ofSize: 20) }
    var nineEmoji: UIFont { .systemFont(ofSize: 30) }
    var sixEmoji: UIFont { .systemFont(ofSize: 42) }
    var threeEmoji: UIFont { .systemFont(ofSize: 48) }
    
    func font(text: String, isBigEmoji: Bool, isFullEmoji: Bool, realCount: Int) -> UIFont {
        guard isBigEmoji else {
            return .bubble.normal
        }
        return bigEmojiFont(text: text, isFullEmoji: isFullEmoji, realCount: realCount)
    }
    
    private func bigEmojiFont(text: String, isFullEmoji: Bool, realCount: Int) -> UIFont {
        guard isFullEmoji else {
            return .bubble.normal
        }
        switch realCount {
        case let count where count < 3:
            return .bubble.threeEmoji
        case let count where count < 6:
            return .bubble.sixEmoji
        case let count where count < 9:
            return .bubble.nineEmoji
        default:
            return .bubble.normal
        }
    }
}
