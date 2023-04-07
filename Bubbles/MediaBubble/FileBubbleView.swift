//
//  FileBubbleView.swift
//  String
//
//  Created by 孙浩 on 2023/4/7.
//

import UIKit

class FileBubbleView: BubbleView {

    lazy var fileView: FileInfoView = FileInfoView(maxWidth: 0)
    
    override var bubbleModel: BubbleModel? {
        didSet {
            guard let fileBubble = bubbleModel as? FileBubbleModel else {
                fileView.update(typeImage: nil, file: nil)
                return
            }
            let image: UIImage? = .bubble.defaultPortrait
            fileView.update(typeImage: image, file: fileBubble.fileName)
        }
    }
    
    override func setupBubbleSubviews() {
        super.setupBubbleSubviews()
        
        addSubview(fileView)
        fileView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(FileBubbleModel.fileViewEdge.left)
            make.trailing.equalToSuperview().offset(-FileBubbleModel.fileViewEdge.right)
            make.top.equalToSuperview().offset(FileBubbleModel.fileViewEdge.top)
            make.height.equalTo(FileBubbleModel.fileViewHeight)
        }
    }
}
