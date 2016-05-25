//
//  LogUtil.swift
//  PeopleTable
//
//  Created by yuya on 2016/03/10.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


class LogUtil{
    static func log(object: Any? = "Any?", classFile: String = __FILE__, functionName: String = __FUNCTION__, lineNumber: Int = __LINE__) {
        
        // クラス名・メソッド名を出力
        if let fileName = NSURL(string: String(classFile))?.lastPathComponent {
            print("\(fileName)/\(functionName)[\(lineNumber)]: \(object ?? "nil")")
        } else {
            print("\(classFile)/\(functionName)[\(lineNumber)]: \(object ?? "nil")")
        }
    }
    
}