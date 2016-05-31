//
//  FBGroupMessage.swift
//  FacebookAPI
//
//  Created by yuya on 2016/05/28.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


struct FBMessage{
    let messageId:String
    let message:String?
    let hasPicture:Bool
    let createdTime:NSDate
    let fromUser:(name:String, id:String, url:String)
    
    /// メッセージがある場合のみファイルを作成
    func createFile(folderName:[String], imagesFileName:[String], overWrite:Bool = false) throws{
        let message = self.message ?? ""
        let dict = [
            "message":message as NSString,
            "id":self.messageId as NSString,
            "pictures":imagesFileName as NSArray,
            "createdTime":"\(self.createdTime.timeIntervalSince1970)" as NSString,
            "userName":self.fromUser.name as NSString,
            "userId":self.fromUser.id as NSString,
            "userImageUrl":self.fromUser.url as NSString
        ]
        
        LogUtil.log()
        let fileName = "\(self.messageId)_\(hasPicture).json"
        let data = try JsonUtil.getJsonData(dict)
        try FileUtil(folderName: folderName).saveData(data, fileName: fileName, overWrite:overWrite)
        
    }
    
}

class FBGroupMessageListParser: FBParser{
    private struct JsonKey{
        struct Data{
            static let itself = "data"
            static let Message = "message"
            static let Picture = "picture"
            static let MessageId = "id"
            static let CreatedTime = "created_time"
            
            struct From{
                static let itself = "from"
                static let Name = "name"
                static let Id = "id"
                struct Picture{
                    static let itself = "picture"
                    struct Data{
                        static let itself = "data"
                        static let Url = "url"
                    }
                }
            }
        }
    }
    
    
    
    init(groupId:String, accessToken:String){
        
        let params = ["access_token":accessToken, "fields":"message,updated_time,id,picture,from{id,name,picture}"]
        super.init(facebookAPI:FaceBookAPIManager(node: groupId, edge: "feed", params: params))
    }
    
    func startAPICall(completionHandler:(result:[FBMessage], error:ErrorType?)->()){
        facebookAPI?.startAPICall { (dict, error) -> () in
            
            var result:[FBMessage] = []
            if let dataArray = dict[JsonKey.Data.itself] as? NSArray{
                for singleData in dataArray{
                    
                    let singleDict = singleData
                    let msgId:String = singleDict[JsonKey.Data.MessageId] as? String ?? "Miss"
                    let msg:String? = singleDict[JsonKey.Data.Message] as? String
                    let tempPictureUrl:String? = singleDict[JsonKey.Data.Picture] as? String
                    let hasPicture:Bool =  tempPictureUrl != nil ? true : false
                    let createdTimeStr:String =  singleDict[JsonKey.Data.CreatedTime] as? String ?? "Miss"
                    let createTime:NSDate = DateUtil.getNSDate(createdTimeStr, format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ") ?? NSDate()
                    
                    
                    let userName:String
                    let userId:String
                    let url:String
                    do{
                        let userDict = singleDict[JsonKey.Data.From.itself] as? NSDictionary
                        userName = userDict?[JsonKey.Data.From.Name] as? String ?? "Unknown"
                        userId = userDict?[JsonKey.Data.From.Id] as? String ?? "Unknown"
                        
                        
                        do{
                            let pictureDict = userDict?[JsonKey.Data.From.Picture.itself] as? NSDictionary
                            let data = pictureDict?[JsonKey.Data.From.Picture.Data.itself] as? NSDictionary
                            url = data?[JsonKey.Data.From.Picture.Data.Url] as? String ?? "Unknown"
                        }
                    }
                    
                    
                    
                    
                    let message = FBMessage(messageId: msgId, message: msg, hasPicture: hasPicture, createdTime: createTime, fromUser: (name: userName, id: userId, url:url))
                    
                    result.append(message)
                }
            }
            
            completionHandler(result: result, error: error)
        }
    }
    
}