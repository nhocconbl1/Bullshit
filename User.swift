//
//  User.swift
//  Salada
//
//  Created by 1amageek on 2016/08/15.
//  Copyright © 2016年 Stamp. All rights reserved.
//

import Foundation
import CoreLocation


@objc enum GenderType: Int {
    case man
    case womman
    case LGBT
}
class User: Salada.Object {
    
    typealias Element = User
    
    override class var _version: String {
        return "vn"
    }
    
    dynamic var name: String?
    dynamic var acid:String?
    dynamic var birthday: Date?
    dynamic var gender: GenderType = .man
    dynamic var friends: Set<String> = []
    dynamic var detail:String?
    dynamic var profileurl: URL?
    dynamic var birth: Date?
    dynamic var thumbnail: Salada.File?
    dynamic var email:String?
    dynamic var password:String?
    dynamic var testItems: Set<String> = []
    
    var tempName: String? 
    
    override var ignore: [String] {
        return ["tempName"]
    }
    
    override func encode(_ key: String, value: Any?) -> Any? {
       if key == "gender" {
            return self.gender.rawValue as AnyObject?
        }
        return nil
    }
    
    override func decode(_ key: String, value: Any?) -> Any? {
      if key == "gender" {
            if let gender: Int = value as? Int {
                self.gender = GenderType(rawValue: gender)!
                return self.gender
            }
        }
        return nil
    }
}
