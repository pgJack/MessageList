//
//  ContactCardBubbleView.swift
//  String
//
//  Created by 孙浩 on 2023/4/6.
//

import UIKit
import SDWebImage

class ContactCardBubbleView: BubbleView {

    private static let margin: CGFloat = 12
    private static let portraitHeight: CGFloat = 40
    
    lazy var portraitImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = ContactCardBubbleView.portraitHeight / 2
        imageView.image = .bubble.defaultPortrait
        return imageView
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.lineBreakMode = .byTruncatingMiddle
//        label.textColor = DYCOLOR(HEXCOLOR(0x1E242A), UMB_TITLE_DCOLOR)
        return label
    }()

    lazy var arrowView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .bubble.arrowImage
        return imageView
    }()
    
    lazy var lineView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
//        view.backgroundColor = BMThemeUtil.callSeparatorLineColor
        return view
    }()
    
    lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.text = "ContactCard"
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    

    override var bubbleModel: BubbleModel? {
        didSet {
            guard let cardBubble = bubbleModel as? ContactCardBubbleModel else {
                portraitImageView.image = nil
                nameLabel.text = nil
                return
            }
            if let portraitUrl = cardBubble.portraitUrl, let url = URL(string: portraitUrl) {
                portraitImageView.sd_setImage(with: url, placeholderImage: .bubble.defaultPortrait)
            }
            nameLabel.text = cardBubble.cardName
        }
    }
    
    override func setupBubbleSubviews() {
        super.setupBubbleSubviews()
        addSubview(portraitImageView)
        addSubview(nameLabel)
        addSubview(arrowView)
        addSubview(lineView)
        addSubview(typeLabel)
        
        portraitImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(ContactCardBubbleView.margin)
            make.leading.equalToSuperview().offset(ContactCardBubbleView.margin)
            make.width.height.equalTo(ContactCardBubbleView.portraitHeight)
        }
        
        arrowView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-17)
            make.centerY.equalTo(portraitImageView)
            make.size.equalTo(CGSize(width: 12, height: 12))
        }

        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(portraitImageView.snp.trailing).offset(ContactCardBubbleView.margin)
            make.trailing.equalTo(arrowView.snp.leading).offset(-ContactCardBubbleView.margin)
            make.centerY.equalTo(portraitImageView)
        }
        
        lineView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(ContactCardBubbleView.margin)
            make.top.equalTo(portraitImageView.snp.bottom).offset(ContactCardBubbleView.margin)
            make.height.equalTo(1)
        }
        
        typeLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(ContactCardBubbleView.margin)
            make.top.equalTo(lineView.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }

}
