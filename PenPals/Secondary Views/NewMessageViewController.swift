//
//  NewMessageViewController.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/12/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class NewMessageViewController: MessagesViewController {
    
    //MARK: - Views
    let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
    
    let titleLabel: UILabel = {
       let title = UILabel(frame: CGRect(x: 5, y: 0, width: 180, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.adjustsFontSizeToFitWidth = true
        return title
    }()
    
    let subTitleLabel: UILabel = {
       let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 140, height: 20))
        subTitle.textAlignment = .left
        subTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        subTitle.adjustsFontSizeToFitWidth = true
        return subTitle
    }()
    
    //MARK: - Vars
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    let currentUser = MKSender(senderId: FUser.currentId, displayName: FUser.currentUserFunc()!.fullname)
    
    let refreshController = UIRefreshControl()
    
    let micButton = InputBarButtonItem()
    
    var mkMessages: [MKMessage] = [] //source of messages that are displayed
    var allLocalMessages: Results<LocalMessage>!
    
    let realm = try! Realm()
    
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var typingCounter = 0
    
    var gallery: GalleryController!
    
    //Listeners
    var notificationToken: NotificationToken?
    
    var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName: String = ""
    var audioDuration: Date!
    
    //MARK: - Inits
    init(chatId: String, recipientId: String, recipientName: String) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - Vew Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        createTypingObserver()
        
        configureLeftBarButton()
        configureCustomTitle()
        
        configureMessageCollectionView()
        configureGestureRecognizer()
        configureMessageInputBar()

        updateTypingIndicator(true)
        
        loadChats()
        listenForNewChats()
        listenForReadStatusChange()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseRecentListener.shared.resetRecentCounter(chatroomId: chatId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FirebaseRecentListener.shared.resetRecentCounter(chatroomId: chatId)
        audioController.stopAnyOngoingPlaying()
    }
    
    //MARK: - Configuration
    private func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.refreshControl = refreshController
        
    }
    
    private func configureMessageInputBar() {
        
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        attachButton.onTouchUpInside {
            item in
            
            self.actionAttachMessage()
        }
        
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        micButton.addGestureRecognizer(longPressGesture)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        updateMicButtonStatus(show: true)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
        
    }
    
    func updateMicButtonStatus(show: Bool) {
        
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
        
    }
    
    private func configureGestureRecognizer() {
        
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
        
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }
    
    private func configureCustomTitle() {
        
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        
        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)
        
        titleLabel.text = recipientName
    }
    
    
    //MARK: - Load Chats
    
    private func loadChats() {
        
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        
        if allLocalMessages.isEmpty {
            checkForOldChats()
        }
        
        print("we have \(allLocalMessages.count) messages")
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in
            
            switch changes {
            
            case .initial:
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)
            case .update(_, _, let insertions, _):
                
                for index in insertions {
                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: false)
                }
            
            case .error(let error):
                print("Error on new insertion ", error.localizedDescription)
            }
            
        })
        
    }
    
    private func listenForNewChats() {
        FirebaseMessageListener.shared.listenForNewChats(FUser.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    private func checkForOldChats() {
        FirebaseMessageListener.shared.checkForOldChats(FUser.currentId, collectionId: chatId)
    }
    
    //MARK: - Insert Messages
    
    private func listenForReadStatusChange() {
        
        FirebaseMessageListener.shared.listenForReadStatusChange(FUser.currentId, collectionId: chatId) { (updatedMessage) in
            
            if updatedMessage.status != kSENT {
                self.updateMessage(updatedMessage)
            }
        }
    }
    
    private func insertMessages() {
        
        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessages[i])
        }
    }
    
    private func insertMessage(_ localMessage: LocalMessage) {
        
        if localMessage.senderId != FUser.currentId {
            markMessageAsRead(localMessage)
        }
        
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
        
    }
    
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            insertOlderMessage(allLocalMessages[i])
        }
    }
    
    private func insertOlderMessage(_ localMessage: LocalMessage) {
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
        displayingMessagesCount += 1
        
    }
    
    private func markMessageAsRead(_ localMessage: LocalMessage) {
        
        if localMessage.senderId != FUser.currentId {
            FirebaseMessageListener.shared.updateMessageInFirebase(localMessage, memberIds: [FUser.currentId, recipientId])
        }
    }
    
    //MARK: - Actions
    
    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location, memberIds: [FUser.currentId, recipientId])
        
    }
    
    @objc func backButtonPressed() {
        
        FirebaseRecentListener.shared.resetRecentCounter(chatroomId: chatId)
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }
    
    //media action sheet
    private func actionAttachMessage() {
        
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (alert) in
            
            self.showImageGallery(camera: true)
        }
        
        let shareMedia = UIAlertAction(title: "Library", style: .default) { (alert) in
            
            self.showImageGallery(camera: false)
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (alert) in
            
            if let _ = LocationManager.shared.currentLocation {
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
            } else {
                print("no access to location")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    //MARK: - Update Typing indicator
    
    func createTypingObserver() {
        
        FirebaseTypingListener.shared.createTypingObserver(chatRoomId: chatId) { (isTyping) in
            
            DispatchQueue.main.async {
                self.updateTypingIndicator(isTyping)
            }
        }
    }
    
    func typingIndicatorUpdate() {
        
        typingCounter += 1
        
        FirebaseTypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)
        
        //stop indicator 1.5 secodns after user stops typing
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.typingCounterStop()
        }
    }
    
    func typingCounterStop() {
        
        typingCounter -= 1
        if typingCounter == 0 {
            FirebaseTypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }
    
    func updateTypingIndicator(_ show: Bool) {
        
        subTitleLabel.text = show ? "Typing.." : ""
    }
    
    //MARK: - UIscrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if refreshController.isRefreshing {
            
            if displayingMessagesCount < allLocalMessages.count {
                //load eariler messages
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            
            refreshController.endRefreshing()
        }
    }
    
    //MARK: - UpdateReadMessageStatus
    private func updateMessage(_ localMessage: LocalMessage) {
        
        for index in 0 ..< mkMessages.count {
            
            let tempMessage = mkMessages[index]
            
            if localMessage.id == tempMessage.messageId {
                
                mkMessages[index].status = localMessage.status
                mkMessages[index].readDate = localMessage.readDate
                
                RealmManager.shared.saveToRealm(localMessage)
                
                if mkMessages[index].status == kREAD {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    //MARK: - Helpers
    
    private func removeListeners() {
        FirebaseTypingListener.shared.removeTypingListener()
        FirebaseMessageListener.shared.removeListener()
    }
    
    private func lastMessageDate() -> Date {
        
        let lastmessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastmessageDate) ?? lastmessageDate
        
    }
    
    //MARK: - Gallery
    
    private func showImageGallery(camera: Bool) {
        
        gallery = GalleryController()
        gallery.delegate = self
        
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30
        
        self.present(gallery, animated: true, completion: nil)
    }
    
    //MARK: - Audio Messages
    
    @objc func recordAudio() {
        
        //check when mic button press starts and ends
        
        switch longPressGesture.state {
        case .began:
            audioDuration = Date()
            audioFileName = Date().stringDate()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
            
        case .ended:
            //stop recording
            AudioRecorder.shared.finishRecording()
            
            if fileExistsAtPath(path: audioFileName + ".m4a") {
                
                let audioDur = audioDuration.interval(ofComponent: .second, from: Date())
                
                messageSend(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioDur)
            } else {
                print("no audio file")
            }
            
            audioFileName = ""
            
        @unknown default:
            print("unkown")
        }
    }

}

extension NewMessageViewController : GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0 {
            images.first!.resolve { (image) in
                self.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
        self.messageSend(text: nil, photo: nil, video: video, audio: nil, location: nil)
        controller.dismiss(animated: true, completion: nil)
    }
    
    //not using
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}
