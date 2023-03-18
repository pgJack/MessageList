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
    private var conversations = [Conversation]()
            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupNavigationBar()
        setupUI()
        setupIM()
    }
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .always
        setTitle("未连接", attributes: [.foregroundColor: UIColor.black])
    }

}

//MARK: UI
extension ViewController {
    
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
        conversations = rcConversations.compactMap(MessageListModelGenerator.conversation(_:))
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversation_cell", for: indexPath)
        let covnersation = conversations[indexPath.row]
        cell.textLabel?.text = covnersation.targetId+" in "+covnersation.channelId
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let covnersation = conversations[indexPath.row]
        let messageListController = MessageListController(currentUserId: userId, conversation: covnersation, listType: .chat, anchorMessage: nil)
        messageListController.navigationItem.backButtonTitle = ""
        navigationController?.pushViewController(messageListController, animated: true)
    }
    
}

//MARK: Connect IM
extension ViewController {
    
    func setupIM() {
        // 沙特测试环境
        // UserDefaults.standard.set("ZTZiZmZhNzA0NTI2M2E2OA", forKey: "RC_APP_UUID")
        RCIMClient.shared().initWithAppKey("mgb7ka1nm7ezg")
        RCIMClient.shared().setServerInfo("https://nav-sccc-test.rongcloud.net", fileServer: nil)
        RCIMClient.shared().logLevel = .log_Level_Verbose
        RCIMClient.shared().voiceMsgType = .highQuality
        let token = "nsv+6LuaJjSIYNWYB8XZWmXWELHE4o6TLluyIqe6Cm0Kt6c+2mU6b+OblMfx7MXYeSlOaDIJBhFDXlO9tjsPmcLxc8doIJiMnmyVy73jEheB5ASv1c8E/AosIYyUIAwl"
        RCIMClient.shared().connect(withToken: token) { [weak self] code in
            guard let `self` = self else { return }
            self.onOpenDatabae()
        } success: { [weak self] userId in
            guard let `self` = self else { return }
            self.onConnectIM()
        } error: { errorCode in
            print("\(errorCode)")
        }
    }
    
    func onOpenDatabae() {
        DispatchQueue.mainAction {
            self.reloadConversations()
        }
    }
    
    func onConnectIM() {
        DispatchQueue.mainAction {
            self.setTitle("已连接", attributes: [.foregroundColor: UIColor.green])
        }
    }
    
}

