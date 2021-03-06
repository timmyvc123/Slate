//
//  ProfileViewTableViewController.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 3/21/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import ProgressHUD
import JGProgressHUD

class ProfileViewTableViewController: UITableViewController {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var messageButtonOutlet: UIButton!
    @IBOutlet weak var blockButtonOutlet: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    
    @IBOutlet weak var messageCell: UITableViewCell!
    
    var cell: UITableViewCell!
    
    // user that is passed through to get the correct contact view
    var user: FUser?
    var hud = JGProgressHUD(style: .dark)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageButtonOutlet.setTitle(NSLocalizedString("Message", comment: ""), for: .normal)
        blockButtonOutlet.setTitle(NSLocalizedString("Block User", comment: ""), for: .normal)
        removeButton.setTitle(NSLocalizedString("Remove User", comment: ""), for: .normal)
                
        // when view is opened..
        setupUI()
        
    }
    
    
    //MARK: IBActions
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        if !checkBlockedStatus(withUser: user!) {
//            let messageVC = MessageViewController()
//            messageVC.titleName = user!.firstname
//            messageVC.membersToPush = [FUser.currentId(), user!.objectId]
//            messageVC.memberIds = [FUser.currentId(), user!.objectId]
//
//            messageVC.chatRoomId = startPrivateChat(user1: FUser.currentUser()!, user2: user!)
//            messageVC.isGroup = false
//            messageVC.hidesBottomBarWhenPushed = true
//            self.navigationController?.pushViewController(messageVC, animated: true)
            
            let chatId = startChat(user1: FUser.currentUserFunc()!, user2: user!)
            
            let privateChatView = NewMessageViewController(chatId: chatId, recipientId: user!.objectId, recipientName: user!.fullname)
            
            privateChatView.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(privateChatView, animated: true)
            print("Start chatting in chatroom id: \(chatId)")

        } else {

            self.hud.textLabel.text = NSLocalizedString("Not Available", comment: "")
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 1.5, animated: true)

        }

    }
    
    @IBAction func blockUserButtonPressed(_ sender: Any) {
        
        var currentBlockedIds = FUser.currentUserFunc()!.blockedUsers
        if currentBlockedIds.contains(user!.objectId) {
            
            // find the index of the currently blocked user in the blockedUsers array
            currentBlockedIds.remove(at: currentBlockedIds.firstIndex(of: user!.objectId)!)
        } else {
            // or add them to the blocked array
            currentBlockedIds.append(user!.objectId)
        }
        
        //
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedIds]) { (error) in
            if error != nil {
                print("error updating user \(error!.localizedDescription)")
                return
            }
            
            self.updateBlockStatus()
        }
        
