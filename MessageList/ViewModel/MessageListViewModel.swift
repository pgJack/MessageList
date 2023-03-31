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
    /// 消息列表容器视图布局
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
        if let anchorMessage = _anchorMessage {
            _anchorMessage = nil
            scrollTo(anchor: anchorMessage)
        } else {
            scrollToBottom()
        }
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
            let height = messageCellHeight(for: bubble)
            totalHeight += height
            bubbleFrames.append(CGRect(x: x, y: y, width: width, height: height))
        }
        collectionViewLayout.layoutHeight = totalHeight
        collectionViewLayout.bubbleFrames = bubbleFrames
    }
    
    func insertBubbleLayouts(for bubbles: [BubbleModel], at index: Int) {
        guard let collectionViewLayout = collectionViewLayout else { return }
        var existFrames = collectionViewLayout.bubbleFrames
        guard existFrames.count >= index else { return }
        var totalHeight: CGFloat = 0
        if index > 0 {
            totalHeight = existFrames[index - 1].maxY
        }
        let x: CGFloat = 0
        let width = collectionViewLayout.layoutWidth
        var frames = [CGRect]()
        var addedHeight: CGFloat = 0
        bubbles.forEach { bubble in
            let y = totalHeight
            let height = messageCellHeight(for: bubble)
            totalHeight += height
            addedHeight += height
            frames.append(CGRect(x: x, y: y, width: width, height: height))
        }
        collectionViewLayout.layoutHeight += addedHeight
        for i in index..<existFrames.count {
            var frame = existFrames[i]
            frame.origin.y += addedHeight
            existFrames[i] = frame
        }
        existFrames.insert(contentsOf: frames, at: index)
        collectionViewLayout.bubbleFrames = existFrames
    }
    
    func messageCellHeight(for bubble: BubbleModel) -> CGFloat {
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
        return height
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
    
    func dataSourceDidReset() {
        _forceResetBubbleModels = true
        reloadCollectionView()
    }
    
    func dataSourceDidInsert(_ bubbles: [BubbleModel], at index: Int) {
        let indexPaths = [Int](0..<bubbles.count).map { IndexPath(row: $0, section: 0) }
        guard indexPaths.count > 0 else { return }
        guard let collectionView = collectionView else { return }
        insertBubbleLayouts(for: bubbles, at: index)
        collectionView.performBatchUpdates {
            collectionView.insertItems(at: indexPaths)
        }
    }
        
}

//MARK: DataSource Method
private extension MessageListViewModel {
    
    func initializeDataSource() {
        if let anchorMessage = _anchorMessage, anchorMessage.anchorMessageId > 0 {
            dataSource?.anchor(atMessageId: anchorMessage.anchorMessageId)
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
        guard _collectionViewHasLoaded else { return }
        guard let dataSource = dataSource else { return }
        let offsetY = scrollView.contentOffset.y
        let viewHeight = scrollView.frame.height
        let contentHeight = scrollView.contentSize.height
        if offsetY <= 0 {
            dataSource.loadMoreOlderMessages()
        } else if offsetY + viewHeight >= contentHeight {
            dataSource.loadMoreLaterMessages()
        }
    }
    
}

//MARK: CollectionView Control
extension MessageListViewModel {
    
    func reloadCollectionView() {
        guard _collectionViewHasLoaded else { return }
        guard let collectionView = collectionView else { return }
        collectionView.reloadData()
    }
    
    func scrollToCenter(messageId: Int, animated: Bool = false) {
        if let anchor = _anchorMessage, anchor.anchorMessageId == messageId {
            scrollTo(anchor: anchor, animated: animated)
            return
        }
        let anchor = AnchorMessage(anchorMessageId: messageId, highlightedText: nil, isHighlightedBackground: false)
        scrollTo(anchor: anchor, animated: animated)
    }
    
    private func scrollTo(anchor: AnchorMessageProtocol, animated: Bool = false) {
        guard _collectionViewHasLoaded else {
            _anchorMessage = anchor
            return
        }
        let messageId = anchor.anchorMessageId
        guard messageId > 0 else { return }
        guard let bubbleIndex = dataSource?.bubbleModels.enumerated().first(where: { $0.element.message.messageId == messageId })?.offset else { return }
        _scrollTo(Index: bubbleIndex, animated: animated)
    }
    
    private func scrollToBottom(animated: Bool = false) {
        guard let collectionView = collectionView else { return }
        let contentEdge = collectionView.adjustedContentInset
        let contentHeight = collectionView.contentSize.height + contentEdge.top + contentEdge.bottom
        _scrollTo(contentY: contentHeight, animated: animated)
    }
    
    private func _scrollTo(Index: Int, animated: Bool = false) {
        guard let bubbleFrames = collectionViewLayout?.bubbleFrames else { return }
        guard bubbleFrames.count > Index else { return }
        let targetFrame = bubbleFrames[Index]
        let targetY = targetFrame.midY
        _scrollTo(contentY: targetY, animated: animated)
    }
    
    private func _scrollTo(contentY: CGFloat, animated: Bool = false) {
        guard _collectionViewHasLoaded else { return }
        guard let collectionView = collectionView else { return }
        
        let viewHeight = collectionView.frame.height
        let viewMidHeight = viewHeight / 2
        
        let contentEdge = collectionView.adjustedContentInset
        let contentHeight = collectionView.contentSize.height + contentEdge.top + contentEdge.bottom
        let targetY = max(min(contentY, contentHeight), 0)
                
        // 内容高度不超过视图高度，不处理
        guard contentHeight > viewHeight else { return }
        
        // 内容底部超过视图底部，留在底部
        guard targetY + viewMidHeight <= contentHeight else {
            collectionView.setContentOffset(CGPoint(x: 0, y: contentHeight - viewHeight), animated: animated)
            return
        }
        
        // 内容顶部低于视图顶部，留在顶部
        guard targetY > viewMidHeight else {
            collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
            return
        }
        
        // 目标位置，滚动到视图中间
        collectionView.setContentOffset(CGPoint(x: 0, y: targetY - viewMidHeight), animated: animated)
    }
    
}

