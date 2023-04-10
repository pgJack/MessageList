//
//  FileBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore

class FileBubbleModel: MediaBubbleModel {
    
    override var bubbleViewType: BubbleView.Type {
        FileBubbleView.self
    }
    
    static let fileViewEdge = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
    static let fileViewHeight = FileInfoView.fileInfoHeight
    
    var fileType: String?
    var fileSize: Int64 = 0
    var thumbnailImageUrl: String?
    var placeholderImage: UIImage?
    
    override func setupBubbleContent(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleContent(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let fileContent = rcMessage.content as? RCFileMessage else {
            return
        }
        
        fileType = fileContent.type
        fileSize = fileContent.size
        fileUrl = fileContent.fileUrl
    }
    
    override func setupBubbleSize(rcMessages: [RCMessage], currentUserId: String) {
        super.setupBubbleSize(rcMessages: rcMessages, currentUserId: currentUserId)
        let width = CGFloat.bubble.maxWidth
        let height: CGFloat = FileInfoView.fileInfoHeight
        bubbleContentSize = CGSize(width: ceil(width), height: ceil(height))
    }

}
