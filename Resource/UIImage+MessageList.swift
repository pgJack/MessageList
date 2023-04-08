//
//  UIImage+MessageList.swift
//  String
//
//  Created by Noah on 2023/3/18.
//

import UIKit

// 气泡背景图片类型
enum BubbleImageType {
    case none, white, purple_v1, purple_v2, purple_v3, gray, opaque, square_opaque
}

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
    
    func bubbleImage(_ type: BubbleImageType) -> UIImage? {
        var image: UIImage? = nil
        switch type {
        case .white:
            image = UIImage(named: "bubble_image_white")
        case .purple_v1:
            image = UIImage(named: "bubble_image_purple_v1")
        case .purple_v2:
            image = UIImage(named: "bubble_image_purple_v2")
        case .purple_v3:
            image = UIImage(named: "bubble_image_purple_v3")
        case .gray:
            image = UIImage(named: "bubble_image_gray")
        case .opaque:
            image = UIImage(named: "bubble_image_opaque")
        case .square_opaque:
            image = UIImage(named: "bubble_image_square_opaque")
        default:
            break
        }
        return image
    }
    
    /// Location
    var defaultLocationThumbnail: UIImage? {
        UIImage(named: "map_location_default")
    }
    
    /// ContactCard
    var defaultPortrait: UIImage? {
        UIImage(named: "default_portrait_msg")
    }
    var arrowImage: UIImage? {
        UIImage(named: "contact_card_arrow")
    }
    
    /// File
    var fileTypeIcon: UIImage? {
        // TODO: - fileIcon 需要实现
        UIImage(named: "fileTypeIcon")
    }
    
}
