//
//  FaceBookAPI.swift
//  FacebookAPI
//
//  Created by yuya on 2016/05/22.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation

enum FaceBookAPIException:ErrorType{
    case OAuthException(message:String, code:Int)
    case OtherException(message:String, code:Int)
    
    init(type:String, message:String, code:Int){
        if type == "OAuthException"{
            self = FaceBookAPIException.OAuthException(message: message, code:code)
        }
        else{
            self = FaceBookAPIException.OtherException(message: message, code:code)
        }
        
    }
}

enum FaveBookAPIType:String{
    case Me = "me"
    case Any
}

class FaceBookAPIManager{
    
    private let BaseURL = "https://graph.facebook.com/v2.6"
    private struct JsonKey{
        static let Error = "error"
        static let ErrorMessage = "message"
        static let ErrorCode = "code"
        static let ErrorType = "type"
    }
    
    let url:String
    let params:Dictionary<String,String>?
    var connection:ConnectionUtil? = nil
    
    init(node:String, edge:String? = nil, params:Dictionary<String, String>?){
        if let edge = edge{
            self.url = "\(BaseURL)/\(node)/\(edge)?"
        }else{
            self.url = "\(BaseURL)/\(node)?"
        }
        self.params = params
        self.connection = ConnectionUtil(url: self.url, parameters: self.params, method:.Get)
    }
    
    func startAPICall(completionHandler:(dict:NSDictionary, error:ErrorType?)->()){
        if self.connection == nil{
            completionHandler(dict: [:], error: FaceBookAPIException(type: "Unknown Error", message: "Unknown Error", code: -1))
            return
        }
        
        
        self.connection?.call() { (data:NSData?, response:NSURLResponse?, error:ErrorType?) -> () in
            if let data = data{
                var apiError:ErrorType? = nil
                do{
                    
                    let object = try JsonUtil.getJsonObject(data)
                    let dict = JsonUtil.castToAnyObject(object, defaultValue: [:])
                    
                    if let errorObject = dict[JsonKey.Error]{
                        let errorDict = JsonUtil.castToAnyObject(errorObject, defaultValue: [:])
                        
                        let message = errorDict[JsonKey.ErrorMessage] as? String ?? "エラーが発生しました:No Error Message"
                        let code = errorDict[JsonKey.ErrorCode] as? Int ?? -1
                        if let errorType = errorDict[JsonKey.ErrorType] as? String{
                            apiError = FaceBookAPIException(type: errorType, message: message, code:code)
                        }
                        LogUtil.log(errorObject)
                    }
                    completionHandler(dict: dict, error: apiError)
                    return
                }catch{
                    apiError = error
                }
                completionHandler(dict: [:], error: apiError)
            }
        }

    }
}