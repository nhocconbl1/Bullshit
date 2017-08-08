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

@objc enum UserType: Int {
    case email
    case facebook
    case google
    case twitter
}

class User: Salada.Object {
    
    typealias Element = User
    
    override class var _version: String {
        return "v1"
    }
    
    dynamic var username: String?
    dynamic var email: String?
    dynamic var follows: Set<String> = []
    dynamic var location: CLLocation?
    dynamic var Profileurl: URL?
    dynamic var ProfileFile: Salada.File?
    dynamic var type: UserType = .email
    dynamic var knockcoin:Int = 0
    dynamic var password:String?
    dynamic var onroom:Bool = false
   
    var profilePic:UIImage?
    override var ignore: [String] {
        return ["profilePic"]
    }
    
    override func encode(_ key: String, value: Any?) -> Any? {
        if key == "location" {
            if let location = self.location {
                return ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
            }
        } else if key == "type" {
            return self.type.rawValue as AnyObject?
        }
        return nil
    }
    
    override func decode(_ key: String, value: Any?) -> Any? {
        if key == "location" {
            if let location: [String: Double] = value as? [String: Double] {
                self.location = CLLocation(latitude: location["latitude"]!, longitude: location["longitude"]!)
                return self.location
            }
        } else if key == "type" {
            if let type: Int = value as? Int {
                self.type = UserType(rawValue: type)!
                return self.type
            }
        }
        return nil
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
   class func checkURL(user:User){
        user.ProfileFile?.ref?.downloadURL(completion: {
            url,error in
            if error != nil {
                return
            }
            if url != nil && url != user.Profileurl {
                user.Profileurl = url
                user.save()
                return
            }
            
        })
    }
    class func InfoValue(forUserID: String, completion: @escaping (User) -> Swift.Void){
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        User.observeSingle(forUserID, eventType: .value, block: {
            (user) in
            
            guard let user:User = user as? User else { return }
            checkURL(user: user)
            if user.Profileurl != nil {
                
                Util.loadImageUsingCacheWithUrlString(urlString: (user.Profileurl?.absoluteString)!, completion: {
                    image in
                    
                    guard let image = image else {return}
                    user.profilePic = image
                    completion(user)
                    return
                    
                })
            }else if user.ProfileFile != nil {
                user.ProfileFile?.dataWithMaxSize(1*10000*2000, completion: {
                    (data,error) in
                    user.profilePic = UIImage(data: data!)
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
    class func info(forUserID: String, completion: @escaping (User) -> Swift.Void) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        User.observe(forUserID, eventType: .value, block: {
        (user) in
            
            guard let user:User = user as? User else { return }
            checkURL(user: user)
            if user.Profileurl != nil {
                
                Util.loadImageUsingCacheWithUrlString(urlString: (user.Profileurl?.absoluteString)!, completion: {
                    image in
                  
                    guard let image = image else {return}
                    user.profilePic = image
                    completion(user)
                    return
                
                })
            }else if user.ProfileFile != nil {
                user.ProfileFile?.dataWithMaxSize(1*10000*2000, completion: {
                    (data,error) in
                    user.profilePic = UIImage(data: data!)
                    
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
