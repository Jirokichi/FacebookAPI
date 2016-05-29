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
    let fromUser:(name:String, id:String)
    
    /// メッセージがある場合のみファイルを作成
    func createFile(folderName:[String], overWrite:Bool = false) throws{
        if let message = self.message{
            let dict = [
                "message":message as NSString,
                "id":self.messageId as NSString,
                "hasPicture":self.hasPicture as NSNumber,
                "createdTime":"\(self.createdTime.timeIntervalSince1970)" as NSString,
                "userName":self.fromUser.name as NSString,
                "userId":self.fromUser.id as NSString
            ]
            
            let fileName = "\(self.createdTime.timeIntervalSince1970)_\(hasPicture)_\(self.messageId).json"
            let data = try JsonUtil.getJsonData(dict)
            try FileUtil(folderName: folderName).saveData(data, fileName: fileName, overWrite:overWrite)
        }
    }
    
}

class FBGroupMessageListParser{
    private struct JsonKey{
        static let Data = "data"
        static let DataMessage = "message"
        static let DataPicture = "picture"
        static let DataMessageId = "id"
        static let DataCreatedTime = "created_time"
        
        static let DataFrom = "from"
        static let DataFromName = "name"
        static let DataFromId = "id"
    }
    
    
    let facebookAPI:FaceBookAPIManager
    
    init(groupId:String, accessToken:String){
        let params = ["access_token":accessToken, "fields":"message, id, picture, from, to, created_time"]
        facebookAPI = FaceBookAPIManager(node: groupId, edge: "feed", params: params)
    }
    
    func startAPICall(completionHandler:(result:[FBMessage], error:ErrorType?)->()){
        facebookAPI.startAPICall { (dict, error) -> () in
            
            var result:[FBMessage] = []
            if let dataArray = dict[JsonKey.Data] as? NSArray{
                for singleData in dataArray{
                    
                    let singleDict = singleData
                    let msgId:String = singleDict[JsonKey.DataMessageId] as? String ?? "Miss"
                    let msg:String? = singleDict[JsonKey.DataMessage] as? String
                    let tempPictureUrl:String? = singleDict[JsonKey.DataPicture] as? String
                    let hasPicture:Bool =  tempPictureUrl != nil ? true : false
                    let createdTimeStr:String =  singleDict[JsonKey.DataCreatedTime] as? String ?? "Miss"
                    let createTime:NSDate = DateUtil.getNSDate(createdTimeStr, format: "yyyy-MM-dd'T'HH:mm:ssZZZZZ") ?? NSDate()
                    
                    let userDict = singleDict[JsonKey.DataFrom] as? NSDictionary
                    let userName = userDict?[JsonKey.DataFromName] as? String ?? "Unknown"
                    let userId = userDict?[JsonKey.DataFromId] as? String ?? "Unknown"
                    
                    let message = FBMessage(messageId: msgId, message: msg, hasPicture: hasPicture, createdTime: createTime, fromUser: (name: userName, id: userId))
                    
                    result.append(message)
                }
            }
            
            completionHandler(result: result, error: error)
        }
    }
    
}