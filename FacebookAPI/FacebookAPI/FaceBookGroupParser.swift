//
//  FaceBookGroupParser.swift
//  FacebookAPI
//
//  Created by yuya on 2016/05/26.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation

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

class FaceBookGroupParser{
    private struct JsonKey{
        static let Data = "data"
        static let DataName = "name"
        static let DataPrivacy = "privacy"
        static let DataId = "id"
    }
    
    
    let facebookAPI:FaceBookAPIManager
    
    init(accessToken:String){
        let params = ["access_token":accessToken]
        facebookAPI = FaceBookAPIManager(node: "me", edge: "groups", params: params)
    }
    
    func startAPICall(completionHandler:(result:[(groupName:String, groupId:String, groupType:GroupPrivacy)], error:ErrorType?)->()){
        facebookAPI.startAPICall { (dict, error) -> () in
            
            var result:[(groupName:String, groupId:String, groupType:GroupPrivacy)] = []
            if let dataArray = dict[JsonKey.Data] as? NSArray{
                for singleData in dataArray{
                    let singleDict = singleData
                    let groupName:String = singleDict[JsonKey.DataName] as? String ?? "Miss"
                    let groupId:String =  singleDict[JsonKey.DataId] as? String ?? "Miss"
                    let groupType:GroupPrivacy =  GroupPrivacy(value: singleDict[JsonKey.DataPrivacy] as? String)
                    
                    result.append((groupName, groupId, groupType))
                }
            }
            
            completionHandler(result: result, error: error)
        }
    }
    
}