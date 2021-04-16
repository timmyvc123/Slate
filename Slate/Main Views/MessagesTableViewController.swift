//
//  MessagesTableViewController.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/12/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import UIKit

class MessagesTableViewController: UITableViewController {
    
    //MARK: - Vars
    var allRecents:[RecentNew] = []
    var filteredRecents:[RecentNew] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    var code = FUser.currentUserFunc()?.language
    let semaphore = DispatchSemaphore(value: 0)

    //MARK: - ViewLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        setupSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        downloadRecentChats()
        
    }
    //MARK: - IBActions
    @IBAction func composeBarButtonPressed(_ sender: Any) {
        
        let userView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "usersTableView") as! UsersTableViewController
        navigationController?.pushViewController(userView, animated: true)
    }
    
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredRecents.count : allRecents.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewRecentTableViewCell
        
        let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
        
        cell.configure(recent: recent)
        
        
        return cell
    }
    
    //MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
        
        FirebaseRecentListener.shared.clearUnreadCounter(recent: recent)
        
        goToChat(recent: recent)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
            
            FirebaseRecentListener.shared.deleteRecent(recent)
            
            searchController.isActive ? self.filteredRecents.remove(at: indexPath.row) : allRecents.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 5
    }
    
    
    //MARK: - Download Chats
    private func downloadRecentChats() {
        
        FirebaseRecentListener.shared.downloadRecentChatsFromFireStore { (allChats) in
            self.allRecents.removeAll()
            for chat in allChats {
                var chat1 = chat
                var isCurrentUser = false
                if chat.actualSender == FUser.currentIdFunc() {
                    isCurrentUser = true
                }
                
                self.initiateTranslation(text: chat.lastMessage, isCurrentUser: isCurrentUser) { (transText) in
                    chat1.lastMessage = transText
                    self.allRecents.append(chat1)
                    self.semaphore.signal()
                }
                
                _ = self.semaphore.wait(wallTimeout: .distantFuture)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func translate(text: String) {
        getTargetLangCode()
        TranslationManager.shared.textToTranslate = text
    }
    
    func getTargetLangCode() {
        if code == nil {
            code = FUser.currentUserFunc()?.language
        }
        TranslationManager.shared.targetLanguageCode = code
    }
    
    func initiateTranslation(text: String, isCurrentUser: Bool, completion: @escaping ( _ result: String) -> ()) {
        var text = text
        if isCurrentUser {
            completion(text)
        } else {
            translate(text: text)
            TranslationManager.shared.translate { (translation) in
                if let translation = translation {
                    text = translation
                    print("The translation is... \(text)")
                    completion(text)
                } else {
                    print("language not translated")
                }
                
            }
        }
    }
    
    //MARK: - Navigation
    
    private func goToChat(recent: RecentNew) {
        
        restartChat(chatRoomId: recent.chatRoomId, memberIds: recent.memberIds)
        
        let privateChatView = NewMessageViewController(chatId: recent.chatRoomId, recipientId: recent.recieverId, recipientName: recent.recieverName)
        
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }
    
    
    
    //MARK: - Search controller
    private func setupSearchController() {
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    private func filteredContentForSearchText(searchText: String) {
        
        filteredRecents = allRecents.filter({ (recent) -> Bool in
            
            return recent.recieverName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
}

extension MessagesTableViewController: UISearchResultsUpdating {
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
