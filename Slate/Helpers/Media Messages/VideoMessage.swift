//
//  VideoMessage.swift
//  PenPals
//
//  Created by Timmy Van Cauwenberge on 1/20/21.
//  Copyright © 2021 SeniorProject. All rights reserved.
//

import Foundation
import MessageKit

class VideoMessage: NSObject, MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    override init() {
        url = URL.init(string: "https://www.google.com")!
        image = UIImage.init()
        placeholderImage = UIImage.init()
        size = CGSize.init()
        super.init()

    }
    init(url: URL?) {
        self.url = url
        self.placeholderImage = UIImage(named: "photoPlaceholder")!
        self.size = CGSize(width: 240, height: 240)
    }
    
}