//        blockUser(userToBlock: user!) func in recent.swift (deleted)
    }
    
    var isFriendRemovedSuccessfully = false
    
    @IBAction func removeUserButtonPressed(_ sender: Any) {
        
        var currentFriends = FUser.currentUserFunc()!.friendListIds
               
               if currentFriends.contains(user!.objectId) {
                   isFriendRemovedSuccessfully = true
                   currentFriends.remove(at: currentFriends.firstIndex(of: user!.objectId)!)
               }
               
               updateCurrentUserInFirestore(withValues: [kFRIENDLISTIDS : currentFriends]) { (error) in
                   
                   if error != nil {
                       self.isFriendRemovedSuccessfully = false
                       print("error updating user \(error!.localizedDescription)")
                       return
                   }
                
                self.updateRemoveStatus()
                   
               }
        
        
    }
    
    //MARK: Background refresh
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 2 {
            return 2
        }
        return 1
    }
    
    // remove tableview cell section headers
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    //initalize an empty view
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    //get rid of first cell header so theres no space between top of the view and the first cell
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        //0 = first cell section
        if section == 0 {
            return 0
        }
        
        return 30
    }
    
    //MARK: Setup UI
    
    func setupUI() {
        
        //make sure there is a user clicked on
        if user != nil {
            
            self.title = NSLocalizedString("Profile", comment: "")
            
            
            //get currently selected user's information from database
            fullNameLabel.text = user!.fullname
            
            phoneLabel.text = user!.phoneNumber
            
            getLanguage(user: user)

            
            updateBlockStatus()
            updateRemoveStatus()
            
            imageFromData(pictureData: user!.avatar) { (avatarImage) in
                if avatarImage != nil {
                    
                    // check if image is the same as user's real image and then make it round
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
    }
    
    func updateBlockStatus() {
        
        // if it is not the current user logged in
        if user!.objectId != FUser.currentId {
            blockButtonOutlet.isHidden = false
            messageButtonOutlet.isHidden = false
        } else {
            blockButtonOutlet.isHidden = true
            messageButtonOutlet.isHidden = true
        }
        
        // if the user is in the current user's array of blocked users
        if FUser.currentUserFunc()!.blockedUsers.contains(user!.objectId) {
            blockButtonOutlet.setTitle(NSLocalizedString("Unblock User", comment: ""), for: .normal)
        } else {
            blockButtonOutlet.setTitle(NSLocalizedString("Block User", comment: ""), for: .normal)
        }
    }
    
    func updateRemoveStatus() {
        
        // if it is not the current user logged in
        if user!.objectId != FUser.currentId {
            removeButton.isHidden = false
            messageButtonOutlet.isHidden = false
        } else {
            removeButton.isHidden = true
            messageButtonOutlet.isHidden = true
        }
        
        // if the user is in the current user's array of blocked users
        if FUser.currentUserFunc()!.friendListIds.contains(user!.objectId) {
            removeButton.setTitle(NSLocalizedString("Remove User", comment: ""), for: .normal)
        } else {
            removeButton.setTitle(NSLocalizedString("Removed", comment: ""), for: .normal)
            removeButton.setTitleColor(.lightGray, for: .normal)
            messageButtonOutlet.setTitleColor(.lightGray, for: .normal)
        }
    }
    
    
    func getLanguage(user: FUser?) {
        
        var lang = user?.language
        
        //        ["Arabic", "Bengali", "Chinese", "Dutch", "English", "French", "German", "Haitian", "Hindi", "Italian", "Japenese", "Korean", "Malay", "Porteguese", "Romanian", "Russian", "Spanish"]
        
        if lang == "ar" {
            languageLabel.text = NSLocalizedString("Arabic", comment: "")
        } else if lang == "bn" {
            languageLabel.text = NSLocalizedString("Bengali", comment: "")
        } else if lang == "zh" {
            languageLabel.text = NSLocalizedString("Standard Chinese (Mandarin)", comment: "")
        } else if lang == "nl" {
            languageLabel.text = NSLocalizedString("Dutch", comment: "")
        } else if lang == "en" {
            languageLabel.text = NSLocalizedString("English", comment: "")
        } else if lang == "fr" {
            languageLabel.text = NSLocalizedString("French", comment: "")
        } else if lang == "de" {
            languageLabel.text = NSLocalizedString("German", comment: "")
        } else if lang == "ht" {
            languageLabel.text = NSLocalizedString("Haitian", comment: "")
        } else if lang == "hi" {
            languageLabel.text = NSLocalizedString("Hindi", comment: "")
        } else if lang == "it" {
            languageLabel.text = NSLocalizedString("Italian", comment: "")
        } else if lang == "ja" {
            languageLabel.text = NSLocalizedString("Japenese", comment: "")
        } else if lang == "ko" {
            languageLabel.text = NSLocalizedString("Korean", comment: "")
        } else if lang == "ms" {
            languageLabel.text = NSLocalizedString("Malay", comment: "")
        } else if lang == "pt" {
            languageLabel.text = NSLocalizedString("Porteguese", comment: "")
        } else if lang == "ro" {
            languageLabel.text = NSLocalizedString("Romanian", comment: "")
        } else if lang == "ru" {
            languageLabel.text = NSLocalizedString("Russian", comment: "")
        } else if lang == "es" {
            languageLabel.text = NSLocalizedString("Spanish", comment: "")
        }
    }
    
}

extension UIView {
    func addBorderTop(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: frame.width, height: size, color: color)
    }
    func addBorderBottom(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: frame.height - size, width: frame.width, height: size, color: color)
    }
    func addBorderLeft(size: CGFloat, color: UIColor) {
        addBorderUtility(x: 0, y: 0, width: size, height: frame.height, color: color)
    }
    func addBorderRight(size: CGFloat, color: UIColor) {
        addBorderUtility(x: frame.width - size, y: 0, width: size, height: frame.height, color: color)
    }
    private func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        layer.addSublayer(border)
    }
}
