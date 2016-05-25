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
    
    @IBOutlet weak var accessTokenTextField: NSTextField!
    @IBOutlet weak var resultTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        LogUtil.log("log")
        if let accessToken =  NSUserDefaults.standardUserDefaults().stringForKey(UserDefaultKey.AccessToken){
            self.accessTokenTextField.stringValue = accessToken
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
        
        let accessToken = self.accessTokenTextField.stringValue
        self.saveAccessToken(accessToken)
            
        
        let params = ["access_token":accessToken]
        let faceBookAPI = FaceBookAPIManager(node: "me", params:params)
        faceBookAPI.startAPICall { (dict, error) -> () in
            if let error = error{
                self.resultTextField.stringValue = "\(error)"
            }else{
                self.resultTextField.stringValue = "有効"
            }
            
        }
        
    }
    
    
    private func saveAccessToken(accessToken:String){
        NSUserDefaults.standardUserDefaults().setObject(accessToken, forKey: ViewController.UserDefaultKey.AccessToken)
    }
}

