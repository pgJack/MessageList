//
//  UIImage+MessageList.swift
//  String
//
//  Created by Noah on 2023/3/18.
//

import UIKit

extension UIImage {
    static let bubble = BubbleImage()
}

struct BubbleImage {
    var checkBoxChecked: UIImage? {
        UIImage(named: "selected_group_icon")
    }
    var checkBoxUnchecked: UIImage? {
        UIImage(named: "un_selected_group_icon")
    }
    var checkBoxDisabled: UIImage? {
        UIImage(named: "unselected_full_white")
    }
    
    var sentStatusUnread: UIImage? {
        UIImage(named: "message_unread_simple")
    }
    var sentStatusDelivered: UIImage? {
        UIImage(named: "message_send_simple")
    }
    var sentStatusRead: UIImage? {
        UIImage(named: "message_read_simple")
    }
    var sentStatusFail: UIImage? {
        UIImage(named: "message_status_error")
    }
    
    /// Location
    var defaultThumbnailImage: UIImage? {
        UIImage(named: "map_location_default")
    }
    
    /// ContactCard
    var defaultPortrait: UIImage? {
        UIImage(named: "default_portrait_msg")
    }
    var arrowImage: UIImage? {
        UIImage(named: "contact_card_arrow")
    }
    
}
