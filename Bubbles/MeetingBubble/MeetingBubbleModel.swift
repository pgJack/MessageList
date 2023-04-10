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
        MeetingBubbleView.self
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
    
    static var subjectHeight: CGFloat = 0
    static var dateHeight: CGFloat = 0
    static var passwordHeight: CGFloat = 0


    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let meetingMsg = rcMessage.content as? UMBLMeetingRobotMessage else {
            return
        }
        meetingId = meetingMsg.meetingId
        
        subject = "meeting_book_invite_topic\(meetingMsg.subject)"
        meetingDate = "\(meetingMsg.beginTime) - \(meetingMsg.endTime)"
        passwd = meetingMsg.passwd
        
        let originalNumber = meetingMsg.meetingNumber
        let displayedNumber = buSplit(string: originalNumber)
        meetingNumber = "meeting_book_invite_id\(displayedNumber)"
        
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
            MeetingBubbleModel.subjectHeight = subjectSize.height
            __messageContentViewHeight += subjectSize.height - MeetingBubbleModel.content_height
        } else {
            MeetingBubbleModel.subjectHeight = MeetingBubbleModel.content_height
        }
        
        if var dateSize = meetingDate?.bm_size(with: .systemFont(ofSize: 15), maxSize: maxSize), dateSize.height > MeetingBubbleModel.content_height {
            if (dateSize.height > MeetingBubbleModel.content_height * 2) {
                dateSize.height = MeetingBubbleModel.content_height * 2;
            }
            MeetingBubbleModel.dateHeight = dateSize.height
            __messageContentViewHeight += dateSize.height - MeetingBubbleModel.content_height
        } else {
            MeetingBubbleModel.dateHeight = MeetingBubbleModel.content_height
        }
        
        if let password = passwd, password.count > 0 {
            MeetingBubbleModel.passwordHeight = MeetingBubbleModel.content_height
            return __messageContentViewHeight
        }
        MeetingBubbleModel.passwordHeight = 0
        __messageContentViewHeight += -(MeetingBubbleModel.content_height + 16)
        return __messageContentViewHeight
    }
    
        
    private func buSplit(by character: Character = " ", string: String, spaceCount: Int = 3) -> String {
        if string.count <= spaceCount {
            return string
        }
        let spacecount = string.count % spaceCount == 0 ? string.count / spaceCount - 1 : string.count / spaceCount
        var str = string;
        for i in 1...spacecount {
            let positon = i * spaceCount + (i - 1);
            str.insert(character, at: str.index(str.startIndex, offsetBy: positon))
        }
        return str
    }
    
    func getDateContant(_ message: UMBLMeetingRobotMessage) -> String {
//        let isToday = Date.isToday(message.beginTime)
//        let isThisYear = Date.isThisYear(message.beginTime)
//        let isYesterday = Date.isYesterday(message.beginTime)
//        var prefixStr = ""
//
//        if isToday {
//            prefixStr = "meeting_book_invite_today"
//        }
//
//        if isYesterday {
//            prefixStr = "meeting_book_invite_yesterday"
//        }
//
//        let beginTimeDate = Date.dateFromServerTimestamp(message.beginTime)
//        let endTimeDate = Date.dateFromServerTimestamp(message.endTime)
//        var startTime: String, endTime: String
//
//        // 判断当前系统时间是 24 小时还是 12 小时
//        let formatter = RCKitUtility.getDateFormatterString(Date())
//
//        if isToday || isYesterday {
//            startTime = beginTimeDate.format(withType: formatter)
//        } else if isThisYear {
//            let formatterStr = "MMM d,\(formatter)"
//            startTime = beginTimeDate.format(withType: formatterStr)
//        } else {
//            let formatterStr = "MMM d,yyyy ,\(formatter)"
//            startTime = beginTimeDate.format(withType: formatterStr)
//        }
//
//        return "\("Start time"):\(prefixStr.appending(" \(startTime)"))"
        return "getDateContant"
    }

}
