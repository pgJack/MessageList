//
//  RCExtraGenerator.swift
//  String
//
//  Created by Noah on 2023/3/22.
//

import Foundation
import RongIMLib

public struct MessageMentionedInfo: Codable {
    let userId: String
    let userName: String
    let isHighlightedBackground: Bool
}

public struct MessageExtraInfo: MessageExtraDecodeProtocol {
    let translateStatus: Int?
    let translateResultString: String?
}

public struct MessageContentExtraInfo: MessageExtraDecodeProtocol {
    
    // 消息会话名称，发送端设置
    let name: String?
    
    // "forward" 代表为转发消息
    let action: String?
    
    // 是否显示转发标记
    let forward: Bool?
    
    // {"id":"name"}
    let mentionInfo: [String: String]?
    
    // 被引用消息 messageUId
    let referenceMessageId: String?
    
    // 谷歌地图定位后的详细街道
    let locationName: String?
    
    // 发送名片消息时，名片消息的oid
    let profileOid: String?
    
    // Call 相关
    // mediaType:0是音频，1是视频
    let mediaType: Int?
    let sessionStatus: Int?
    let syncTime: Int?
    let crtTime: Int?

    // 密聊相关
    let secretChat: Int? // 是否密聊 1是密聊， 0不是
    let secretChatKey: String? //  密聊的密钥
}

let kEndMeetingKey = "meetingEnd"

// messageExpansion 中 userId 对应的 value
public struct MessageExpansionThumbUpAction: MessageExtraDecodeProtocol {
    // 消息点赞
    var userId: String?
    let e: String?
    let ts: Int?
}
public struct MessageExpansionPollAction: MessageExtraDecodeProtocol {
    // 投票结果
    var userId: String?
    let p: [Int]?
}

public protocol MessageExtraDecodeProtocol: Codable {
    static func info(_ infoText: String?) -> Self?
}
public extension MessageExtraDecodeProtocol {
    static func info(_ infoText: String?) -> Self? {
        guard let infoData = infoText?.data(using: .utf8) else { return nil }
        let extra = try? JSONDecoder().decode(Self.self, from: infoData)
        return extra
    }
}
