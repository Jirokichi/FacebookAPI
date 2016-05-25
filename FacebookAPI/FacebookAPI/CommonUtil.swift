//
//  CommonUtil.swift
//  FacebookAPI
//
//  Created by yuya on 2016/05/21.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


struct CommonUtil{
    
    
    static func EncodeString(targetString:String)->String{
        if let encodedString = targetString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
        {
            return encodedString
        }else{
            LogUtil.log("エンコード失敗")
            return targetString
        }
    }
    
    
    static func DencodeString(encodedString:String)->String{
        if let decodedString = encodedString.stringByRemovingPercentEncoding{
            return decodedString
        }else{
            LogUtil.log("デコード失敗")
            return encodedString
        }
    }
    
}