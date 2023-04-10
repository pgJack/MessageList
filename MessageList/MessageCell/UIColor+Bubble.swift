//
//  UIFont+Bubble.swift
//  String
//
//  Created by Noah on 2023/3/18.
//

import Foundation
import BMMagazine

private let kNameColors = [0x019AD6, 0x2F83EE, 0xF15B71, 0xF26622, 0xD9C911, 0x5643E9, 0xA244EA, 0x45BA7C, 0x2B5CAA, 0xF05B9B, 0xFAA755, 0xFB9775, 0xBE6758, 0x575FAA, 0x7EB70E, 0x02AE9D, 0x1C953E, 0xAE8A3D, 0x80752C, 0xEF4236]

extension UIColor {
    static let bubble = BubbleColor()
}

struct BubbleColor {
    
    // 消息日期背景色
    var dateBackground: UIColor {
        UIColor(light: UIColor(0xF0E5FF), dark: UIColor(0xFFFFFF, alpha: 0.1))
    }
    // 消息日期文字颜色
    var dateText: UIColor {
        UIColor(light: UIColor(0x1E242A), dark: UIColor(0xFFFFFF, alpha: 0.9))
    }
    // 发送人名称颜色，根据 userId 计算色值
    func nameColor(forUserId uid: String?) -> UIColor {
        guard let firstAscii = uid?.first?.asciiValue else {
            return UIColor(light: .gray, dark: UIColor(0x7A7A7A))
        }
        let colorKey = Int(firstAscii)
        let colorHex = kNameColors[colorKey % kNameColors.count]
        return UIColor(colorHex)
    }
    // 消息气泡中，不透明的时间背景色
    var opacityTimeBackground: UIColor {
        UIColor(light: UIColor(0xFFFFFF), dark: UIColor(0xFFFFFF,alpha: 0.1))
    }
    // 消息气泡，默认时间背景色
    var timeText: UIColor {
        UIColor(light: UIColor(0x8C959E), dark: UIColor(0xFFFFFF,alpha: 0.4))
    }
    
}
