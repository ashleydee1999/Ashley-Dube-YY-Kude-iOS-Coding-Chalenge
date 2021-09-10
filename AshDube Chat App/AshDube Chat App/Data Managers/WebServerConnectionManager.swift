//
//  WebServerConnectionManager.swift
//  AshDube Chat App
//  Created by Ashley Dube on 2021/09/02.
//

import Foundation
import SocketIO

class WebServerConnectionManager: NSObject
{
    
    static let sharedInstance = WebServerConnectionManager()

    let manager = SocketManager(socketURL: URL(string: "ws://localhost:3000")!, config: [.log(false), .compress])
    var socket: SocketIOClient? = nil

    override init() {
        super.init()
        setupSocket()
    }

    func establishConnection() {
        if let socket = socket
        {
            socket.connect()
        }
    }

    func closeConnection() {
        if let socket = socket
        {
            socket.disconnect()
        }
    }
    
    func setupSocket() {
        self.socket = manager.defaultSocket
    }
    
    func establishConnectionServer(theUsersName: String, completionHandler: @escaping ([[String: AnyObject]]?) -> Void)
    {
        /*
            - Informing server of a user that has connected and what their name is
            - Adding the user the list of all the users who are or were connected
            to the server
            - call the  onlineStatusManger() func to update online users of the users'
            online status
         */
        socket!.emit("connectUser", theUsersName)
        
        socket!.on("userList") { ( dataArray, ack) -> Void in
            completionHandler(dataArray[0] as? [[String: AnyObject]])
            }
        
        onlineStatusManger()

    }
    
    func sendMessage(message: String, withNickname nickname: String) {
        
        /*
            - Invoked when a user sends a message
            - Parameters: The Users' username and their message
         */
        socket!.emit("chatMessage", nickname, message)
    }
    
    func getMessages(completionHandler: @escaping ([String: String]) -> Void)
    {
        /*
            - This func is contiually invoked in the life cycle of the app
            - It gets all new messages which were sent by different users and
             updates the tableview with those messages
            - The server returns an array with 3 elements: the Users' username,
             their message and time the message was sent
            - Those 3 elements are stored in dictionary
            - As more messages come through, we eventually end up with a dictionary array
         */
        socket!.on("newChatMessage") { (dataArray, socketAck) -> Void in
            var theMessages = [String: String]()
            
            theMessages["userName"] = dataArray[0] as? String
            theMessages["message"] = dataArray[1] as? String
            theMessages["date"] = dataArray[2] as? String
     
            completionHandler(theMessages)
        }
    }
    
    private func onlineStatusManger()
    {
        /*
            - Constantly communicates with the server to get a change in a users' online status.
            - If there's a change, an array with one element i.e the Users' username is returned
            - Online users will get a notification informing them of a change in a users' online status
         */
        if let socket = socket
        {
            socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "userWasConnectedNotification") , object: dataArray[0] as! [String: AnyObject])
            }
            
            socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
                NotificationCenter.default.post(name: Notification.Name(rawValue: "userWasDisconnectedNotification") , object: dataArray[0] as! String)
            }
        }
        
        
        
    }
}
