//
//  MeetingBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore
import BMIMLib
import BMMagazine

class MeetingBubbleModel: BubbleModel, BubbleInfoProtocol {
    var cellType: String {
        message.messageDirection == .send
        ? MessageCellRegister.sender
        : MessageCellRegister.receiver
    }
    
    var bubbleViewType: BubbleView.Type {
        ContactCardBubbleView.self
    }
    
    var canTapAvatar: Bool = true
    lazy var canLongPressAvatarMention = message.conversationType == .group
    lazy var canPanReference = message.conversationType != .person_encrypted
    
    static let file_content_height: CGFloat = 278
    static let content_height: CGFloat = 20
    
    var meetingId: String?
    var subject: String?
    var meetingDate: String?
    var passwd: String?
    var meetingNumber: String?

    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let meetingMsg = rcMessage.content as? UMBLMeetingRobotMessage else {
            return
        }
        meetingId = meetingMsg.meetingId
        subject = meetingMsg.subject
        meetingDate = "\(meetingMsg.beginTime) - \(meetingMsg.endTime)"
        passwd = meetingMsg.passwd
        meetingNumber = meetingMsg.meetingNumber

        
        let cellHeight = heightMessageContentView()
        bubbleContentSize = CGSize(width: ceil(CGFloat.bubble.maxWidth), height: ceil(cellHeight))
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    private func heightMessageContentView() -> CGFloat {
        let maxWidth = CGFloat.bubble.maxWidth - 20 - 16 - 12 - 8
        let maxSize = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        var __messageContentViewHeight = MeetingBubbleModel.file_content_height
        if var subjectSize = subject?.bm_size(with: .systemFont(ofSize: 15), maxSize: maxSize),
           subjectSize.height > MeetingBubbleModel.content_height {
            if (subjectSize.height > MeetingBubbleModel.content_height * 2) {
                subjectSize.height = MeetingBubbleModel.content_height * 2;
            }
            __messageContentViewHeight += subjectSize.height - MeetingBubbleModel.content_height
        }
        
        if var dateSize = meetingDate?.bm_size(with: .systemFont(ofSize: 15), maxSize: maxSize), dateSize.height > MeetingBubbleModel.content_height {
            if (dateSize.height > MeetingBubbleModel.content_height * 2) {
                dateSize.height = MeetingBubbleModel.content_height * 2;
            }
            __messageContentViewHeight += dateSize.height - MeetingBubbleModel.content_height
        }
        if let password = passwd, password.count > 0 {
            return __messageContentViewHeight
        }
        __messageContentViewHeight += -(MeetingBubbleModel.content_height + 16)
        return __messageContentViewHeight
    }
}
