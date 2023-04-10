//
//  MessageListGlobalConfig.swift
//  String
//
//  Created by 孙浩 on 2023/4/7.
//

import Foundation
import BMMagazine

struct MessageListGlobalConfig {
    
    static let shared = MessageListGlobalConfig()
    
    let reeditDuration: Int = 300
    
    let dateFormatter = DateFormatter()
    var systemLocale: Locale? {
        guard let localeId = BMAppearance.shared().systemLocaleIdentifier() else { return nil }
        return Locale(identifier: localeId)
    }
    
    func text(sentTime: Int64) -> String? {
        guard sentTime > 0 else { return nil }
        guard let locale = systemLocale else { return nil }
        if let formatForHours = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: locale),
           formatForHours.contains(where: { $0 == "a" }) {
            dateFormatter.dateFormat = "h:mm a"
        } else {
            dateFormatter.dateFormat = "HH:mm"
        }
        dateFormatter.locale = locale
        let sentDate = Date(timeIntervalSince1970: TimeInterval(sentTime))
        return dateFormatter.string(for: sentDate)
    }
    
}
