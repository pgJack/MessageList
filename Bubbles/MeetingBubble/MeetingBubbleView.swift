//
//  MeetingBubbleView.swift
//  String
//
//  Created by 孙浩 on 2023/4/10.
//

import UIKit
import BMMagazine

class MeetingBubbleView: BubbleView {
    
    private static let titleBgHeight: CGFloat = 40
    private static let titleLabelMargin: CGFloat = 16
    private static let labEdges = UIEdgeInsets(top: 16, left: 8, bottom: 0, right: 16)
    private static let iconEdges = UIEdgeInsets(top: 16, left: 12, bottom: 0, right: 0)
    private static let iconSize = CGSize(width: 20, height: 20)
    private static let buttonMargin: CGFloat = 16
    private static let buttonBottomMargin: CGFloat = 26
    private static let buttonHeight: CGFloat = 36
    
    lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 1
        view.layer.borderColor = BMThemeUtil.messageLineColor.cgColor
        view.clipsToBounds = true
        view.backgroundColor = BMThemeUtil.meetingMessageBackgroundColor
        return view
    }()
    
    lazy var titleBackgroundView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(light: UIColor(0x7962D9), dark: .clear)
        imageView.image = .bubble.meetingTitleImage
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "meeting_book_invite_meeting_title"
        label.textColor = BMThemeUtil.cellHeaderNameTitleColor;
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    lazy var topicLab: UILabel = {
        let label = UILabel()
        label.textColor = BMThemeUtil.messageTitleColor;
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 15)
        return label
    }()
        
    lazy var timeLab: UILabel = {
        let label = UILabel()
        label.textColor = BMThemeUtil.messageTitleColor;
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    lazy var meetingNumberLab: UILabel = {
        let label = UILabel()
        label.textColor = BMThemeUtil.messageTitleColor;
        label.font = .systemFont(ofSize: 15)
        return label
    }()

    lazy var passwordLab: UILabel = {
        let label = UILabel()
        label.textColor = BMThemeUtil.messageTitleColor;
        label.font = .systemFont(ofSize: 15)
        return label
    }()
    
    lazy var meetingBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Join", for: .normal)
        button.backgroundColor = .clear
        button.layer.borderColor = BMThemeUtil.beemMainColor.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        button.setTitleColor(BMThemeUtil.beemMainColor, for: .normal)
        return button
    }()
    
    lazy var topicIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .bubble.topicIcon
        return imageView
    }()
    
    lazy var timeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .bubble.timeIcon
        return imageView
    }()
    
    lazy var idIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .bubble.idIcon
        return imageView
    }()
    
    lazy var pwdIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .bubble.pwdIcon
        return imageView
    }()

    override var bubbleModel: BubbleModel? {
        didSet {
            guard let meetingBubble = bubbleModel as? MeetingBubbleModel else {
                return
            }
            
            topicLab.text = meetingBubble.subject
            timeLab.text = meetingBubble.meetingDate
            meetingNumberLab.text = meetingBubble.meetingNumber
            passwordLab.text = meetingBubble.passwd
        }
    }
    
    override func setupBubbleSubviews() {
        super.setupBubbleSubviews()
        
        addSubview(containerView)
        containerView.addSubview(titleBackgroundView)
        titleBackgroundView.addSubview(titleLabel)
        containerView.addSubview(topicLab)
        containerView.addSubview(timeLab)
        containerView.addSubview(meetingNumberLab)
        containerView.addSubview(passwordLab)
        containerView.addSubview(meetingBtn)
        containerView.addSubview(topicIcon)
        containerView.addSubview(timeIcon)
        containerView.addSubview(idIcon)
        containerView.addSubview(pwdIcon)
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        
        titleBackgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(MeetingBubbleView.titleBgHeight)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(MeetingBubbleView.titleLabelMargin)
        }
        
        topicIcon.snp.makeConstraints { make in
            make.top.equalTo(titleBackgroundView.snp.bottom).offset(MeetingBubbleView.iconEdges.top)
            make.leading.equalToSuperview().offset(MeetingBubbleView.iconEdges.left)
            make.size.equalTo(MeetingBubbleView.iconSize)
        }
        
        topicLab.snp.makeConstraints { make in
            make.top.equalTo(titleBackgroundView.snp.bottom).offset(MeetingBubbleView.labEdges.top)
            make.leading.equalTo(topicIcon.snp.trailing).offset(MeetingBubbleView.labEdges.left)
            make.trailing.equalToSuperview().offset(-MeetingBubbleView.labEdges.right)
            make.height.equalTo(MeetingBubbleModel.subjectHeight)
        }
        
        timeIcon.snp.makeConstraints { make in
            make.top.equalTo(timeLab)
            make.leading.size.equalTo(topicIcon)
        }
        
        timeLab.snp.makeConstraints { make in
            make.top.equalTo(topicLab.snp.bottom).offset(MeetingBubbleView.labEdges.top)
            make.leading.trailing.equalTo(topicLab)
            make.height.equalTo(MeetingBubbleModel.dateHeight)
        }
        
        idIcon.snp.makeConstraints { make in
            make.centerY.equalTo(meetingNumberLab)
            make.leading.size.equalTo(topicIcon)
        }
        
        meetingNumberLab.snp.makeConstraints { make in
            make.top.equalTo(timeLab.snp.bottom).offset(MeetingBubbleView.labEdges.top)
            make.leading.trailing.equalTo(topicLab)
            make.height.equalTo(MeetingBubbleModel.content_height)
        }
        
        passwordLab.snp.makeConstraints { make in
            make.top.equalTo(meetingNumberLab.snp.bottom).offset(MeetingBubbleView.labEdges.top)
            make.leading.trailing.equalTo(topicLab)
            make.height.equalTo(MeetingBubbleModel.passwordHeight)
        }
        
        pwdIcon.snp.makeConstraints { make in
            make.top.equalTo(idIcon.snp.bottom).offset(MeetingBubbleView.iconEdges.top)
            make.leading.size.equalTo(topicIcon)
        }
        
        meetingBtn.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(MeetingBubbleView.buttonMargin)
            make.bottom.equalToSuperview().offset(-MeetingBubbleView.buttonBottomMargin)
            make.height.equalTo(MeetingBubbleView.buttonHeight)
        }
    }

}

