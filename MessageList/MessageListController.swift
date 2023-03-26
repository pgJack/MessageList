//
//  MessageListController.swift
//  String
//
//  Created by Noah on 2023/3/16.
//

import UIKit
import BMMagazine

private let kMessageListCacheKey = "kMessageList"

class MessageListController: BMBaseViewController, MessageListControllerProtocol {
    
    private var _messageList: MessageList
    private var _viewModel: MessageListViewModel
    
    private lazy var _collectionViewLayout = {
        let layout = MessageListCollectionViewLayout()
        layout.viewModel = _viewModel
        return layout
    }()
    private lazy var _collectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: _collectionViewLayout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.alwaysBounceVertical = true
        return view
    }()
    
    var controller: UIViewController { self }
    var collectionView: UICollectionView { _collectionView }
    var messageList: MessageListProtocol { _messageList }
    
    required init?(currentUserInfo: UserInfoProtocol, rcConversation: RCConversationDescriptionProtocol, listType: MessageListType, anchorMessage: AnchorMessageProtocol?) {
        guard let conversation = Conversation(rcConversation) else { return nil }
        let messageList = MessageList(currentUserInfo: currentUserInfo, conversation: conversation, listType: listType)
        _messageList = messageList
        _viewModel = MessageListViewModel(messageList: messageList, anchorMessage: anchorMessage)
        super.init(nibName: nil, bundle: nil)
        _viewModel.controller = self
    }
    
    required init?(coder: NSCoder) {
        guard let cacheData = coder.decodeObject(forKey: kMessageListCacheKey) as? Data else { return nil }
        guard let cacheList = try? JSONDecoder().decode(MessageList.self, from: cacheData) else { return nil }
        _messageList = cacheList
        _viewModel = MessageListViewModel(messageList: cacheList, anchorMessage: nil)
        super.init(coder: coder)
        _viewModel.controller = self
    }
    
    override func encode(with coder: NSCoder) {
        guard let cacheData = try? JSONEncoder().encode(_messageList) else { return }
        coder.encode(cacheData, forKey: kMessageListCacheKey)
    }
    
    private let startDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSubviews()
        _viewModel.onViewDidLoad()
        print("????? 1 \(Date().timeIntervalSince1970-startDate.timeIntervalSince1970)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _viewModel.onViewWillAppear(animated)
        DispatchQueue.main.async {
            print("????? 2 \(Date().timeIntervalSince1970-self.startDate.timeIntervalSince1970)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _viewModel.onViewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        _viewModel.onViewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        _viewModel.onViewDidDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _viewModel.onViewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        _viewModel.onReceiveMemoryWarning()
    }
    
}

//MARK: Initial
extension MessageListController {
    
    func initialSubviews() {
        navigationItem.leftBarButtonItem = nil
        view.backgroundColor = .lightGray
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
        
}
