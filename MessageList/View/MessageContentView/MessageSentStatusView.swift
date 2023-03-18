//
//  MessageSentStatusView.swift
//  BMIMModule
//
//  Created by Noah on 2022/11/28.
//

import UIKit
import Lottie
import BMMagazine

class MessageSentStatusView: UIButton {
        
    private(set) var sentStatus: MessageSentStatus = .none
    private lazy var deliveredProgress: CGFloat = 0
    private lazy var readProgress: CGFloat = 0

    
    var statusImageView: UIImageView?
    private(set) var progressView: BMMessageReadProgressView?
    var clockView: AnimationView?
        
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if #available(iOS 13.0, *) {
            if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection),
               let clockView = clockView {
                clockView.removeFromSuperview()
                self.clockView = createClockView()
                updateStatus(sentStatus, deliveredProgress: deliveredProgress, readProgress: readProgress)
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
}

//MARK: Update Status
extension MessageSentStatusView {
    
    func updateStatus(_ status: MessageSentStatus, deliveredProgress dScale: CGFloat = 0, readProgress rScale: CGFloat = 0) {
        self.sentStatus = status
        self.deliveredProgress = deliveredProgress
        self.readProgress = readProgress

        isHidden = false
        switch status {
        case .none:
            isHidden = true
        case .sending:
            showClockView()
        case .groupSent, .privateSent:
            showStatusView(.bubble.sentStatusUnread)
        case .delivered:
            showStatusView(.bubble.sentStatusDelivered)
        case .readProgress:
            showProgress(delivered: dScale, read: rScale)
        case .read:
            showStatusView(.bubble.sentStatusRead)
        case .fail:
            showStatusView(.bubble.sentStatusFail)
        }
    }
    
}

//MARK: Update Subview
private extension MessageSentStatusView {
    
    func showStatusView(_ statusImage: UIImage?) {
        clockView?.isHidden = true
        clockView?.stop()
        progressView?.isHidden = true
        if statusImageView == nil {
            statusImageView = createStatusImageView()
        }
        statusImageView?.isHidden = false
        statusImageView?.image = statusImage
    }
    
    func showClockView() {
        statusImageView?.isHidden = true
        progressView?.isHidden = true
        if clockView == nil {
            clockView = createClockView()
        }
        clockView?.isHidden = false
        clockView?.play()
    }
    
    func showProgress(delivered dScale: CGFloat, read rScale: CGFloat) {
        statusImageView?.isHidden = true
        clockView?.isHidden = true
        clockView?.stop()
        if progressView == nil {
            progressView = createProgressView()
        }
        progressView?.isHidden = false
        progressView?.deliverProgress = dScale
        progressView?.readProgress = rScale
    }
    
    func createStatusImageView() -> UIImageView {
        let imageView = UIImageView(frame: bounds)
        addSubview(imageView)
        return imageView
    }
    
    func createProgressView() -> BMMessageReadProgressView {
        let progressView = BMMessageReadProgressView(frame: bounds)
        progressView.isUserInteractionEnabled = false
        addSubview(progressView)
        return progressView
    }
    
    func createClockView () -> AnimationView {
        var fileName = MessageListBundleFile.clockLoadingLight.fileName
        if #available(iOS 13.0, *) {
            if BMAppearance.shared().displayMode == .dark {
                fileName = MessageListBundleFile.clockLoadingDark.fileName
            }
        }
        let view = AnimationView(name: fileName, bundle: .messageList)
        view.frame = bounds
        view.isUserInteractionEnabled = false
        view.loopMode = .loop
        view.animationSpeed = 1
        view.contentMode = .scaleAspectFit
        view.backgroundBehavior = .pauseAndRestore
        addSubview(view)
        return view
    }
    
}
