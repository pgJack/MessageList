//
//  OnlineDocumentBubbleView.swift
//  String
//
//  Created by 孙浩 on 2023/4/10.
//

import UIKit
import BMMagazine

class OnlineDocumentBubbleView: BubbleView {
    
    lazy var onlineFileInfoView = FileInfoView(maxWidth: 0)
    lazy var thumbnailImgView = ThumbnailImageView()
    lazy var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = BMThemeUtil.onlineDocmentLineColor;
        return line
    }()
    lazy var openButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.setTitle("Open in Beem Docs", for: .normal)
        button.setTitleColor(UIColor(light: BMThemeUtil.beemMainColor, dark: UIColor(0xFFFFFF)), for: .normal)
        return button
    }()

    override var bubbleModel: BubbleModel? {
        didSet {
            guard let onlineDocBubble = bubbleModel as? OnlineDocumentBubbleModel else {
                onlineFileInfoView.update(typeImage: nil, file: nil)
                return
            }
            let image: UIImage? = .bubble.defaultPortrait
            onlineFileInfoView.update(typeImage: image, file: onlineDocBubble.fileName)
            if let thumbnailImgURLString = onlineDocBubble.thumbnailViewUrl {
                thumbnailImgView.sd_setImage(with: URL(string: thumbnailImgURLString))
            } else {
                thumbnailImgView.sd_setImage(with: URL(string: ""))
            }
        }
    }
    
    override func setupBubbleSubviews() {
        super.setupBubbleSubviews()
        
        addSubview(onlineFileInfoView)
        addSubview(thumbnailImgView)
        addSubview(lineView)
        addSubview(openButton)
        
        let fileViewHeight = FileInfoView.fileInfoHeight
        onlineFileInfoView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(OnlineDocumentBubbleModel.fileInfoViewEdges.top)
            make.leading.trailing.equalToSuperview().inset(OnlineDocumentBubbleModel.fileInfoViewEdges.left)
            make.height.equalTo(fileViewHeight)
        }
        
        thumbnailImgView.snp.makeConstraints { make in
            make.top.equalTo(onlineFileInfoView.snp.bottom).offset(OnlineDocumentBubbleModel.thumbnailTopMargin)
            make.leading.trailing.equalTo(onlineFileInfoView)
            make.height.equalTo(OnlineDocumentBubbleModel.thumbnailViewHeight)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(thumbnailImgView.snp.bottom).offset(OnlineDocumentBubbleModel.lineEdges.top)
            make.leading.trailing.equalToSuperview().inset(OnlineDocumentBubbleModel.lineEdges.left)
            make.height.equalTo(1)
        }
        
        openButton.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(OnlineDocumentBubbleModel.openButtonEdges.left)
            make.bottom.equalToSuperview().offset(-OnlineDocumentBubbleModel.openButtonEdges.bottom)
        }
        
    }

}
