//
//  Video.swift
//  KnockDox
//
//  Created by home on 3/30/17.
//  Copyright © 2017 Toupper. All rights reserved.
//

import Foundation

class Video: Salada.Object {
    
    typealias Element = Video
    dynamic var userID: String?
    dynamic var title:String?
    dynamic var VideoUrl:URL?
    dynamic var ImageVideoUrl:URL?
    dynamic var Loves:Set<String> = []
    dynamic var Views:NSNumber = 0
    var user:User?
    override var ignore: [String] {
        return ["user"]
    }
    
    class func VideoInfo(Id:String,completion: @escaping(Video) -> Void)  {
        Video.observeSingle(Id, eventType: .value, block: {
            video in
            guard let video:Video = (video as! Video) else {return}
            User.InfoValue(forUserID: video.userID!, completion: {
                user in
                video.user = user
                completion(video)
                return
            })
            return
        })
    }
}
