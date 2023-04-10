//
//  HQVoiceBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore

class HQVoiceBubbleModel: MediaBubbleModel, BubbleInfoProtocol, BubbleImageProtocol {
    var cellType: String {
        message.messageDirection == .send
        ? MessageCellRegister.sender
        : MessageCellRegister.receiver
    }
    
    var bubbleViewType: BubbleView.Type {
        HQVoiceBubbleView.self
    }
    
    var canTapAvatar: Bool = true
    lazy var canLongPressAvatarMention = message.conversationType == .group
    lazy var canPanReference = message.conversationType != .person_encrypted
    
    //MARK: Bubble Background Image
    var isHighlighted: Bool = false
    var bubbleForegroundImageType: BubbleImageType {
        return .none
    }
    var bubbleBackgroundImageType: BubbleImageType {
        switch message.messageDirection {
        case .send:
            return isHighlighted ? .purple_v2 : .purple_v1
        default:
            return isHighlighted ? .gray : .white
        }
    }
    
    static let voiceHeight = 66
    static let avatarSendEdge = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    static let avatarReceiveEdge = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 0)
    static let avatarSideSize = CGSize(width: 40, height: 40)
    static let voiceBubbleWidth = 270 * CGFloat.bubble.maxWidthRatio
    
    var duration: Int = 0
    
    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let voiceContent = rcMessage.content as? RCHQVoiceMessage else {
            return
        }
        
        duration = voiceContent.duration
        
        let width = HQVoiceBubbleModel.voiceBubbleWidth

        let height = FileBubbleModel.fileViewHeight
        bubbleContentSize = CGSize(width: ceil(width), height: ceil(height))
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
}
