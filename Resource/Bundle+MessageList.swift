//
//  Bundle+MessageList.swift
//  String
//
//  Created by Noah on 2023/3/18.
//

import UIKit

private let kBundleName = "BMIMModuleResource"

extension Bundle {
    static var messageList: Bundle {
        guard let bundlePath = Bundle.main.path(forResource: kBundleName, ofType: "bundle"),
              let bundle = Bundle.init(path: bundlePath) else {
            return Bundle.main
        }
        return bundle
    }
}

enum MessageListBundleFile: String {
    case clockLoadingLight = "bm_clock_loading_light"
    case clockLoadingDark = "bm_clock_loading_dark"
    
    var fileName: String { rawValue }
}
