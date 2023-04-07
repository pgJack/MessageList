//
//  MessageListGlobalConfig.swift
//  String
//
//  Created by 孙浩 on 2023/4/7.
//

import Foundation

struct MessageListGlobalConfig {
    static let shared = MessageListGlobalConfig()
    
    let reeditDuration: Int = 300
}
