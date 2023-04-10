//
//  FileInfoView.swift
//  String
//
//  Created by 孙浩 on 2023/4/7.
//

import UIKit

public class FileInfoView: UIView {

    static let fileInfoHeight = FileInfoView.typeIconSize.height + FileInfoView.typeIconEdges.top + FileInfoView.typeIconEdges.bottom
    private static let typeIconEdges = UIEdgeInsets(top: 9, left: 8, bottom: 9, right: 0)
    private static let typeIconSize = CGSize(width: 42, height: 42)
    private static let fileNameEdges = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    private lazy var typeIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        return imageView
    }()
    
    private lazy var fileNameLabel: UILabel = {
        let label = UILabel()
        label.font = .bubble.normal
        label.numberOfLines = 2
        label.textColor = .black
        label.lineBreakMode = .byTruncatingTail
//        label.textColor = DYCOLOR(HEXCOLOR(0x1E242A), UMB_TITLE_DCOLOR);
        return label
    }()
    
    public convenience init(maxWidth: CGFloat) {
        self.init(frame:CGRect(x: 0, y: 0, width: maxWidth, height: 0))
        setupFileInfoUI()
    }
    
    public func update(typeImage: UIImage?, file name: String?) {
        typeIcon.image = typeImage
        fileNameLabel.text = name
    }
    
    private func setupFileInfoUI() {
        addSubview(typeIcon)
        addSubview(fileNameLabel)
        
        typeIcon.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(FileInfoView.typeIconEdges.top)
            make.leading.equalToSuperview().offset(FileInfoView.typeIconEdges.left)
            make.bottom.equalToSuperview().offset(-FileInfoView.typeIconEdges.bottom)
            make.size.equalTo(FileInfoView.typeIconSize)
        }
        
        fileNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(typeIcon)
            make.leading.equalTo(typeIcon.snp.trailing).offset(FileInfoView.fileNameEdges.left)
            make.trailing.equalToSuperview().offset(-FileInfoView.fileNameEdges.right)
        }
    }
    

}
