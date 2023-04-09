//
//  CallMissBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore
import BMIMLib

class CallMissBubbleModel: BubbleModel, BubbleInfoProtocol {
    
    var cellType: String {
        MessageCellRegister.tip
    }
    
    var bubbleViewType: BubbleView.Type {
        BubbleView.self
    }
    
    var canTapAvatar = false
    lazy var canLongPressAvatarMention = message.conversationType == .group
    lazy var canPanReference = message.conversationType != .person_encrypted
    
    var contentString: String?
    var mediaType: BMIMCallMediaType?
    var detailTime: Int?
    
    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let callMissMsg = rcMessage.content as? BMIMCallMissMessage else {
                  return
              }
        
        contentString = callMissMsg.content
        if let mediaTypeValue = message.contentExtra?.mediaType {
            mediaType = BMIMCallMediaType(rawValue: UInt(mediaTypeValue))
        }
        if let crtTime = message.contentExtra?.crtTime {
            detailTime = crtTime / 1000
        }
        
        let attributedText: NSAttributedString = splicingAttributedText()
        
        let maxSize = CGSize(width: CGFloat.bubble.maxWidth, height: .greatestFiniteMagnitude)
        if let rect = BubbleAttributedTextUtil.boundingRect(attributedText, maxSize: maxSize) {
            bubbleContentSize = CGSize(width: ceil(CGFloat.bubble.maxWidth), height: ceil(rect.size.height))
        }
        
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    private func splicingAttributedText() -> NSAttributedString {
        var content = ""
        if (mediaType == .audio) {
            content = "Missed voice call at \(String(describing: detailTime))"
        } else {
            content = "Missed video call at \(String(describing: detailTime))"
        }
        
        let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor(light: UIColor(0x3370FE), dark: UIColor(0x0A84FF)), .underlineStyle: NSUnderlineStyle.single, .underlineColor: UIColor(light: UIColor(0x3370FE), dark: UIColor(0x0A84FF))]
        
        let attributedText = NSMutableAttributedString(string: content, attributes: attributes)
        return attributedText
    }
}
