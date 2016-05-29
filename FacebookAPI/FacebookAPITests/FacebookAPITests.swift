//
//  FacebookAPITests.swift
//  FacebookAPITests
//
//  Created by yuya on 2016/05/14.
//  Copyright © 2016年 yuya. All rights reserved.
//

import XCTest
@testable import FacebookAPI

class FacebookAPITests: XCTestCase {
    
    
    
    
    static let SharedAccessToken = ""
    
    override func setUp() {
        super.setUp()
        LogUtil.log("---------------------------------------------")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func test00_FacebookURL_ACCESS_TOKEN(){
//        graph.facebook.com/oauth/access_token?client_id=743885552423548&client_secret=6a35cd011dcf04e7704f2ec14779fb35&grant_type=client_credentials
        
        
        let expectation = expectationWithDescription("")
        let node = "oauth"
        let edge = "access_token"
        let parameters = ["client_id":"743885552423548", "client_secret":"6a35cd011dcf04e7704f2ec14779fb35", "grant_type":"client_credentials"]
        
        
        let manager = FaceBookAPIManager(node: node, edge: edge, params: parameters)
        manager.startAPICall { (dict, error) -> () in
            XCTAssertNil(error)
            XCTAssertNotEqual(dict, [:])
            
            LogUtil.log(dict)
            
            expectation.fulfill()
        }
        
        
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
        
        
    }
    
    func test00_FacebookURL() {
        let expectation = expectationWithDescription("")
        
        let access_token = FacebookAPITests.SharedAccessToken
        
        
        let node = "me"
        let test = ConnectionUtil(url: "https://graph.facebook.com/v2.6/\(node)?access_token=\(access_token)", parameters: nil, method:.Get)
        test.call() { (data:NSData?, response:NSURLResponse?, error:ErrorType?) -> () in
            XCTAssertNil(error)
            if let data = data{
                LogUtil.log(NSString(data:data, encoding:NSUTF8StringEncoding))
            }
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
    }
    
    func test01_FacebookURL() {
        let expectation = expectationWithDescription("")
        
        let access_token = FacebookAPITests.SharedAccessToken
        let groupId = "1343498652344664"

        
        let node = groupId
        let edge = "feed"
        let test = ConnectionUtil(url: "https://graph.facebook.com/\(node)/\(edge)?access_token=\(access_token)", parameters: nil, method:.Get)
        test.call() { (data:NSData?, response:NSURLResponse?, error:ErrorType?) -> () in
            XCTAssertNil(error)
            if let data = data{
                LogUtil.log(NSString(data:data, encoding:NSUTF8StringEncoding))
            }
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
    }
    
    func test02_FacebookURL_groupFile() {
        let expectation = expectationWithDescription("")
        
        let access_token = FacebookAPITests.SharedAccessToken
        let groupId = "1343498652344664"
        
        
        let node = groupId
        let edge = "files"
        let test = ConnectionUtil(url: "https://graph.facebook.com/\(node)/\(edge)?access_token=\(access_token)", parameters: nil, method:.Get)
        test.call() { (data:NSData?, response:NSURLResponse?, error:ErrorType?) -> () in
            XCTAssertNil(error)
            if let data = data{
                LogUtil.log(NSString(data:data, encoding:NSUTF8StringEncoding))
            }
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
    }
    
    // 特定のグループのアルバムの写真のURLを取得するテスト
    func test03_FacebookURL_groupAlbumsWithPhotosIds() {
        let expectation = expectationWithDescription("")
        
        let access_token = FacebookAPITests.SharedAccessToken
        let groupId = "1343498652344664"
        
        
        let node = groupId
        let edge = "albums"
        let parameters = ["access_token":"\(access_token)", "fields":"photos"]
        let test = ConnectionUtil(url: "https://graph.facebook.com/\(node)/\(edge)?", parameters: parameters, method:.Get)
        test.call() { (data:NSData?, response:NSURLResponse?, error:ErrorType?) -> () in
            XCTAssertNil(error)
            if let data = data{
                LogUtil.log(NSString(data:data, encoding:NSUTF8StringEncoding))
            }
            
            struct JsonKey{
                
            }
            
            
            
            
            
            
            
            
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
    }
    
    // 特定のグループのフィード取得(メッセージと写真)
    func test04_FacebookURL_groupMessages() {
        let expectation = expectationWithDescription("")
        
        let access_token = FacebookAPITests.SharedAccessToken
        let groupId = "1343498652344664"
        
        let node = groupId
        let edge = "feed"
        let parameters = ["access_token":"\(access_token)", "fields":"story, message, picture"]
        
        
        let manager = FaceBookAPIManager(node: node, edge: edge, params: parameters)
        manager.startAPICall { (dict, error) -> () in
            XCTAssertNil(error)
            XCTAssertNotEqual(dict, [:])
            
            LogUtil.log(dict)
            
            expectation.fulfill()
        }
        
        
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
    }
    
    // 特定のグループのフィード取得(メッセージと写真)
    func test05_FacebookURL_groupAttachmentsOfSpecificMessage() {
        let expectation = expectationWithDescription("")
        
        let access_token = FacebookAPITests.SharedAccessToken
        let messageId = "1343498652344664_1349431868418009"
        
        let node = messageId
        let edge = "attachments"
        let parameters = ["access_token":"\(access_token)"]
        
        
        let manager = FaceBookAPIManager(node: node, edge: edge, params: parameters)
        manager.startAPICall { (dict, error) -> () in
            XCTAssertNil(error)
            LogUtil.log(error)
            XCTAssertNotEqual(dict, [:])
            
            LogUtil.log(dict)
            
            expectation.fulfill()
        }
        
        
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
    }
    
    
    func test06_Image(){
        
        let expectation = expectationWithDescription("")
    
        
        let fileDownloader = FileDownloader(imagesInfo: [("https://scontent.xx.fbcdn.net/v/t1.0-9/s720x720/13245280_266185977065641_4080831858092387733_n.jpg?oh=583c69d5c633b2ef56a1ba15f0a9398f&oe=57D4AC9F", "13245280_266185977065641_4080831858092387733_n.jpg")], folderName: ["test"])
        
        fileDownloader.getDataFromApi { (error) -> () in
            XCTAssertNil(error)
            LogUtil.log(error)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
        
    }
    
    func test07_Member(){
        let expectation = expectationWithDescription("")
        
        let access_token = FacebookAPITests.SharedAccessToken
        let groupId = "1343498652344664"
        
        let node = groupId
        let edge = "members"
        let parameters = ["access_token":"\(access_token)", "fields":"name, picture"]
        
        
        let manager = FaceBookAPIManager(node: node, edge: edge, params: parameters)
        manager.startAPICall { (dict, error) -> () in
            XCTAssertNil(error)
            XCTAssertNotEqual(dict, [:])
            
            LogUtil.log(dict)
            
            expectation.fulfill()
        }
        
        
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
