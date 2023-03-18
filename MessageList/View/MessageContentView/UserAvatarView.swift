//
//  UserAvatarView.swift
//  BMIMModule
//
//  Created by Noah on 2022/11/28.
//

import UIKit

class UserAvatarView: UIView {
    
    private(set) lazy var avatarImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.layer.cornerRadius = .bubble.avatarRadius
        imgView.layer.masksToBounds = true
        imgView.isUserInteractionEnabled = true
        addSubview(imgView)
        imgView.snp.makeConstraints { make in
            make.centerY.centerX.equalToSuperview()
            make.size.equalTo(CGSize.bubble.avatarSize)
        }
        return imgView
    }()
    
    func updateAvatar(url: String?, placeholder: UIImage?) {
        var remoteUrl: URL?
        if let url = url {
            remoteUrl = URL(string: url)
        }
        avatarImageView.sd_setImage(with: remoteUrl, placeholderImage: placeholder)
    }
    
}
