//
//  CheckBoxView.swift
//  BMIMModule
//
//  Created by Noah on 2022/11/28.
//

import UIKit

enum CheckBoxStatus: Int {
    case checked, unchecked, disabled
}

class CheckBoxView: UIView {
    
    //MARK: 设置选中框状态
    var status: CheckBoxStatus = .unchecked {
        didSet {
            switch status {
            case .checked:
                iconView.image = .bubble.checkBoxChecked
            case .unchecked:
                iconView.image = .bubble.checkBoxUnchecked
            case .disabled:
                iconView.image = .bubble.checkBoxDisabled
            }
        }
    }
    
    lazy var iconView: UIImageView = {
        let imgView = UIImageView(image: .bubble.checkBoxUnchecked)
        addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.trailing.equalToSuperview().offset(-CGFloat.bubble.checkBoxImageTrailing)
            make.size.equalTo(CGSize.bubble.checkBoxImageSize)
        }
        return imgView
    }()
    
}
