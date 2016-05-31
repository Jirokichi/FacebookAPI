//
//  ViewController.swift
//  FacebookAPI
//
//  Created by yuya on 2016/05/14.
//  Copyright © 2016年 yuya. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    struct UserDefaultKey{
        static let AccessToken = "AccessToken"
    }
    
    static let NotSelectedStatus = "-"
    static let FolderName = "WeddingInstallation"
    
    @IBOutlet weak var groupPopUpButton: NSPopUpButton!
    
    @IBOutlet weak var accessTokenTextField: NSTextField!
    @IBOutlet weak var resultTextField: NSTextField!
    
    private var groups:[FBGroup]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LogUtil.log("log")
        if let accessToken =  NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultKey.AccessToken){
            self.accessTokenTextField.stringValue = accessToken
        }
        self.callGroupsAPI()
    }
    
    private func setGroupPopUpButton(){
        self.groupPopUpButton.removeAllItems()
        
        if let groups = self.groups{
            groups.forEach { (group) -> () in
                self.groupPopUpButton.addItemWithTitle(group.createDisplayedText())
            }
            self.groupPopUpButton.enabled = true
        }else{
            self.groupPopUpButton.addItemWithTitle(ViewController.NotSelectedStatus)
            self.groupPopUpButton.enabled = false
        }
    }
    
    private func callGroupsAPI(){
        
        self.groups = nil
        self.setGroupPopUpButton()
        
        let accessToken = self.accessTokenTextField.stringValue
        self.saveAccessToken(accessToken)
        
        resultTextField.hidden = false
        resultTextField.stringValue = "グループの取得中..."
        let api = FBGroupListParser(accessToken:accessToken)
        api.startAPICall { (result:[FBGroup], error) -> () in
            ThreadUtil.dipatch_async_main({ () -> () in
                if let error = error{
                    DialogUtil.startDialog("\(error)", onClickOKButton: { () -> () in
                    })
                }else{
                    self.groups = result
                    self.setGroupPopUpButton()
                }
                
                self.resultTextField.stringValue = ""
                self.resultTextField.hidden = true
            })
        }
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func updateAccessToken(sender: NSTextField) {
        LogUtil.log()
        let accessToken = sender.stringValue
        self.saveAccessToken(accessToken)
    }

    @IBAction func confirmAccessTokenStatus(sender: NSButton) {
        self.callGroupsAPI()
    }
    
    @IBAction func changeGroup(sender: NSPopUpButton) {
        LogUtil.log(sender.selectedItem?.title)
    }
    
    var isSync = false
    @IBAction func startSync(sender: NSButton) {
        
        if self.isSync{
            DialogUtil.startDialog("同期のキャンセル", onClickOKButton: { () -> () in
                self.isSync = false
            })
            self.resultTextField.hidden = true
            self.resultTextField.stringValue = ""
            return
        }
        
        if let groups = self.groups{
            
            var index:Int?
            index = groups.indexOf({ (group:FBGroup) -> Bool in
                if group.createDisplayedText() == self.groupPopUpButton?.selectedItem?.title{
                    return true
                }
                return false
            })
            
            
            if let index = index{
                let group = groups[index]
                LogUtil.log(group)
                self.startSyncForGroup(group)
            }
        }
    }
    
    private func processInFail(error:ErrorType){
        ThreadUtil.dipatch_async_main({ () -> () in
            DialogUtil.startDialog("同期失敗", message: "\(error)", onClickOKButton: { () -> () in })
            self.resultTextField.hidden = true
            self.resultTextField.stringValue = ""
        })
        self.isSync = false
    }
    
    private func startSyncForGroup(group:FBGroup){
        self.isSync = true
        let accessToken = self.accessTokenTextField.stringValue
        resultTextField.hidden = false
        resultTextField.stringValue = "データ同期中..."
        self.callFBGroupMessageListParser(group, accessToken: accessToken)
    }
    
    /// グループのメッセージリストのダウンロード
    private func callFBGroupMessageListParser(group:FBGroup, accessToken:String){
        let api = FBGroupMessageListParser(groupId: group.groupId, accessToken:accessToken)
        api.startAPICall { (result:[FBMessage], error) -> () in
            if let error = error{
                LogUtil.log(error)
                self.processInFail(error)
            }else{
                self.callFBGroupMessageImageListParser(result, group:group, accessToken: accessToken)
            }
        }
    }
    
//    /// ユーザー画像のダウンロード
//    private func callFileDownloaderForUserImages(messages:[FBMessage], group:FBGroup, accessToken:String){
//        
//        let folderName = [ViewController.FolderName + "_" + group.groupName, "UserImages"]
//        var imagesInfo:[(url: String, fileName: String)] = []
//        for message in messages{
//            let fileName = message.fromUser.id + ".jpg"
//            
//            do{
//                let fileUtil = FileUtil(folderName: folderName)
//                if !(try fileUtil.isFileUnderTheFolder(fileName)){
//                    imagesInfo.append((message.fromUser.url, fileName))
//                }
//            }catch{
//                
//            }
//        }
//        
//        let imageApi = FileDownloader(imagesInfo: imagesInfo, folderName: folderName)
//        imageApi.getDataFromApi({ (error) -> () in
//            if let error = error{
//                self.processInFail(error)
//            }else{
//                self.callFBGroupMessageImageListParser(messages, group:group, accessToken: accessToken)
//            }
//        })
//
//    }
    
    /// 画像URLリストのダウンロード
    private func callFBGroupMessageImageListParser(messages:[FBMessage], group:FBGroup, accessToken:String){
        
        messages.forEach({ (fbmsg) -> () in
            do{
                try fbmsg.createFile([ViewController.FolderName + "_" + group.groupName, "Messages"])
            }catch{
                LogUtil.log(error)
                LogUtil.log(fbmsg.messageId)
            }
        })
        LogUtil.log("一回目のメッセージを保存しました。続けて画像URLのダウンロードを開始します")
        var msgIdWithImage:[String] = []
        messages.forEach({ (fbmsg) -> () in
            if fbmsg.hasPicture{
                msgIdWithImage.append(fbmsg.messageId)
            }
        })
        
        let api = FBGroupMessageImageListParser(msgIds: msgIdWithImage, accessToken: accessToken)
        api.startAPICall { (result:[FBPicture], error) -> () in
            LogUtil.log("画像URLのダウンロードを終了しました")
            
            if let error = error{
                self.processInFail(error)
            }else{
                self.callFileDownloader(group, pictures: result)
            }
        }
    }
    
    /// 画像のダウンロード
    private func callFileDownloader(group:FBGroup, pictures:[FBPicture]){
        var imagesInfo:[(url: String, fileName: String)] = []
        for picture in pictures{
            var num = 0
            for url in picture.urls{
                imagesInfo.append((url, "\(picture.messageId)_\(num).jpg"))
                num = num + 1
            }
        }
        let imageApi = FileDownloader(imagesInfo: imagesInfo, folderName: [ViewController.FolderName + "_" + group.groupName, "Images"])
        imageApi.getDataFromApi({ (error) -> () in
            if let error = error{
                self.processInFail(error)
            }else{
                ThreadUtil.dipatch_async_main({ () -> () in
                    DialogUtil.startDialog("同期完了", onClickOKButton: { () -> () in
                    })
                    self.isSync = false
                    self.resultTextField.hidden = true
                    self.resultTextField.stringValue = ""
                })
            }
        })
    }
    
    
    private func saveAccessToken(accessToken:String){
        NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: ViewController.UserDefaultKey.AccessToken)
    }
}

