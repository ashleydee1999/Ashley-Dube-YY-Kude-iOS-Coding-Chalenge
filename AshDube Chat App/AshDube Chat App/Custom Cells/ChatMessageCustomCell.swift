//
//  ChatMessageCustomCell.swift
//  AshDube Chat App
//
//  Created by Ashley Dube on 2021/09/02.
//

import UIKit

class ChatMessageCustomCell: UITableViewCell
{
    
    @IBOutlet weak var nicknameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var messagesBackgroundView: UIView!
    
    var trailingConstraint: NSLayoutConstraint!
    var leadingConstraint: NSLayoutConstraint!
    
    var nameTrailingConstraint: NSLayoutConstraint!
    var nameLeadingConstraint: NSLayoutConstraint!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        messageLbl.text = nil
        leadingConstraint.isActive = false
        trailingConstraint.isActive = false
    }
    
    func updateMessageCell(_ nickname: String, _ message: String, _ isFirstUser: Bool)
    {
        messagesBackgroundView.layer.cornerRadius = 16
        messagesBackgroundView.clipsToBounds = true
        
        trailingConstraint = messagesBackgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        leadingConstraint = messagesBackgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)
        
        nameTrailingConstraint = nicknameLbl.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        nameLeadingConstraint = nicknameLbl.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20)
        
        messageLbl.text =  message
        
        
        if isFirstUser
        {
            messagesBackgroundView.backgroundColor = UIColor(red: 222/255.0, green: 183/255.0, blue: 138/255.0, alpha: 1.0)
            trailingConstraint.isActive = true
            nameTrailingConstraint.isActive = true
            messageLbl.textAlignment = .right
            nicknameLbl.textAlignment = .right
            nicknameLbl.text = "You"
        }
        else
        {
            messagesBackgroundView.backgroundColor = UIColor(red: 133/255.0, green: 112/255.0, blue: 179/255.0, alpha: 1.0)
            leadingConstraint.isActive = true
            nameLeadingConstraint.isActive = true
            messageLbl.textAlignment = .left
            nicknameLbl.textAlignment = .left
            nicknameLbl.text = nickname.capitalizingFirstLetter()
        }
    }
}
