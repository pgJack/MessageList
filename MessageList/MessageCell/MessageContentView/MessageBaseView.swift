//
//  MessageBaseView.swift
//  BMIMModule
//
//  Created by Noah on 2022/11/28.
//

import UIKit

//MARK: Interface - 消息内容根视图
class MessageBaseView: UIView {
    
    // 消息日期显示视图
    private var isUnreadLineViewHidden = true
    private(set) lazy var unreadLineView = {
        let view = MessageUnreadLineView()
        addSubview(view)
        view.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(CGFloat.bubble.unreadLineHeight)
        }
        return view
    }()
    
    // 消息日期显示视图
    private var isDateViewHidden = true
    private(set) lazy var dateView: MessageDateView = {
        let view = MessageDateView()
        addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(CGFloat.bubble.unreadLineHeight)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(CGFloat.bubble.dateViewHeight)
        }
        return view
    }()
    
    // 选中按钮视图
    var checkBoxStatus: CheckBoxStatus { checkBoxView.status }
    private var isCheckBoxViewHidden = true
    private(set) lazy var checkBoxView: CheckBoxView = {
        let view = CheckBoxView()
        addSubview(view)
        view.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(detailContainerView.snp.top)
            make.bottom.equalTo(detailContainerView.snp.bottom)
            make.width.equalTo(CGFloat.bubble.checkBoxWidth)
        }
        return view
    }()

    // 消息详情容器
    private(set) lazy var detailContainerView: UIView = {
        let view = UIView()
        addSubview(view)
        view.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
        }
        return view
    }()
    
}

//MARK: Subview Control
extension MessageBaseView {
    
    func setUnreadLine(isHidden: Bool) {
        // 视图状态与即将更改的状态不匹配时，刷视图
        guard isUnreadLineViewHidden != isHidden else {
            return
        }
        isUnreadLineViewHidden = isHidden
        unreadLineView.isHidden = isHidden
        remakeDetailViewLayout()
    }
    
    func setMessageDate(dateText: String?) {
        // 显示 即 刷数据
        let isHidden = dateText == nil
        if !isHidden {
            dateView.dateText = dateText
        }
        // 视图状态与即将更改的状态不匹配时，刷视图
        guard isDateViewHidden != isHidden else {
            return
        }
        isDateViewHidden = isHidden
        dateView.isHidden = isHidden
        remakeDetailViewLayout()
    }
    
    func setCheckBox(isHidden: Bool, status: CheckBoxStatus, animated: Bool) {
        // 显示 即 刷数据
        if !isHidden {
            checkBoxView.status = status
        }
        // 视图状态不匹配时，刷视图
        guard isCheckBoxViewHidden != isHidden else {
            return
        }
        isCheckBoxViewHidden = isHidden
        checkBoxView.isHidden = isHidden
        detailContainerView.isUserInteractionEnabled = isHidden
        remakeDetailViewLayout()
        layoutIfNeeded(animated: animated)
    }
    
}

//MARK: DetailView Layout
extension MessageBaseView {
    
    private func remakeDetailViewLayout() {
        var top: CGFloat = 0
        var leading: CGFloat = 0
        if !isDateViewHidden {
            top += .bubble.dateViewHeight
        }
        if !isUnreadLineViewHidden {
            top += .bubble.unreadLineHeight
        }
        if !isCheckBoxViewHidden {
            leading += .bubble.checkBoxWidth
        }
        detailContainerView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(top)
            make.leading.equalToSuperview().offset(leading)
            make.trailing.bottom.equalToSuperview()
        }
    }
    
}
