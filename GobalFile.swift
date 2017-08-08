//
//  GobalFile.swift
//  KnockDox
//
//  Created by home on 3/17/17.
//  Copyright © 2017 Toupper. All rights reserved.
//

import Foundation
import Firebase

class GobalFile {
    class func GetCurrentUser(completion:@escaping (User?) ->Void ){
        guard let id = FIRAuth.auth()?.currentUser?.uid else {return}
        
        User.info(forUserID: id, completion: {
            user in
            completion(user)
        })
    }
}


