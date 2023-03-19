//
//  MessageListViewModel.swift
//  String
//
//  Created by Noah on 2023/3/17.
//

import UIKit

class MessageListViewModel: NSObject {
        
    private(set) weak var controller: MessageListControllerProtocol?
    var collectionView: UICollectionView? { controller?.collectionView }

    private(set) var dataSource: MessageListDataSource
    
    /// 控制器是否加载完成
    private var _collectionViewHasLoaded = false
    /// 气泡数据源
    private var _bubbleModels: [BubbleModel] { dataSource.bubbleModels }
    /// 所有气泡 Frame
    private var _bubbleFrames = [CGRect]()
    /// 所有气泡 Frame
    private var _bubbleViewCache = [Int: BubbleView]()
    /// 所有气泡高度和
    private var _bubbleModelsTotalHeight: CGFloat = 0

    //MARK: LifeCycle
    init(controller: MessageListControllerProtocol) {
        self.controller = controller
        dataSource = MessageListDataSource(userId: controller.messageList.currentUserId)
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
    
    func onViewDidLayoutSubviews() {
        guard !_collectionViewHasLoaded, let collectionView = collectionView else {
            return
        }
        _collectionViewHasLoaded = true
        collectionView.layoutIfNeeded()
        scorllToBottom()
        reloadCollectionView()
    }
    
    func onCollectionViewPrepareLayout() {
        if _bubbleModels.count != _bubbleFrames.count {
            reloadBubbles()
        }
    }
    
    func onReceiveMemoryWarning() {
        dataSource.clearMemoryCache()
        _bubbleViewCache.removeAll()
    }
    
}

//MARK: Layout Output
extension MessageListViewModel {
    
    var collectionViewSize: CGSize {
        collectionView?.frame.size ?? .zero
    }
    
    var messagesTotalHeight: CGFloat {
        _bubbleModelsTotalHeight
    }
    
    func layoutAttributesForMessage(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard _bubbleFrames.count > indexPath.row else { return nil }
        let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        layoutAttribute.frame = _bubbleFrames[indexPath.row]
        return layoutAttribute
    }
    
    func layoutAttributesForMessages(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        _bubbleFrames.enumerated().filter {
            !rect.intersection($0.element).isNull
        }.map {
            let indexPath = IndexPath(item: $0.offset, section: 0)
            let layoutAttribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            layoutAttribute.frame = $0.element
            return layoutAttribute
        }
    }
    
}

//MARK: Message Bubble
private extension MessageListViewModel {
    
    private func reloadBubbles() {
        _bubbleModelsTotalHeight = 0
        _bubbleFrames = []
        
        let x: CGFloat = 0
        let width = collectionViewSize.width
        
        var lastBubble: BubbleModel? = nil
        _bubbleModels.forEach { bubble in
            let message = bubble.message
            let messageId = message.messageId
            let sentTime = message.sentTime
            updateUnreadLine(bubble, messageId: messageId)
            updateDateText(bubble, sentTime: sentTime, lastBubble: lastBubble)
            
            let y = _bubbleModelsTotalHeight
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
            _bubbleModelsTotalHeight += height
            _bubbleFrames.append(CGRect(x: x, y: y, width: width, height: height))
            lastBubble = bubble
        }
    }
    
    func updateUnreadLine(_ bubble: BubbleModel, messageId: Int) {
        guard let anchorMessage = controller?.messageList.anchorMessage,
              anchorMessage.isFirstUnreadMessage,
              anchorMessage.anchorMessageId == messageId else {
            bubble.shownUnreadLine = false
            return
        }
        bubble.shownUnreadLine = true
    }
    
    func updateDateText(_ bubble: BubbleModel, sentTime: Int64, lastBubble: BubbleModel?) {
        guard let lastSentTime = lastBubble?.message.sentTime else {
            bubble.dateText = nil
            return
        }
        let date = NSDate(timeIntervalSince1970: TimeInterval(sentTime) / 1000)
        let previousDate = Date(timeIntervalSince1970: TimeInterval(lastSentTime) / 1000)
        guard !date.isSameDay(previousDate) else {
            bubble.dateText = nil
            return
        }
        bubble.dateText = date.beautyTime()
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
        guard let cell = cell as? MessageBaseCell else {
            return
        }
        let bubbleModel = _bubbleModels[indexPath.row]
        cell.updateSubviewsOnReuse(bubbleModel)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
}

//MARK: CollectionView Control
private extension MessageListViewModel {
    
    func reloadCollectionView() {
        if _collectionViewHasLoaded {
            collectionView?.reloadData()
        }
    }
    
    func scorllToBottom() {
        guard let collectionView = collectionView else { return }
        let height = collectionView.frame.size.height
        let contentBottom = collectionView.adjustedContentInset.bottom
        let contentSize = collectionView.contentSize.height
        collectionView.setContentOffset(CGPoint(x: 0, y: max(contentSize - height + contentBottom, 0)), animated: false)
    }
    
}

