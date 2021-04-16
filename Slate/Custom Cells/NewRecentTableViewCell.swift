//
//  NewRecentTableViewCell.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/4/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import UIKit

class NewRecentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var counterBackgroundView: UIView!
    

    override func awakeFromNib() {
        super.awakeFromNib()

        counterBackgroundView.layer.cornerRadius = counterBackgroundView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func configure(recent: RecentNew) {
        
        //print("AVATAR IMAGE  ", recent.avatarLink)
        
        usernameLabel.text = recent.recieverName
        usernameLabel.adjustsFontSizeToFitWidth = true
        usernameLabel.minimumScaleFactor = 0.9
        
        lastMessageLabel.text = recent.lastMessage
        lastMessageLabel.adjustsFontSizeToFitWidth = true
        lastMessageLabel.numberOfLines = 2
        lastMessageLabel.minimumScaleFactor = 0.9

        if recent.unreadCounter != 0 {
            self.counterLabel.text = "\(recent.unreadCounter)"
            self.counterBackgroundView.isHidden = false
        } else {
            self.counterBackgroundView.isHidden = true
        }
        
        
        
//        profileImageView.image = UIImage(named: "goodiebag")?.circleMasked
        
//        var link = URL(string: recent.avatarLink)
//        
//        if let data = try? Data(contentsOf: link!) {
//            profileImageView.image = UIImage(data: data)
//        }
        
//        profileImageView.image = recent.avatarLink
        setAvatar(avatarLink: recent.avatarLink)
        dateLabel.text = timeElapsed(recent.date ?? Date())
        dateLabel.adjustsFontSizeToFitWidth = true
    }
    
    private func setAvatar(avatarLink: String) {
        
        if avatarLink != "" {
            
            
            imageFromData(pictureData: avatarLink) { (avatarImage) in
                
                if avatarImage != nil {
                    
                    self.profileImageView.image = avatarImage!.circleMasked
                }
            }
            
        } else {
            self.profileImageView.image = UIImage(named: "avatarPlaceholder")
        }
        
//        if avatarLink != "" {
//
//
//            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
//                print("We get the profile picture!!!!")
//                self.profileImageView.image = avatarImage?.circleMasked
//            }
//        } else {
//            self.profileImageView.image = UIImage(named: "avatarPlaceholder")
//        }
    }

}
