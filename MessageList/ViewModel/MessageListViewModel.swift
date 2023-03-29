//
//  MessageListViewModel.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import UIKit

class MessageListViewModel: NSObject {
    
    /// 消息列表模型
    var messageList: MessageListProtocol?
    
    /// 消息列表视图控制器
    weak var controller: MessageListControllerProtocol?
    /// 消息列表容器视图
    var collectionView: UICollectionView? { controller?.collectionView }
    var collectionViewLayout: MessageListCollectionViewLayout? { collectionView?.collectionViewLayout as? MessageListCollectionViewLayout }
    
    /// 消息数据源接口
    lazy var dataSource: MessageDataSource? = MessageDataSource(viewModel: self, messageList: messageList)
    
    /// 消息数据源
    private var _bubbleModels: [BubbleModel] { dataSource?.bubbleModels ?? [] }
    /// 消息定位，滚动到锚点位置
    private var _anchorMessage: AnchorMessageProtocol?
    
    /// 控制器是否加载完成
    private lazy var _collectionViewHasLoaded = false
    /// 强制刷新全部数据源
    private lazy var _forceResetBubbleModels = true
        
    /// 所有气泡视图
    private lazy var _bubbleViewCache = [Int: BubbleView]()
    
    //MARK: LifeCycle
    init(messageList: MessageListProtocol, anchorMessage: AnchorMessageProtocol?) {
        self.messageList = messageList
        _anchorMessage = anchorMessage
    }
    
    func onViewDidLoad() {
        guard let collectionView = collectionView else { return }
        initializeDataSource()
        MessageCellRegister.registerCells(for: collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func onViewWillAppear(_ animated: Bool) { }
    
    func onViewDidAppear(_ animated: Bool) { }
    
    func onViewWillDisappear(_ animated: Bool) { }
    
    func onViewDidDisappear(_ animated: Bool) { }
    
    func onViewDidLayoutSubviews() {
        guard !_collectionViewHasLoaded else { return }
        _collectionViewHasLoaded = true
        firstLayout()
    }
    
    func onReceiveMemoryWarning() {
        _bubbleViewCache.removeAll()
    }
    
}

//MARK: Layout Interface
extension MessageListViewModel {
    
    func onCollectionViewPrepareLayout() {
        guard _forceResetBubbleModels else { return }
        _forceResetBubbleModels = false
        resetBubbleLayouts()
    }
    
}

//MARK: Layout Method
private extension MessageListViewModel {
    
    func firstLayout() {
        guard let collectionView = collectionView else { return }
        collectionView.layoutIfNeeded()
        scorllToBottom()
        reloadCollectionView()
    }
    
    func resetBubbleLayouts() {
        guard let collectionViewLayout = collectionViewLayout else { return }
        var totalHeight: CGFloat = 0
        var bubbleFrames = [CGRect]()
        let x: CGFloat = 0
        let width = collectionViewLayout.layoutWidth
        _bubbleModels.forEach { bubble in
            let y = totalHeight
            /// 气泡内容高度
            var height = bubble.bubbleHeight
            /// 显示 unreadLine，高度增加
            if bubble.shownUnreadLine {
                height += .bubble.unreadLineHeight
            }
            /// 显示 date，高度增加
            if bubble.dateText != nil {
                height += .bubble.dateViewHeight
            }
            totalHeight += height
            bubbleFrames.append(CGRect(x: x, y: y, width: width, height: height))
        }
        collectionViewLayout.layoutHeight = totalHeight
        collectionViewLayout.bubbleFrames = bubbleFrames
    }
    
    func bubbleView<T: BubbleModel>(forModel bubble: T) -> BubbleView? {
        let messageId = bubble.message.messageId
        var bubbleView = _bubbleViewCache[messageId]
        if bubbleView == nil {
            bubbleView = bubble.bubbleViewType.init(bubble: bubble)
            bubbleView?.bubbleModel = bubble
            _bubbleViewCache[messageId] = bubbleView
        }
        return bubbleView
    }
    
}

//MARK: DataSource Interface
extension MessageListViewModel {
    
    func dataSourceDidReset(unreadCount: Int32 = 0) {
        _forceResetBubbleModels = true
        reloadCollectionView()
    }
    
}

//MARK: DataSource Method
private extension MessageListViewModel {
    
    func initializeDataSource() {
        if let anchorMessage = _anchorMessage {
            dataSource?.anchor(at: anchorMessage)
        } else {
            dataSource?.anchorAtFirstUnreadMessage()
        }
    }
    
}

//MARK: CollectionView DataSource
extension MessageListViewModel: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        _bubbleModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard _collectionViewHasLoaded else {
            return collectionView.dequeueReusableCell(withReuseIdentifier: .cellType.placeholder, for: indexPath)
        }
        let bubbleContent = _bubbleModels[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: bubbleContent.cellType, for: indexPath)
        return cell
    }
    
}

//MARK: CollectionView Delegate
extension MessageListViewModel: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        UIView.performWithoutAnimation {
            let bubbleModel = _bubbleModels[indexPath.row]
            
            guard let cell = cell as? MessageBaseCell else { return }
            cell.updateSubviewsOnReuse(bubbleModel)
            
            guard let cell = cell as? MessageUserCell else { return }
            cell.addBubbleView(bubbleView(forModel: bubbleModel))
            cell.updateCheckBox(isHidden: true, status: .disabled, animated: false)
            print("cell display")
            guard let cell = cell as? MessageSenderCell else { return }
            cell.updateSentStatus(bubbleModel.message.sentStatus,
                                  deliveredProgress: bubbleModel.message.deliveredProgress,
                                  readProgress: bubbleModel.message.readProgress)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MessageUserCell else { return }
        cell.removeBubbleView()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
}

//MARK: CollectionView Control
extension MessageListViewModel {
    
    func reloadCollectionView() {
        guard _collectionViewHasLoaded else { return }
        guard let collectionView = collectionView else { return }
        collectionView.reloadData()
    }
    
    func scorllToBottom() {
        guard let collectionView = collectionView else { return }
        let height = collectionView.frame.size.height
        let contentBottom = collectionView.adjustedContentInset.bottom
        let contentSize = collectionView.contentSize.height
        collectionView.setContentOffset(CGPoint(x: 0, y: max(contentSize - height + contentBottom, 0)), animated: false)
    }
    
}

