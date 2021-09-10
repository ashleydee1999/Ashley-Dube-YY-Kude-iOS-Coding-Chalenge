//
//  RealmManager.swift
//  AshDube Chat App
//
//  Created by Ashley Dube on 2021/09/04.
//

import Foundation
import RealmSwift

class Chats: Object
{
    @objc dynamic var nickname: String?
    @objc dynamic var message: String?
    @objc dynamic var date: String?
    
}
class User: Object
{
    @objc dynamic var usernameRealm: String?
}

class AddToRealm
{
    let realmDB = try! Realm()
    var userChats: Chats?
   
    
    func getDate()->String{
        let time = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "dd/MM HH:mm"
        let stringDate = timeFormatter.string(from: time)
        return stringDate
    }
    
    func writeToRealm(_ nickname:String, _ message:String)
    {
        try! realmDB.write
        {
            userChats = Chats()
            
            if let userChats = userChats
            {
                userChats.nickname = nickname
                userChats.message = message
                userChats.date =  getDate()
                realmDB.add(userChats)
            }
        }
        
    }
}
