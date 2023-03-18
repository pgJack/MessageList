//
//  MessageListModelGenerator.swift
//  String
//
//  Created by Noah on 2023/3/18.
//

import Foundation
import RongIMLib

struct MessageListModelGenerator {
    
    static func conversation(_ rcConversation: RCConversation) -> Conversation? {
        guard let channelId = rcConversation.channelId else {
            return nil
        }
        var targetId: String? = rcConversation.targetId
        var conversationType: ConversationType = .unknown
        var secretKey: String? = nil
        switch rcConversation.conversationType {
        case .ConversationType_PRIVATE:
            let isRobot = rcConversation.targetId == "BeemGlobalRobot"
            if isRobot {
                conversationType = .robot
            } else {
                conversationType = .person
            }
        case .ConversationType_GROUP:
            conversationType = .group
        case .ConversationType_Encrypted:
            conversationType = .person_encrypted
            let targeInfo = targetId?.components(separatedBy: ";;;")
            targetId = targeInfo?.last
            secretKey = targeInfo?.first
        default:
            break
        }
        guard let targetId = targetId, conversationType != .unknown else {
            return nil
        }
        let conversation = Conversation(targetId: targetId, channelId: channelId, conversationType: conversationType, secretKey: secretKey)
        return conversation
    }
    
}
