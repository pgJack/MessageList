//
//  PollBubbleModel.swift
//  String
//
//  Created by 孙浩 on 2023/4/4.
//

import UIKit
import RongIMLibCore
import BMIMLib

class PollBubbleModel: BubbleModel, BubbleInfoProtocol, BubbleImageProtocol {
    
    var cellType: String {
        message.messageDirection == .send
        ? MessageCellRegister.sender
        : MessageCellRegister.receiver
    }

    var bubbleViewType: BubbleView.Type {
        PollBubbleView.self
    }
    
    var canTapAvatar = true
    lazy var canLongPressAvatarMention = message.conversationType == .group
    lazy var canPanReference = message.conversationType != .person_encrypted
    
    //MARK: Bubble Background Image
    var bubbleForegroundImageType: BubbleImageType {
        return .none
    }
    var bubbleBackgroundImageType: BubbleImageType {
        switch message.messageDirection {
        case .send:
            return isBubbleHighlighted ? .purple_v2 : .purple_v3
        default:
            return isBubbleHighlighted ? .gray : .white
        }
    }
    
    static let cellHeight: CGFloat = 110
    static let pollCellWidth: CGFloat = 264
    static let quectionEdges = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
    static let anonymousEdges = UIEdgeInsets(top: 2, left: 0, bottom: 4, right: 0)
    static let cellOptionEdges = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    static let anpnymousHeight: CGFloat = 17
    
    static let optionCellMarginHoriz: CGFloat = 12
    static let optionCellMarginVertical: CGFloat = 12
    static let optionCellIconWidth: CGFloat = 18
    static let optionCellIconTitleSpec: CGFloat = 8
    static let cellTitleWidth = PollBubbleModel.pollCellWidth - 2 * optionCellMarginHoriz
    static let cellOptionWidth = cellTitleWidth - optionCellIconWidth - optionCellIconTitleSpec
    static let viewResultHeight: CGFloat = 42
    
    var pollId: String?
    var question: String?
    var options: [UMBPollOptionModel]?
    var isMultiple: Bool?
    var isAnonymity: Bool?

    required init?(rcMessages: [RCMessage], currentUserId: String) {
        super.init(rcMessages: rcMessages, currentUserId: currentUserId)
        guard let rcMessage = rcMessages.first,
              let pollContent = rcMessage.content as? UMBPollMessage else {
            return
        }
        
        pollId = pollContent.pollId
        question = pollContent.question
        options = pollContent.options
        isMultiple = pollContent.isMultiple
        isAnonymity = pollContent.isAnonymity

        let height = getMessageHeight()
        bubbleContentSize = CGSize(width: ceil(PollBubbleModel.pollCellWidth), height: ceil(height))
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    
    private func getMessageHeight() -> CGFloat {
        var height: CGFloat = 0
        if let tempQuestion = question, !tempQuestion.isEmpty {
            let textRect = PollBubbleModel.getStringSize(tempQuestion, maxWidth: PollBubbleModel.cellTitleWidth, font: .systemFont(ofSize: 15))
            height += textRect.size.height + PollBubbleModel.quectionEdges.top + PollBubbleModel.quectionEdges.bottom
        }
        if let anonymity = isAnonymity, anonymity {
            height += PollBubbleModel.anonymousEdges.top + PollBubbleModel.anpnymousHeight + PollBubbleModel.anonymousEdges.bottom - PollBubbleModel.quectionEdges.bottom
        }
        options?.forEach({ optionModel in
            if (!optionModel.optionText.isEmpty) {
                let textRect = PollBubbleModel.getStringSize(optionModel.optionText, maxWidth: PollBubbleModel.cellOptionWidth, font: .systemFont(ofSize: 14))
                height += (textRect.size.height + PollBubbleModel.cellOptionEdges.top + PollBubbleModel.cellOptionEdges.bottom)
            }
        })
        return height + PollBubbleModel.viewResultHeight
    }
    
    static func getStringSize(_ text: String, maxWidth: CGFloat, font: UIFont) -> CGRect {
        let maxSize = CGSize(width: maxWidth, height: CGFloat.greatestFiniteMagnitude)
        let attributes = [NSAttributedString.Key.font: font]
        let stringRect = text.boundingRect(with: maxSize, options: [.truncatesLastVisibleLine, .usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)
        return stringRect
    }
}
