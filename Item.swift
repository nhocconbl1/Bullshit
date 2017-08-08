//
//  Item.swift
//  KnockDox
//
//  Created by home on 3/24/17.
//  Copyright © 2017 Toupper. All rights reserved.
//

import Foundation
@objc enum Itemtype:Int {
    case video
    case image
    case gif

}

class Item: Salada.Object {
    typealias Element = Item
    dynamic var userID: String?
    dynamic var file: Salada.File?
    dynamic var type:Itemtype = .image
    override class var _version: String {
        return "v1"
    }
    override func encode(_ key: String, value: Any?) -> Any? {
        if key == "type" {
            return self.type.rawValue as AnyObject?
        }
        return nil
        
    }
    override func decode(_ key: String, value: Any?) -> Any? {
        if key == "type" {
            if let type: Int = value as? Int {
                self.type = Itemtype(rawValue: type)!
                return self.type
            }
        }
        return nil
    }
    

}
