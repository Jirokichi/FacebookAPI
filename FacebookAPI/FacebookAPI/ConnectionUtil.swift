//
//  ConnectionUtil.swift
//  ZohoMotivator
//
//  Created by Yuya Kida on 2015/12/15.
//  Copyright © 2015年 FujiXerox. All rights reserved.
//

import Foundation
import SystemConfiguration



enum ConnectionError:ErrorType{
    case NoNetwork
    case Cancel
    case HttpResponseError(code:Int)
}

class ConnectionUtil{
    
    deinit{
        LogUtil.log(url)
        // セッションを削除してあげないとメモリリークが発生する
        session?.invalidateAndCancel()
    }
    enum HttpMethod:String{
        case Post = "POST"
        case Get = "GET"
    }
    
    enum HttpRequestHeaderContentType:String{
        case ApplicationXWWWFormUrlEncoded = "application/x-www-form-urlencoded"
    }
    
    private let url:String
    private let method:HttpMethod
    private let contetnType:HttpRequestHeaderContentType
    private let parameters:Dictionary<String, String>?
    var isWorking = false
    
    private var session:NSURLSession?
    private var task:NSURLSessionDataTask?
    init(url:String, parameters:Dictionary<String, String>?, method:HttpMethod = .Post, contetnType:HttpRequestHeaderContentType = .ApplicationXWWWFormUrlEncoded){
        self.url = url
        self.method = method
        self.contetnType = contetnType
        self.parameters = parameters
        
        self.task = nil
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration: config)//, delegate: self, delegateQueue: nil)
    }
    
    func stopConnection(){
        self.task?.cancel()
    }
    
    
    func call(completionHandler: (data:NSData?, response:NSURLResponse?, error:ErrorType?) -> ()){
        
        let requestURL = self.createRequestURL()
        
        
        isWorking = true
        self.task = session?.dataTaskWithRequest(requestURL, completionHandler:{(data, response, error) in
            defer{
                self.isWorking = false
                // セッションを削除してあげないとメモリリークが発生する
                self.session?.invalidateAndCancel()
            }
            
            if let error = error as? NSURLError where error.rawValue == NSURLErrorCancelled{
                completionHandler(data: data, response:response, error: ConnectionError.Cancel)
            }else{
                completionHandler(data: data, response:response, error: error)
            }
            
            
            
        })
        self.task?.resume()
    }
    
    private func createRequestURL() -> NSMutableURLRequest{
        let requestURL:NSMutableURLRequest
        let url:String
        var paramString:String = ""
        if self.parameters != nil{
            for (key, value) in parameters!{
                paramString += "&\(key)=\(value)"
            }
            if(paramString != "") {
                paramString.removeAtIndex(paramString.startIndex)
            }
        }
        
        switch(method){
        case .Post:
            url = self.url
            requestURL = NSMutableURLRequest(URL: NSURL(string: url)!)
            requestURL.HTTPMethod = self.method.rawValue
            requestURL.setValue("Content-Type", forHTTPHeaderField: self.contetnType.rawValue)
            
            // Set Parameter to HTTPBody
            if paramString != ""{
                requestURL.HTTPBody = paramString.dataUsingEncoding(NSUTF8StringEncoding)
            }
        case .Get:
            
            url = self.url + CommonUtil.EncodeString(paramString)
            requestURL = NSMutableURLRequest(URL: NSURL(string: url)!)
            requestURL.HTTPMethod = self.method.rawValue
            requestURL.setValue("Content-Type", forHTTPHeaderField: self.contetnType.rawValue)
        }
        LogUtil.log("\(url):\(paramString)" )
        return requestURL
    }
}

struct NetWork{
    
    /// ホストに接続可能かを判定する関数
    /// - parameter hostName: ホスト名
    /// - returns: ホストへの接続の可否
    static func CheckReachability(hostName:String)->Bool{
        
        let reachability = SCNetworkReachabilityCreateWithName(nil, hostName)!
        var flags = SCNetworkReachabilityFlags.ConnectionAutomatic
        if !SCNetworkReachabilityGetFlags(reachability, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    
    /// ネットワークに接続可能かを判定する関数
    /// - returns: ネットワーク接続の可否
    static func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}