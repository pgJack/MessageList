//
//  HQVoiceBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore

class HQVoiceBubbleModel: MediaBubbleModel {

    override var bubbleViewType: BubbleView.Type {
        HQVoiceBubbleView.self
    }
    
    static let voiceHeight = 66
    static let avatarSendEdge = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    static let avatarReceiveEdge = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 0)
    static let avatarSideSize = CGSize(width: 40, height: 40)
    static let voiceBubbleWidth = 270 * CGFloat.bubble.maxWidthRatio
    
    var duration: Int = 0
    
    override func setupBubbleContent(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleContent(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let voiceContent = rcMessage.content as? RCHQVoiceMessage else {
            return
        }
        duration = voiceContent.duration
        let width = HQVoiceBubbleModel.voiceBubbleWidth
    }
    
    override func setupBubbleSize(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleSize(rcMessages: rcMessages, currentUserId: currentUserId)
        let width = CGFloat.bubble.maxWidth
        let height: CGFloat = FileInfoView.fileInfoHeight
        bubbleContentSize = CGSize(width: ceil(width), height: ceil(height))
    }
    
}
