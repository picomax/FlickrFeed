//
//  ItemModel.swift
//  FlickrFeed
//
//  Created by picomax on 2016. 11. 27..
//  Copyright © 2016년 picomax. All rights reserved.
//

import UIKit

class ItemModel {
    var url: URL
    var path: String?
    var isDownloadComplete = false
    
    init(url: URL) {
        self.url = url
    }
}

