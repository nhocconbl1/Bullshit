//
//  User.swift
//  Salada
//
//  Created by 1amageek on 2016/08/15.
//  Copyright © 2016年 Stamp. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import Firebase


class User: Salada.Object {
    
    typealias Element = User
    
    override class var _version: String {
        return "v1"
    }
    
    dynamic var username: String?
    
    dynamic var email: String?
    dynamic var follows: Set<String> = []
//    dynamic var location: CLLocation?
    dynamic var Profileurl: URL?
    dynamic var knockcoin:Int = 0
    dynamic var password:String?
    dynamic var onroom:Bool = false
   
    var profilePic:UIImage?
    override var ignore: [String] {
        return ["profilePic"]
    }
    
    
  
    class func registerUser(email: String, password: String, completion: @escaping (User?,Error?) -> Swift.Void) {
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                user?.sendEmailVerification(completion: nil)
                guard let uid = user?.uid else{
                    return
                }
                let u = User(id: uid)
                
                u!.email = email
                u!.password = MD5(password)
                u?.save({
                    ref,err in
                    if err == nil {
                        let userInfo = ["email" : email, "password" : password]
                        UserDefaults.standard.set(userInfo, forKey: "userInformation")
                        
                        completion(u!,nil)
                        return
                    }
                    return
                
                })
                return
            }
            else {
                completion(nil,error)
                return
            }
        })
    }
    //Load number User with page *10
    class func LoadFollowsUsers(withArray:[String],completion:@escaping ([User])->Void)  {
        let count = 10
        let end = count < withArray.count ? count:withArray.count
        
        var users:[User] = []
        if withArray.count == 0 {
            return
        }
        for i in 0..<end {
            User.info(forUserID: withArray[i], completion: {
                user in
                if users.contains(where: {$0.id == user.id}){
                    return
                }
                users.append(user)
                if i == end - 1{
                    completion(users)
                    return
                }
                return
            })
        }
        return
       
    }
    class func CheckID(forUserID:String,completion:@escaping(Bool) -> Void){
        
        User.observeSingle(forUserID, eventType: .value, block: {
            (user) in
        
            if user != nil {
                completion(true)
                return
            }else
            {
                completion(false)
                return
            }
        
        })

    }
    class func loginUser(withEmail: String, password: String, completion: @escaping (Error?) -> Swift.Void) {
        FIRAuth.auth()?.signIn(withEmail: withEmail, password: password, completion: { (user, error) in
            if error == nil {
                let userInfo = ["email" : withEmail, "password" : password]
                UserDefaults.standard.set(userInfo, forKey: "userInformation")

                completion(nil)
                return
                } else {
                completion(error)
                return
                }
        })
    }
    
    class func logOutUser(completion: @escaping (Bool) -> Swift.Void) {
        do {
            try FIRAuth.auth()?.signOut()
                       completion(true)
              UserDefaults.standard.removeObject(forKey: "userInformation")
            return
        } catch _ {
            completion(false)
            return
        }
    }
    class func InfoValue(forUserID: String, completion: @escaping (User) -> Swift.Void){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        User.observeSingle(forUserID, eventType: .value, block: {
            (user) in
            
            guard let user:User = user as? User else { return }
           
            if user.Profileurl != nil {
                
                Util.loadImageUsingCacheWithUrlString(urlString: (user.Profileurl?.absoluteString)!, completion: {
                    image in
                    
                    guard let image = image else {return}
                    user.profilePic = image
                    completion(user)
                    return
                    
                })
            }else{
                user.profilePic = UIImage.init(named: "profile pic")
                completion(user)
                return
            }
        })

    }
    class func checkusername(forUserName: String,completion:@escaping (Bool)->Void) {
        User.observeSingle(child: "username", equal: forUserName, eventType: .value, block: {
            (users) in
            if users.count != 0 {
                completion(true)
            }else{
                completion(false)
            }
        })
    }
    class func info(forUserID: String, completion: @escaping (User) -> Swift.Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        User.observe(forUserID, eventType: .value, block: {
        (user) in
            
            guard let user:User = user as? User else { return }
                if user.Profileurl != nil {
                
                Util.loadImageUsingCacheWithUrlString(urlString: (user.Profileurl?.absoluteString)!, completion: {
                    image in
                  
                    guard let image = image else {return}
                    user.profilePic = image
                    completion(user)
                    return
                
                })
            }else{
                user.profilePic = UIImage.init(named: "profile pic")
                completion(user)
                return
            }

        })
    }

    
    
    
    
    
}
