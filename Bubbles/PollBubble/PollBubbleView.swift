//
//  PollBubbleView.swift
//  String
//
//  Created by 孙浩 on 2023/4/10.
//

import UIKit
import BMMagazine
import BMIMLib

class PollBubbleView: BubbleView {
    
    private static let margin: CGFloat = 12
    private static let portraitHeight: CGFloat = 40
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = BMThemeUtil.cellHeaderNameTitleColor
        label.text = ""
        return label
    }()
    
    lazy var anonymousTipLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.text = "Anonymous Voting"
        label.textColor = BMThemeUtil.cellHeaderNameTitleColor
        return label
    }()
    
    lazy var pollBackView: UIView = {
        let view = UIView()
        view.backgroundColor = BMThemeUtil.meetingMessageBackgroundColor
        return view
    }()
    
    lazy var viewResultBtn: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        button.setTitle("Vote", for: .normal)
        button.setTitleColor(BMThemeUtil.pollMessageViewResultTitleColor, for: .normal)
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        // TODO: - UMBOptionCell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UMBPollOptionCellID")
//        [tableView registerClass:UMBOptionCell.class forCellReuseIdentifier:UMBPollOptionCellID];
        return tableView
    }()
    

    override var bubbleModel: BubbleModel? {
        didSet {
            guard let pollBubble = bubbleModel as? PollBubbleModel else {
                return
            }
            titleLabel.text = pollBubble.question
            tableView.reloadData()
            
            if bubbleModel?.message.messageDirection == .send {
                titleLabel.textColor = BMThemeUtil.cellHeaderNameTitleColor
                anonymousTipLabel.textColor = UIColor(0xFFFFFF, alpha: 0.6)
            } else {
                titleLabel.textColor = BMThemeUtil.messageTitleColor
                anonymousTipLabel.textColor = BMThemeUtil.messageDigestTitleColor
            }
            
            if let anonymity = pollBubble.isAnonymity, anonymity {
                anonymousTipLabel.isHidden = false
                pollBackView.snp.updateConstraints { make in
                    let topMargin = PollBubbleModel.anonymousEdges.top + PollBubbleModel.anpnymousHeight + PollBubbleModel.anonymousEdges.bottom
                    make.top.equalTo(titleLabel.snp.bottom).offset(topMargin)
                }
            } else {
                anonymousTipLabel.isHidden = true
                pollBackView.snp.updateConstraints { make in
                    make.top.equalTo(titleLabel.snp.bottom).offset(PollBubbleModel.quectionEdges.bottom)
                }
            }
        }
    }
    
    override func setupBubbleSubviews() {
        super.setupBubbleSubviews()
        
        addSubview(titleLabel)
        addSubview(anonymousTipLabel)
        addSubview(pollBackView)
        pollBackView.addSubview(tableView)
        pollBackView.addSubview(viewResultBtn)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(PollBubbleModel.quectionEdges.top)
            make.leading.trailing.equalToSuperview().inset(PollBubbleModel.optionCellMarginHoriz)
        }
        
        anonymousTipLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(PollBubbleModel.anonymousEdges.top)
            make.leading.trailing.equalTo(titleLabel)
            make.bottom.equalTo(pollBackView.snp.top).offset(-PollBubbleModel.anonymousEdges.bottom)
        }

        pollBackView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(PollBubbleModel.quectionEdges.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(pollBackView)
            make.leading.trailing.equalTo(pollBackView)
            make.bottom.equalTo(viewResultBtn.snp.top).offset(4)
        }
        
        viewResultBtn.snp.makeConstraints { make in
            make.leading.trailing.equalTo(pollBackView)
            make.height.equalTo(PollBubbleModel.viewResultHeight)
            make.bottom.equalTo(pollBackView)
        }
    }
}

extension PollBubbleView: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let pollBubble = bubbleModel as? PollBubbleModel else {
            
            return 0
        }
        
        return pollBubble.options?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: - Cell 替换
        let cell = UITableViewCell()
        guard let pollBubble = bubbleModel as? PollBubbleModel, let option = pollBubble.options?[indexPath.row] as? UMBPollOptionModel else {
            return UITableViewCell()
        }
        cell.textLabel?.text = option.optionText
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard let pollBubble = bubbleModel as? PollBubbleModel, let option = pollBubble.options?[indexPath.row] as? UMBPollOptionModel else {
            return 0
        }
        
        let textRect = PollBubbleModel.getStringSize(option.optionText, maxWidth: PollBubbleModel.cellOptionWidth, font: UIFont(name: "HelveticaNeue", size: 14) ?? .systemFont(ofSize: 14))
        let height = textRect.size.height + PollBubbleModel.cellOptionEdges.top + PollBubbleModel.cellOptionEdges.bottom
        return height
    }
}
