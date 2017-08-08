//
//  File.swift
//  KnockDox
//
//  Created by home on 3/15/17.
//  Copyright © 2017 Toupper. All rights reserved.
//

import Foundation
import Firebase
@objc enum Roomtype:Int {
    case game
    case video
    case livestream
    case room
    
}

class Room: Salada.Object {
    
    typealias Element = Room
    
    override class var _version: String {
        return "v1"
    }
    dynamic var point:Int = 0
    dynamic var userId:String?
    dynamic var title:String?
    dynamic var type:Roomtype = .room
    dynamic var nembers:Set<String> = []
    var user:User?
    
    override var ignore: [String] {
        return ["user"]
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
                self.type = Roomtype(rawValue: type)!
                return self.type
            }
        }
        return nil
    }

   
    
    class func CreateRoom(Point: Int,type:Roomtype){
        guard  let uid =  FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        let room:Room = Room()
        
        room.point = Point
        room.userId = uid
        room.type = type
        do {
            try? room.save()
            User.info(forUserID: uid, completion: {
                user in
                user.onroom = true
                user.save()
                room.user = user
                return
            
            })
            return
        }catch let error {
            print("Create room error :",error)
        }
    }
    


}
