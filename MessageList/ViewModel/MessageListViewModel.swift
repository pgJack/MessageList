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
    var collectionView: MessageListCollectionView? { controller?.collectionView as? MessageListCollectionView }
    /// 消息列表容器视图布局
    var collectionViewLayout: MessageListCollectionViewLayout? { collectionView?.collectionViewLayout as? MessageListCollectionViewLayout }
    
    /// 消息数据源接口
    lazy var dataSource: MessageDataSource? = MessageDataSource(viewModel: self, messageList: messageList)
    
    /// 消息气泡事件处理
    lazy var actionHander = MessageCellGestureHandler(viewModel: self)
    
    /// 消息数据源
    private var _bubbleModels: [BubbleModel] { dataSource?.bubbleModels ?? [] }
    /// 消息定位，滚动到锚点位置
    private var _anchorMessage: AnchorMessageProtocol?
    
    /// 所有气泡视图
    private lazy var _bubbleViewCache = [Int: BubbleView]()
    
    //MARK: LifeCycle
    init(messageList: MessageListProtocol, anchorMessage: AnchorMessageProtocol?) {
        self.messageList = messageList
        _anchorMessage = anchorMessage
        super.init()
        dataSource?.initializeDataSource(anchorMessageId: anchorMessage?.anchorMessageId)
    }
    
    func onViewDidLoad() {
        guard let collectionView = collectionView else { return }
        MessageCellRegister.registerCells(for: collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func onViewWillAppear(_ animated: Bool) { }
    
    func onViewDidAppear(_ animated: Bool) { }
    
    func onViewWillDisappear(_ animated: Bool) { }
    
    func onViewDidDisappear(_ animated: Bool) { }
    
    func onViewDidLayoutSubviews() { }
    
    func onReceiveMemoryWarning() {
        _bubbleViewCache.removeAll()
    }
    
}

//MARK: DataSource Interface
extension MessageListViewModel {
    
    func dataSourceDidReset(anchorMessageId: Int? = nil) {
        collectionView?.reloadData()
        if let anchorMessageId = anchorMessageId {
            scrollToCenter(messageId: anchorMessageId, animated: false)
        }
    }
    
    func dataSourceDidInsert(_ bubbles: [BubbleModel], at index: Int) {
        let startIndex = index
        let endIndex = bubbles.count + startIndex
        let indexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
        guard indexPaths.count > 0 else { return }
        guard let collectionView = collectionView else { return }
        guard let collectionViewLayout = collectionViewLayout else { return }

        let firstVisiableIndex = collectionView.indexPathsForVisibleItems.sorted(by: { $0.row < $1.row }).first?.row
        let offsetY = collectionViewLayout.insertBubbleLayouts(for: bubbles, at: index, offsetForIndex: firstVisiableIndex)
        
        var offset = collectionView.contentOffset
        collectionView.reloadData()
        guard offsetY > 0 else { return }
        offset.y = ceil(offset.y + offsetY)
        collectionView.contentOffset = offset
    }
        
}

//MARK: CollectionView DataSource
extension MessageListViewModel: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("---> section: \(_bubbleModels.count)")
        return _bubbleModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
            cell.actionDelegate = actionHander
            
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
        guard let dataSource = dataSource else { return }
        let offsetY = scrollView.contentOffset.y
        let viewHeight = scrollView.frame.height
        let contentHeight = scrollView.contentSize.height
        let triggerHeight: CGFloat = viewHeight / 3
        if offsetY <= triggerHeight {
            /// Offset 小于触发点，加载更多历史
            dataSource.loadMoreOlderMessages()
        } else if offsetY + viewHeight + triggerHeight >= contentHeight  {
            /// Offset + 视图高度 + 触发点，大于内容高度，加载更多最新
            dataSource.loadMoreLaterMessages()
        }
    }
    
    private func bubbleView<T: BubbleModel>(forModel bubble: T) -> BubbleView? {
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

//MARK: CollectionView Control
extension MessageListViewModel {
    
    func scrollToCenter(messageId: Int, animated: Bool = false) {
        if let anchor = _anchorMessage, anchor.anchorMessageId == messageId {
            scrollTo(anchor: anchor, animated: animated)
            return
        }
        let anchor = AnchorMessage(anchorMessageId: messageId, highlightedText: nil, isHighlightedBackground: false)
        scrollTo(anchor: anchor, animated: animated)
    }
    
    private func scrollTo(anchor: AnchorMessageProtocol, animated: Bool = false) {
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
        guard let bubbleLayouts = collectionViewLayout?.bubbleLayouts else { return }
        guard bubbleLayouts.count > Index else { return }
        let targetFrame = bubbleLayouts[Index].frame
        let targetY = targetFrame.midY
        _scrollTo(contentY: targetY, animated: animated)
    }
    
    private func _scrollTo(contentY: CGFloat, animated: Bool = false) {
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

