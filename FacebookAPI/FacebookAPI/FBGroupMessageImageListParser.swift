//
//  FBGroupMessageImageListParser.swift
//  FacebookAPI
//
//  Created by yuya on 2016/05/28.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation


enum ParserError:ErrorType{
    case ParamError(msg:String)
}

struct FBPicture{
    let messageId:String
    let urls:[String]
    
    enum FBType:String{
        case Photo = "photo"
        case Others = "others"
        init(value:String?){
            if value == Photo.rawValue{
                self = .Photo
            }else{
                self = .Others
            }
        }
    }
}

class FBGroupMessageImageListParser{
    private struct JsonKey{
        static let Data = "data"
        static let Attachments = "subattachments"
        static let AttachmentsType = "type"
        static let AttachmentsMedia = "media"
        static let AttachmentsImage = "image"
        static let AttachmentsUrl = "src"
    }
    
    var facebookAPI:FaceBookAPIManager?
    private let msgIds:[String]
    private let params:[String:String]
    init(msgIds:[String], accessToken:String){
        self.msgIds = msgIds
        self.params = ["access_token":accessToken]
    }
    
    private func updateFaceBoolAPI(msgId:String){
        // @Todo: 本来は上書きではなくFaceBookAPIManagerに更新用のメソッドを作成するべき
        self.facebookAPI = FaceBookAPIManager(node: msgId, edge: "attachments", params: params)
    }
    
    func startAPICall(completionHandler:(result:[FBPicture], error:ErrorType?)->()){
        
        
        if msgIds.count <= 0{
            completionHandler(result: [], error: ParserError.ParamError(msg: "メッセージIdが一つも入力されてません"))
            return
        }
        
        self.chainApiCall(0, downloadedPictures:[], completionHandler: completionHandler)
    }
    
    private func chainApiCall(num:Int, var downloadedPictures:[FBPicture], let performingError:ErrorType? = nil, completionHandler:(result:[FBPicture], error:ErrorType?)->()){
        
        // エラー発生したら途中終了
        if let performingError = performingError{
            completionHandler(result: downloadedPictures, error: performingError)
            return
        }
        
        // 全てDLしたら終了
        if num >= msgIds.count{
            completionHandler(result: downloadedPictures, error: nil)
            return
        }
        
        let msgId = self.msgIds[num]
        self.updateFaceBoolAPI(msgId)
        self.facebookAPI?.startAPICall { (dict, error) -> () in
            
            defer{
                // 必ずこの関数を最後に呼ぶ
                self.chainApiCall(num + 1, downloadedPictures: downloadedPictures, performingError: error,completionHandler: completionHandler)
            }
            
            if let error = error{
                LogUtil.log(error)
            }else{
                var urls:[String] = []
                if let dataArray = dict[JsonKey.Data] as? NSArray{
                    for singleData in dataArray{
                        // メッセージに写真を添付している場合
                        let subattachments = singleData[JsonKey.Attachments] as? NSDictionary
                        if let subDataArray = subattachments?[JsonKey.Data] as? NSArray{
                            for subSingleData in subDataArray{
                                let typeString = subSingleData[JsonKey.AttachmentsType] as? String
                                let type = FBPicture.FBType(value: typeString)
                                if type == .Photo{
                                    
                                    let lUrl:String?
                                    do{
                                        let mediaDict = subSingleData[JsonKey.AttachmentsMedia] as? NSDictionary
                                        let imageDict = mediaDict?[JsonKey.AttachmentsImage] as? NSDictionary
                                        lUrl = imageDict?[JsonKey.AttachmentsUrl] as? String
                                    }
                                    if let url = lUrl{
                                        urls.append(url)
                                    }
                                }
                            }
                        }
                        // 写真を直接投稿している場合
                        else{
                            let typeString = singleData[JsonKey.AttachmentsType] as? String
                            let type = FBPicture.FBType(value: typeString)
                            if type == .Photo{
                                
                                let lUrl:String?
                                do{
                                    let mediaDict = singleData[JsonKey.AttachmentsMedia] as? NSDictionary
                                    let imageDict = mediaDict?[JsonKey.AttachmentsImage] as? NSDictionary
                                    lUrl = imageDict?[JsonKey.AttachmentsUrl] as? String
                                }
                                if let url = lUrl{
                                    urls.append(url)
                                }
                            }
                        }
                    }
                    let result = FBPicture(messageId: msgId, urls: urls)
                    downloadedPictures.append(result)
                }
            }
            
        }
    }
    
    
}