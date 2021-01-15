//
//  InputBarAccessoryViewDelegate.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/12/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import InputBarAccessoryView

extension NewMessageViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
        if text != "" {
            print("user is typing...")
        }
    }
    
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        for component in inputBar.inputTextView.components {
            
            if let text = component as? String {
                
                messageSend(text: text, photo: nil, video: nil, audio: nil, location: nil)
                
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
    
}
