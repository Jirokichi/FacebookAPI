//
//  JsonUtil.swift
//  FacebookAPI
//
//  Created by yuya on 2016/05/22.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation

struct JsonUtil{
    
    static func getJsonObject(data:NSData) throws -> AnyObject{
        let object = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        return object
    }
    
    static func getJsonData(dict:NSDictionary) throws -> NSData{
        let jsonData = try NSJSONSerialization.dataWithJSONObject(dict, options: NSJSONWritingOptions.init(rawValue: 2)) //(*)options??
        return jsonData
    }
    
//    static func castToDictionary(object:AnyObject, defaultValue:NSDictionary = [:]) -> NSDictionary{
//        if object is NSDictionary{
//            return object as! NSDictionary
//        }else{
//            LogUtil.log("特定の型ではない:\(object)")
//        }
//        return defaultValue
//    }
    
    static func castToAnyObject<T>(object:AnyObject, defaultValue:T) -> T{
        if object is T{
            return object as! T
        }else{
            LogUtil.log("特定の型ではない:\(object)")
        }
        return defaultValue
    }
    
}