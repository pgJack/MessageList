//
//  ViewController.swift
//  String
//
//  Created by Noah on 2023/3/16.
//

import UIKit
import BMMagazine
import RongIMLib

class ViewController: UITableViewController {
    
    private let userId = "cKvDAdIS4aSbku5o7pfdI9"
    private let deviceId = "ZTZiZmZhNzA0NTI2M2E2OA"
    private let token = "nsv+6LuaJjSIYNWYB8XZWmXWELHE4o6TLluyIqe6Cm0Kt6c+2mU6b+OblMfx7MXYeSlOaDIJBhFDXlO9tjsPmcLxc8doIJiMnmyVy73jEheB5ASv1c8E/AosIYyUIAwl"
    
    // iPhone 12
//    private let userId = "ag9zx42_kEk8gSbgvnxnbE"
//    private let deviceId = "ZmJiMmY2ZWYzYWZiNTA2OQ"
//    private let token = "1NxMtBVBBuRB2QOWQuVzQAIt0Wj44QyP5UUGV5by6bIvXnST3RfauM7afcPk8Iaqv3GE+8meaZ/9amlGNGGOuCmOXHzm0prlKUxggFho9tBkOgxbk4LKRqPBtN+u50hL8QBWaA298WY="

    private var conversations = [RCConversation]()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupUI()
        setupIM()
    }

}

//MARK: UI
extension ViewController {
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .always
    }
    
    func setTitle(_ title: String, attributes: [NSAttributedString.Key: Any]) {
        self.title = title
        self.navigationTitleAttributes = attributes
        self.setNavigationBarLargeTitleTextAttributes(attributes)
    }
    
    func setupUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "conversation_cell")
    }
    
    func reloadConversations() {
        guard let rcConversations = RCChannelClient.sharedChannelManager().getConversationList(forAllChannel: [
            NSNumber(value: RCConversationType.ConversationType_PRIVATE.rawValue),
            NSNumber(value: RCConversationType.ConversationType_Encrypted.rawValue),
            NSNumber(value: RCConversationType.ConversationType_GROUP.rawValue)
        ]) else {
            return
        }
        conversations = rcConversations
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversation_cell", for: indexPath)
        let covnersation = conversations[indexPath.row]
        cell.textLabel?.text = covnersation.targetId+" in "+(covnersation.channelId ?? "_")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let covnersation = conversations[indexPath.row]
        let user = UserInfo(userId: userId, userName: "A")
        guard let messageListController = MessageListController(currentUserInfo: user, rcConversation: covnersation, listType: .chat, anchorMessage: nil) else {
            return
        }
        messageListController.navigationItem.backButtonTitle = ""
        navigationController?.pushViewController(messageListController, animated: true)
    }
    
}

//MARK: Connect IM
extension ViewController: RCConnectionStatusChangeDelegate {
        
    func setupIM() {
        onDisconnectIM()

        // 沙特测试环境
        UserDefaults.standard.set(deviceId, forKey: "RC_APP_UUID")
        RCCoreClient.shared().initWithAppKey("mgb7ka1nm7ezg")
        RCCoreClient.shared().setServerInfo("https://nav-sccc-test.rongcloud.net", fileServer: nil)
        RCCoreClient.shared().logLevel = .log_Level_Verbose
        RCCoreClient.shared().voiceMsgType = .highQuality
        RCCoreClient.shared().setRCConnectionStatusChangeDelegate(self)
        RCCoreClient.shared().connect(withToken: token, dbOpened: { [weak self] _ in
            guard let `self` = self else { return }
            self.onOpenDatabae()
        }, success: nil)
    }
    
    func onOpenDatabae() {
        DispatchQueue.mainAction {
            self.reloadConversations()
        }
    }
    
    func onConnectionStatusChanged(_ status: RCConnectionStatus) {
        switch status {
        case .ConnectionStatus_Connected:
            onConnectIM()
        default:
            onDisconnectIM()
        }
    }
    
    func onConnectIM() {
        DispatchQueue.mainAction {
            self.setTitle("已连接", attributes: [.foregroundColor: UIColor.green])
        }
    }
    
    func onDisconnectIM() {
        DispatchQueue.mainAction {
            self.setTitle("未连接", attributes: [.foregroundColor: UIColor.black])
        }
    }
    
}

