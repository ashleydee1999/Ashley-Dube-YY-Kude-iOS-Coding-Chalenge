//
//  ViewController.swift
//  AshDube Chat App
//
//  Created by Ashley Dube on 2021/09/02.
//

import UIKit
import SocketIO
import RealmSwift

class ChatVC: UIViewController,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate
{
    
    var chatMessages = [[String: String]]()
    var nickname: String!
    var addChats = AddToRealm()
    let realmDB = try! Realm()
    
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var lblNewsBanner: UILabel!
    @IBOutlet weak var messageBox: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var messageTxt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        chatTable.delegate = self
        chatTable.dataSource = self
        messageBox.delegate = self
        
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "No File Path!") //The filepath of the Realm Database
        
        lblNewsBanner.text = ""
        getMessagesFromRealm()
        getAllMessages()
        notificationsHandler()
        
    }
    func getAllMessages() //Fetch messages from Server Database and update the view
    {
        WebServerConnectionManager.sharedInstance.getMessages { messageInfo in
            DispatchQueue.main.async { [self] in
                chatMessages.append(messageInfo)
                chatTable.reloadData()
                let lastIndex:Int = self.chatMessages.count - 1
                addChats.writeToRealm(chatMessages[lastIndex]["userName"]!, chatMessages[lastIndex]["message"]!)
                
            }
        }
    }
    
    func notificationsHandler()
    {
        /*
            - Handles the informing of other users of a users' online status
            - Handles the informing of the view to move up when the keyboard pops up
         */
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hidekeyboard)))
        
        let center: NotificationCenter = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(handleConnectedUserUpdateNotification(_:)) , name: Notification.Name("userWasConnectedNotification"), object: nil)
        
        center.addObserver(self, selector: #selector(handleDisconnectedUserUpdateNotification(_:)), name: Notification.Name("userWasDisconnectedNotification"), object: nil)

        center.addObserver(self, selector: #selector(keyboardWillShow(notification:)) , name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)) , name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    func getMessagesFromRealm()
    {
        /*
          - Fetches the messages from the Realm Database and
            appends them to the chatMessages Array which updates the
            table view of messages
         */
        let results = realmDB.objects(Chats.self)
        
        var messageDictionary = [String: String]()
        
        for i in 0 ..< results.count {
            
            messageDictionary["userName"] = results[i].nickname
            messageDictionary["message"] = results[i].message
            messageDictionary["date"] = results[i].date
            
            chatMessages.append(messageDictionary)

        }
    }
    
    @IBAction func sendMessage(sender: AnyObject)
    {
       // The send button after typing a message
        if messageBox.hasText
        {
            let theMessage = messageBox.text!
            WebServerConnectionManager.sharedInstance.sendMessage(message: theMessage, withNickname: nickname)
            messageBox.text = ""
            messageBox.resignFirstResponder()
        }
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = chatTable.dequeueReusableCell(withIdentifier: "ChatMessageCustomCell") as! ChatMessageCustomCell
        
        cell.dateLbl.text = chatMessages[indexPath.row]["date"]
        
        let sender = chatMessages[indexPath.row]["userName"]
        if sender ==  nickname
        {
            cell.updateMessageCell(sender ?? "no sender", chatMessages[indexPath.row]["message"] ?? "no message", true)
        }
        else
        {
            cell.updateMessageCell(sender ?? "no sender", chatMessages[indexPath.row]["message"] ?? "no message", false)
        }
        
        return cell;
    }
    
    
    /*
        Keyboard and Notifications Management start here
     
        - Handling the Keyboard when it pops up and making it disappear
        - Notification of User when another user goes Online or Offline
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        messageBox.resignFirstResponder()
        return true
    }
    
    @objc func hidekeyboard()
    {
        self.view.endEditing(true)
    }
    
    @objc func handleConnectedUserUpdateNotification(_ notification: Notification)
    {
        let connectedUserInfo = notification.object as! [String: AnyObject]
        let connectedUserNickname = connectedUserInfo["userName"] as? String
        lblNewsBanner.text = "\(connectedUserNickname!.capitalizingFirstLetter()) is Online!"
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.lblNewsBanner.text = ""
        }
    }
    
    @objc func handleDisconnectedUserUpdateNotification(_ notification: Notification)
    {
        let disconnectedUserNickname = notification.object as! String
        lblNewsBanner.text = "\(disconnectedUserNickname.capitalizingFirstLetter()) is Offline!"
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            self.lblNewsBanner.text = ""
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
        {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let bottomSpace = self.view.frame.height - (messageBox.frame.origin.y + messageBox.frame.height)
            self.view.frame.origin.y -= keyboardHeight - bottomSpace + 10
        }
        
    }
    
    @objc func keyboardWillHide(notification: Notification)
    {
        self.view.frame.origin.y = 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    //Keyboard management ends here
}


