//
//  SetTableViewController.swift
//  PenPals
//
//  Created by Tim Van Cauwenberge on 4/22/20.
//  Copyright © 2020 SeniorProject. All rights reserved.
//

import UIKit
import JGProgressHUD

class SetTableViewController: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNamesLabel: UILabel!
    @IBOutlet weak var blockedUsersButton: UIButton!
    @IBOutlet weak var tellFriendButton: UIButton!
    @IBOutlet weak var tCButton: UIButton!
    @IBOutlet weak var slateVersionLabel: UILabel!
    @IBOutlet weak var deleteUserAccountButton: UIButton!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteAccountButton: UIButton!
    
    let userDefaults = UserDefaults.standard
    
    var avatarSwitchStatus = false
    var firstLoad: Bool?
    var translatedText = ""
    var code = FUser.currentUserFunc()?.language
    
    var hud = JGProgressHUD(style: .dark)
    
    override func viewDidAppear(_ animated: Bool) {
        
        // if we have a current user setUpUI
        if FUser.currentUserFunc() != nil {
            setUpUI()
            loadUserDefaults()
        }
        setUpUI()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
           
        setUpUI()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.tableFooterView = UIView()
        
        navigationController?.navigationBar.backgroundColor = CustomColor.settingsBackgroundColor
        view.backgroundColor = CustomColor.settingsBackgroundColor
        
        navigationItem.title = NSLocalizedString("Settings", comment: "")
        
        tabBarController?.tabBar.items?[0].title = NSLocalizedString("Chats", comment: "")
        tabBarController?.tabBar.items?[1].title = NSLocalizedString("Your Friends", comment: "")
        tabBarController?.tabBar.items?[2].title = NSLocalizedString("Settings", comment: "")
        
        blockedUsersButton.setTitle(NSLocalizedString("Blocked Users", comment: ""), for: .normal)

        tellFriendButton.setTitle(NSLocalizedString("Tell a Friend", comment: ""), for: .normal)
        
        
        tCButton.setTitle(NSLocalizedString("T & C", comment: ""), for: .normal)
        slateVersionLabel.text = NSLocalizedString("Slate Version", comment: "")

        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            
            versionLabel.text = version
        }
        
        logOutButton.setTitle(NSLocalizedString("Log Out", comment: ""), for: .normal)
        deleteAccountButton.setTitle(NSLocalizedString("Delete Account", comment: ""), for: .normal)
        
        

        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 || section == 2 {
            return 2
        }
        return 2
    }
    
    //MARK: TableViewDelegate
    
    //gets rid of section titles
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        }
        
        return 30
    }
    
    //MARK: IBActions
    
    @IBAction func TCButtonPressed(_ sender: Any) {
        let urlComponents = URLComponents (string: "http://www.slateofficial.com/terms.html")!
        UIApplication.shared.open (urlComponents.url!)
    }
    
    @IBAction func tellFriendButtonTapped(_ sender: Any) {
        
        //implement translation for message
        let text = NSLocalizedString("Hey! Lets chat on Slate ", comment: "") + " \(kAPPURL)"
//        "Hey! Lets chat on Slate \(kAPPURL)"
        let objectsToShare : [Any] = [text]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.setValue(NSLocalizedString("Hey! Lets chat on Slate ", comment: ""), forKey: "subject")
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func logoutButton(_ sender: Any) {
        
        FUser.logOutCurrentUser { (success) in
            
            if success {
                self.showLoginview()
            }
            
        }
    }
    
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        
        //implement translation
        let firstTitle = NSLocalizedString("Delete Account", comment: "")
        let message = NSLocalizedString("Are You Sure", comment: "")
        let secondTitle = NSLocalizedString("Delete", comment: "")
        
        let optionMenu = UIAlertController(title: firstTitle, message: message, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: secondTitle, style: .destructive) { (alert) in
            
            self.deleteUser()
            
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { (alert) in
            
        }
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        // ipad bug fix (required for app store success
        // check if it an ipad
        if (UI_USER_INTERFACE_IDIOM() == .pad) {
            if let currentPopoverPresentationcontroller = optionMenu.popoverPresentationController {
                
                // changes option menu location
                currentPopoverPresentationcontroller.sourceView = deleteUserAccountButton
                currentPopoverPresentationcontroller.sourceRect = deleteUserAccountButton.bounds
                currentPopoverPresentationcontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        } else {
            // if its an iphone
            self.present(optionMenu, animated: true, completion: nil)
        }
        // end bug fix
        
        
    }
    
    
    func showLoginview() {
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirstView")
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true, completion: nil)
    }
    
    //MARK: SetUpUI
    
    func setUpUI() {
        
//        print("HELLOOOOOOO")
        
        let currentUser = FUser.currentUserFunc()!
        
        //profileImageView.isUserInteractionEnabled = true
        
        fullNamesLabel.text = currentUser.fullname
        
        if currentUser.avatar != "" {
            
            imageFromData(pictureData: currentUser.avatar) { (avatarImage) in
                
                if avatarImage != nil {
                    self.profileImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
    }
    
    //MARk: Delete User
    
    func deleteUser() {
        
        //delete locally
        userDefaults.removeObject(forKey: kPUSHID)
        userDefaults.removeObject(forKey: kCURRENTUSER)
        //saves changes
        userDefaults.synchronize()
        
        //delete from firebase
        FirebaseReference(.User).document(FUser.currentId).delete()
        
        FUser.deleteUser { (error) in
            
            //when user is delete do this...
            if error != nil {
                
                //if we can't delete user
                DispatchQueue.main.async {
                    
                    self.hud.textLabel.text = NSLocalizedString("Couldn't delete user", comment: "")
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.dismiss(afterDelay: 2.0, animated: true)
                    
                }
                return
            }
            //user was deleted successfully
            self.showLoginview()
        }
        
    }
    
    //MARK: User defaults
    
    func saveUserDefaults() {
        
        userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
        userDefaults.synchronize()
        
    }
    
    func loadUserDefaults() {
        
        // check to see if it is users first time running application
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        
        //if it isnt the first load
        if !firstLoad! {
            
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.synchronize()
        }
        
    }
    
    
    
}
