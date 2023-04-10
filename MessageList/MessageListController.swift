//
//  MessageListController.swift
//  String
//
//  Created by Noah on 2023/3/16.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import BMMagazine

private let kMessageListCacheKey = "kMessageList"

class MessageListController: BMBaseViewController, MessageListControllerProtocol {
        
    private let disposeBag = DisposeBag()
    
    private var _viewModel: MessageListViewModel
    
    private lazy var _collectionViewLayout = {
        let layout = MessageListCollectionViewLayout()
        layout.viewModel = _viewModel
        return layout
    }()
    private lazy var _collectionView = {
        let view = MessageListCollectionView(frame: .zero, collectionViewLayout: _collectionViewLayout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.alwaysBounceVertical = true
        view.viewModel = _viewModel
        return view
    }()
    
    var controller: UIViewController { self }
    var collectionView: UICollectionView { _collectionView }
    var readonly: Bool {
        get { _viewModel.readonly }
        set { _viewModel.readonly = newValue }
    }
    
    required init?(currentUserInfo: UserInfoProtocol, rcConversation: RCConversationDescriptionProtocol, listType: MessageListType, anchorMessage: AnchorMessageProtocol?) {
        guard let conversation = Conversation(rcConversation) else { return nil }
        let messageList = MessageList(currentUserInfo: currentUserInfo, conversation: conversation, listType: listType)
        _viewModel = MessageListViewModel(messageList: messageList, anchorMessage: anchorMessage)
        super.init(nibName: nil, bundle: nil)
        _viewModel.controller = self
    }
    
    required init?(coder: NSCoder) {
        guard let cacheData = coder.decodeObject(forKey: kMessageListCacheKey) as? Data else { return nil }
        guard let cacheList = try? JSONDecoder().decode(MessageList.self, from: cacheData) else { return nil }
        _viewModel = MessageListViewModel(messageList: cacheList, anchorMessage: nil)
        super.init(coder: coder)
        _viewModel.controller = self
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
    
    deinit {
        print("---> Message List Deinit")
    }
    
}

//MARK: Initial
extension MessageListController {
    
    func initialSubviews() {
        navigationItem.leftBarButtonItem = nil
        view.backgroundColor = .lightGray
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.leading.trailing.top.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalToSuperview()
        }
        
        let button = UIButton(frame: .init(origin: .zero, size: .init(width: 44, height: 44)))
        button.setTitle("123", for: .normal)
        button.rx.tap.asDriver().drive(onNext: { [weak self] in
            guard let `self` = self else { return }
            self._viewModel.dataSource?.loadMoreOlderMessages()
        }).disposed(by: disposeBag)
        let item = UIBarButtonItem(customView: button)
        navigationItem.setRightBarButton(item, animated: false)
    }
        
}
