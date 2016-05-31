//
//  FaceBookGroupParser.swift
//  FacebookAPI
//
//  Created by yuya on 2016/05/26.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


struct FBGroup{
    let groupName:String
    let groupId:String
    let groupType:GroupPrivacy
    let ownerName:String
    
    func createDisplayedText() -> String{
        return "\(self.groupName)(\(self.groupType)) created by \(self.ownerName) - \(self.groupId)"
    }
}

enum GroupPrivacy:String{
    case Open = "OPEN"
    case Closed = "CLOSED"
    case Others
    init(value:String?){
        if value == Open.rawValue{
            self = .Open
        }else if value == Closed.rawValue{
            self = .Closed
        }else{
            self = .Others
        }
    }
}

class FBGroupListParser: FBParser{
    private struct JsonKey{
        static let Data = "data"
        static let DataName = "name"
        static let DataPrivacy = "privacy"
        static let DataId = "id"
        static let DataOwner = "owner"
        static let DataOwnerName = "name"
    }
    
    
    init(accessToken:String){
        let params = ["access_token":accessToken, "fields":"data,name,id,owner,privacy"]
        super.init(facebookAPI: FaceBookAPIManager(node: "me", edge: "groups", params: params))
    }
    
    func startAPICall(completionHandler:(result:[FBGroup], error:ErrorType?)->()){
        facebookAPI?.startAPICall { (dict, error) -> () in
            
            var result:[FBGroup] = []
            if let dataArray = dict[JsonKey.Data] as? NSArray{
                for singleData in dataArray{
                    let singleDict = singleData
                    let groupName:String = singleDict[JsonKey.DataName] as? String ?? "Miss"
                    let groupId:String =  singleDict[JsonKey.DataId] as? String ?? "Miss"
                    let groupType:GroupPrivacy =  GroupPrivacy(value: singleDict[JsonKey.DataPrivacy] as? String)
                    let ownerDict = singleDict[JsonKey.DataOwner] as? NSDictionary
                    let ownerName = ownerDict?[JsonKey.DataOwnerName] as? String ?? "Unknown"
                    
                    let group = FBGroup(groupName: groupName, groupId: groupId, groupType: groupType, ownerName: ownerName)
                    result.append(group)
                }
            }
            
            completionHandler(result: result, error: error)
        }
    }
    
}