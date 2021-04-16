//
//  RecentTableViewCell.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 11/11/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var unreadCounterlabel: UILabel!
    @IBOutlet weak var unreadCounterBackgroundView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        unreadCounterBackgroundView.layer.cornerRadius = unreadCounterBackgroundView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(recent: RecentChats) {
        
        //get users full name and scale it to fit in the cell
        fullNameLabel.text = recent.recieverName
        fullNameLabel.adjustsFontSizeToFitWidth = true
        fullNameLabel.minimumScaleFactor = 0.9
        
        //get last message and scale it to fit in cell
        lastMessageLabel.text = recent.lastMessage
        lastMessageLabel.adjustsFontSizeToFitWidth = true
        lastMessageLabel.numberOfLines = 2
        lastMessageLabel.minimumScaleFactor = 0.9
        
        // if there is unread messages increment the counter if not hdie the view
        if recent.unreadCounter != 0 {
            self.unreadCounterlabel.text = "\(recent.unreadCounter)"
            self.unreadCounterBackgroundView.isHidden = false
        } else {
            self.unreadCounterBackgroundView.isHidden = true
        }
        
        setAvatar(avatarLink: recent.avatarLink)
        dateLabel.text = timeElapsed(recent.date ?? Date())
        dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func setAvatar(avatarLink: String) {
        
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                            self.avatarImageView.image = avatarImage?.circleMasked
            }
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")?.circleMasked
        }
    }

}
