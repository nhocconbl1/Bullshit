//
//  File.swift
//  KnockDox
//
//  Created by home on 4/3/17.
//  Copyright © 2017 Toupper. All rights reserved.
//

import Foundation
class Comment:NSObject {
    
    var senderId:String?
    var text:String?
    var imageUrl:String?
    var timestamp: NSNumber?
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?

    init(dictionary: [String: AnyObject]) {
        super.init()
        senderId = dictionary["senderId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        imageUrl = dictionary["imageUrl"] as? String
        imageHeight = dictionary["imageHeight"] as? NSNumber
        imageWidth = dictionary["imageWidth"] as? NSNumber
    }

    
}
