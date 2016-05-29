//
//  ImageUtil.swift
//  FacebookAPI
//
//  Created by yuya on 2016/05/22.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Foundation

enum FileError: ErrorType{
    case ImageFileSaveError
    case FailToCreateNewDerectory
}



struct ImageUtil{
    private static let DocumentPath = NSHomeDirectory().stringByAppendingString("/Documents/")
    private static let FolderName = "WeddingImages"
    
    // 画像のURLと取得後に保存するためのファイル名のタプル
    let imagesInfo:[(url:String, fileName:String)]
    
    init(imagesInfo:[(url:String, fileName:String)]){
        self.imagesInfo = imagesInfo
    }
    
    /// 画像を取得してDocumentPathに保存する。保存後に保存したパスの一覧を引数としたコールバックメソッドdidParseが呼び出される。
    /// - parameter ticket: 認証チケット(妥当性チェックは関数内でしてくれる)
    /// - parameter didParse: すべての画像を保存した後に呼び出されるコールバック関数。エラーの場合は取得前に呼び出される。
    func getDataFromApi(didParse: (error:ErrorType?) -> ()){
        self.executeApiCall(didParse:didParse)
    }
    
    /// num番目の画像URLを引数としてAPIを呼び出す関数。self.imagesInfoの個数分、再帰的に呼び出される。エラーが発生した場合は、途中で処理を中断する。
    /// - parameter ticket: 認証チケット(妥当性チェックは関数内でしてくれる)
    /// - parameter num: self.imagesInfoの画像番号。この番号の画像をサーバーから保存する。
    /// - parameter didParse: すべての画像を取得したあとに呼び出されるコールバック関数。エラーの場合は取得前に呼び出される。
    private func executeApiCall(num:Int = 0, error:ErrorType? = nil, didParse: (error:ErrorType?) -> ()){
        // 再帰処理の終了条件
        if(imagesInfo.count <= num || error != nil){
            didParse(error: error)
            return
        }
        
        let connection = ConnectionUtil(url: imagesInfo[num].url, parameters: nil, method:.Get)
        connection.call { (data, response, error) -> () in
            var errorType = error
            if errorType == nil{
                do{
                    try ImageUtil.saveData(data, fileName:self.imagesInfo[num].fileName)
                }catch{
                    errorType = error
                }
            }
            self.executeApiCall((num+1), error: errorType, didParse: didParse)
        }
    }
    
    static func saveData(data: NSData?, fileName:String, overWrite:Bool = false) throws{
        let folderPath = try ImageUtil.getFolderPath()
        let path =  folderPath + "/" + fileName
        let success:Bool
        if isFile(path) && !overWrite{
            success = true
        }else{
            success = data?.writeToFile(path, atomically: true) ?? false
        }
        //@Action Fix
        if !(success) {
            throw FileError.ImageFileSaveError
        }
    }
    
    static func isFile(fullPath:String) -> Bool{
        var isDir : ObjCBool = false
        let fileManager = NSFileManager.defaultManager()
        return fileManager.fileExistsAtPath(fullPath, isDirectory: &isDir)
    }
    
    /// 利用するフォルダーのパスを取得する関数。存在しない場合は作成する。作成に失敗した場合はエラーを返す
    static func getFolderPath() throws -> String{
        let folderPath = ImageUtil.DocumentPath.stringByAppendingString(ImageUtil.FolderName)
        var isDir : ObjCBool = false
        let fileManager = NSFileManager.defaultManager()
        fileManager.fileExistsAtPath(folderPath, isDirectory: &isDir)
        if !isDir{
            do{
                try fileManager.createDirectoryAtPath(folderPath, withIntermediateDirectories: true, attributes: nil)
            }catch{
                throw FileError.FailToCreateNewDerectory
            }
        }
        return folderPath
    }
    
}