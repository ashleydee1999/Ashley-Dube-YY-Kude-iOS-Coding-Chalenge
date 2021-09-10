//
//  ChatViewController.swift
//  AshDube Chat App
//
//  Created by Ashley Dube on 2021/09/02.
//

import UIKit
import SocketIO
import RealmSwift

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource
{

    @IBOutlet weak var usersTableView: UITableView!
    @IBOutlet weak var joinButton: UIBarItem!
    
    var users = [[String: AnyObject]]()
    var userNameArr: User?
    var theUsersName: String!
    let realmDB = try! Realm()
    var configurationOK = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        
        theUsersName = getUsernameRealm()
        if theUsersName != nil
        {
            
            populateTable()
            self.title = "Welcome \(theUsersName.capitalizingFirstLetter())"
            
        }
        else
        {
            // if the DB returned nil then ask the User for their Name
            requestUsername()
        }
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
     
    }
    func populateTable()
    {
        /*
          - Populate tableview with all the users the server has stored whether on or offline
         */
        WebServerConnectionManager.sharedInstance.establishConnectionServer(theUsersName: self.theUsersName) { userList in
            DispatchQueue.main.async {
               
                if userList != nil
                {
                    self.users = self.removeOwnUsername(userList!)
                    self.usersTableView.reloadData()
                    self.usersTableView.isHidden = false
                }
            }
        }
    }
    
    func removeOwnUsername(_ onlineUsers: [[String: AnyObject]]) -> [[String: AnyObject]]
    {
        /*
          - The server returns an array of all users
            on record including the user who's using the chat app (Themself)
            So this function just removes that users' name from the dictionary array
         */
        var theArr = onlineUsers
        let recordValue = "userName"
        let recordKey = self.theUsersName
        var usernameIndex: Int? = nil
        for index in 0..<theArr.count {
            for (key, value) in theArr[index] {
                if (key, value as? String) == (recordValue, recordKey) {
                    usernameIndex = index
                    break
                }
            }
            if usernameIndex != nil {
                break
            }
        }
        if let myIndex = usernameIndex {
            theArr.remove(at: myIndex)
        } else {
            print("No index found :(")
        }
        
        return theArr
    }
    
    func getUsernameRealm () -> String?
    {
        /*
            - Query Realm DB for that Users' username and return it
         */
        let results = realmDB.objects(User.self)
        var userNickname: String?
        
        if !results.isEmpty
        {
            userNickname = results[0].usernameRealm
            return userNickname!
        }
        else
        {
            return nil
        }
        
    }
    
    func setUsernameRealm(_ theNickname: String)
    {
        /*
          - Save the users' username to the Realm DB
         */
        try! realmDB.write
        {
            userNameArr = User()
            
            if let userNickname = userNameArr
            {
                userNickname.usernameRealm = theUsersName
                realmDB.add(userNickname)
            }
        }
    }
    func requestUsername()
    {
        /*
             - if Realm DB returned 0 records when queried for the users' username,
             an Alert Controller is invoked to get that users' username
         
            - The username is subsequently saved to RealmDB
         
            - Lastly, the populateTable() function is called in order update the
            tableview with all users
         */
        let alertController = UIAlertController(title: "AshDube Chat App", message: "Enter your name :)", preferredStyle: UIAlertController.Style.alert)
        
        alertController.addTextField(configurationHandler: nil)
        
        let OKAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action) -> Void in
            
            let textfield = alertController.textFields![0]
            if !textfield.hasText{
                self.requestUsername()
            }
            else
            {
                self.theUsersName = textfield.text
                self.setUsernameRealm(self.theUsersName)
                self.populateTable()
                self.title = self.theUsersName
            }
        }
        
        alertController.addAction(OKAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func pressed(_ sender: Any)
    {
        // Action pressed for the 'joinButton'
        performSegue(withIdentifier: "theScreen", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        /*
          - If the Bar button: 'Join' is pressed, the app has to segue
            to ChatVC so we just send the users' username to the next view
         */
        
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "theScreen"
        {

            let senderButton = sender as! UIBarItem

            switch senderButton
            {
                case joinButton:
                    let controller = segue.destination as? ChatVC
                    controller?.nickname = theUsersName
                    
                default:
                    //default code
                    print("default scenario")
            }

        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = usersTableView.dequeueReusableCell(withIdentifier: "onlineUserCustomCell") as! CocktailCollectionViewCell
        
        let userN =  users[indexPath.row]["userName"] as? String
        
        cell.userNameLbl?.text = userN?.capitalizingFirstLetter()
        let onlineStatus = users[indexPath.row]["isConnected"] as? Bool
        
        if onlineStatus == true
        {
            cell.detailIMG.image = UIImage(named: "greenCircle")
        }
        else
        {
            cell.detailIMG.image = UIImage(named: "redCircle")
        }
       
        return cell;
    }
    
}
extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }

    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
