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
    private var unreadLineHeight: CGFloat {
        isUnreadLineViewHidden ? 0 : CGFloat.bubble.unreadLineHeight
    }
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
    private var dateViewHeight: CGFloat {
        isDateViewHidden ? 0 : CGFloat.bubble.dateViewHeight
    }
    private(set) lazy var dateView: MessageDateView = {
        let view = MessageDateView()
        addSubview(view)
        view.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(unreadLineHeight)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(CGFloat.bubble.dateViewHeight)
        }
        return view
    }()
    
    // 选中按钮视图
    var checkBoxStatus: CheckBoxStatus { checkBoxView.status }
    private var isCheckBoxViewHidden = true
    private var checkBoxViewWidth: CGFloat {
        isCheckBoxViewHidden ? 0 : CGFloat.bubble.checkBoxWidth
    }
    private(set) lazy var checkBoxView: CheckBoxView = {
        let view = CheckBoxView()
        addSubview(view)
        view.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.top.equalTo(dateView.snp.bottom)
            make.bottom.equalToSuperview()
            make.width.equalTo(CGFloat.bubble.checkBoxWidth)
        }
        return view
    }()

    // 消息详情容器
    private(set) lazy var detailView: UIView? = nil
    func setupDetailView(_ detailView: UIView) {
        self.detailView = detailView
        addSubview(detailView)
        remakeDetailViewLayout()
    }
    
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
        remakeDateViewLayout()
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
        remakeDateViewLayout()
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
        detailView?.isUserInteractionEnabled = !isHidden
        remakeDetailViewLayout()
        layoutIfNeeded(animated: animated)
    }
    
}

//MARK: DetailView Layout
extension MessageBaseView {
    
    private func remakeDateViewLayout() {
        guard !isDateViewHidden else { return }
        dateView.snp.remakeConstraints { make in
            make.top.equalToSuperview().offset(unreadLineHeight)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(CGFloat.bubble.dateViewHeight)
        }
    }
    
    private func remakeDetailViewLayout() {
        detailView?.snp.remakeConstraints { make in
            make.top.lessThanOrEqualToSuperview().offset(dateViewHeight + unreadLineHeight)
            make.leading.equalToSuperview().offset(checkBoxViewWidth)
            make.trailing.bottom.equalToSuperview()
        }
    }
    
}
