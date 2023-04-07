//
//  HQVoiceBubbleView.swift
//  String
//
//  Created by 孙浩 on 2023/4/7.
//

import UIKit

class HQVoiceBubbleView: BubbleView {
    
    static let voice_Margin = 10
    static let voice_Padding = 8
    static let voice_Right_Padding = 17
    static let play_Voice_View_Width = 24
    static let voiceWidth: CGFloat = CGFloat(play_Voice_View_Width + voice_Padding + voice_Right_Padding + voice_Margin)
    static let progressWidth = HQVoiceBubbleModel.voiceBubbleWidth - voiceWidth - HQVoiceBubbleModel.avatarSideSize.width
    
    lazy var progressView = VoiceProgressView()
    lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = HQVoiceBubbleModel.avatarSideSize.width / 2;
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    lazy var voiceDurationLabel: UILabel = {
        let label = UILabel()
//        label.textAlignment = [RCKitUtility isRTL] ? NSTextAlignmentCenter : NSTextAlignmentLeft;
//        label.textColor = DYCOLOR(HEXCOLOR(0x111f2c), UMB_SUBTITLE_DCOLOR);
        label.textAlignment = .left
        label.textColor = UIColor(0x111f2c)
        label.font = .systemFont(ofSize: 10)
        return label
    }()
    
    
    override var bubbleModel: BubbleModel? {
        didSet {
            guard let voiceBubble = bubbleModel as? HQVoiceBubbleModel else {
                avatarImageView.image = nil
                voiceDurationLabel.text = nil
                progressView.resetStonesSite(width: HQVoiceBubbleView.progressWidth)
                return
            }
            
            // TODO: - update avatar
//            avatarImageView.image = UIImage()
            
            progressView.soundSource = voiceBubble.message.messageDirection
            progressView.resetStonesSite(width: HQVoiceBubbleView.progressWidth)
            updateSubViews(with: TimeInterval(voiceBubble.duration))
        }
    }
    
    func updateSubViews(with process: TimeInterval) {
        let total = (bubbleModel as? HQVoiceBubbleModel)?.duration ?? 1
        let minValue = min(Int(process), total)
        let scale = max(0, minValue) / total
        
        progressView.proceed(rate: CGFloat(scale))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        voiceDurationLabel.text = formatter.string(from: Date(timeIntervalSince1970: TimeInterval(minValue)))
        voiceDurationLabel.sizeToFit()
    }
    
    override func setupBubbleSubviews() {
        super.setupBubbleSubviews()
        
        addSubview(avatarImageView)
        addSubview(progressView)
        addSubview(voiceDurationLabel)
        
        avatarImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(HQVoiceBubbleModel.avatarSendEdge.left)
            make.size.equalTo(HQVoiceBubbleModel.avatarSideSize)
        }
        
        // TODO: - 这里缺少一个点击播放按钮
        let offsetLeading = HQVoiceBubbleView.voice_Margin + HQVoiceBubbleView.play_Voice_View_Width + HQVoiceBubbleView.voice_Padding
        
        progressView.snp.makeConstraints { make in
            make.leading.equalTo(avatarImageView.snp.trailing).offset(offsetLeading)
            make.width.equalTo(HQVoiceBubbleView.progressWidth)
            make.centerY.equalTo(avatarImageView)
            make.height.equalTo(VoiceProgressView.progressHeight)
        }
        
        voiceDurationLabel.snp.makeConstraints { make in
            make.leading.equalTo(progressView)
//            make.leading.equalTo(self.playVoiceView.mas_trailing).offset(Voice_Padding);
            make.bottom.equalToSuperview().offset(-10);
        }
    }

}
