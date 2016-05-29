//
//  ConnectionUtilTests.swift
//  FacebookAPI
//
//  Created by yuya on 2016/05/25.
//  Copyright © 2016年 yuya. All rights reserved.
//

import XCTest
@testable import FacebookAPI

class ConnectionUtilTests: XCTestCase {
    override func setUp() {
        super.setUp()
        LogUtil.log("---------------------------------------------")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func test00_ConnectionUtil(){
        let expectation = expectationWithDescription("")
        
        let access_token = FacebookAPITests.SharedAccessToken
        
        
        let node = "me"
        let test = ConnectionUtil(url: "https://graph.facebook.com/v2.6/\(node)?access_token=\(access_token)", parameters: nil, method:.Get)
        test.call() { (data:NSData?, response:NSURLResponse?, error:ErrorType?) -> () in
            XCTAssertNotNil(error)
            if let data = data{
                LogUtil.log(NSString(data:data, encoding:NSUTF8StringEncoding))
            }
            expectation.fulfill()
        }
        test.stopConnection()
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
    }
    
    func test01_LargeFile(){
        let expectation = expectationWithDescription("")
        
        
        
        let url = "http://202.18.171.2/doctor/docc0094-T.Shindo/docc0094_2013.pdf"
        let test = ConnectionUtil(url: url, parameters: nil, method:.Get)
        test.call() { (data:NSData?, response:NSURLResponse?, error:ErrorType?) -> () in
            XCTAssertNil(error)
            XCTAssert(data != nil, "dataなし")
            if let data = data{
                do{
                    let fileName = "sample.pdf"
                    LogUtil.log(fileName)
                    try FileUtil(folderName: ["test01_LargeFile"]).saveData(data, fileName: fileName)
                }catch{
                    XCTAssertNil(error)
                }
            }else{
                
            }
            expectation.fulfill()
        }
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
    }
    
    func test02_LargeFile_Cancel(){
        let expectation = expectationWithDescription("")
        
        let url = "http://202.18.171.2/doctor/docc0094-T.Shindo/docc0094_2013.pdf"
        let test = ConnectionUtil(url: url, parameters: nil, method:.Get)
        test.call() { (data:NSData?, response:NSURLResponse?, error:ErrorType?) -> () in
            XCTAssertNotNil(error)
            XCTAssert(data == nil, "dataあり")
            if let data = data{
                do{
                    let fileName = "sample_cancel.pdf"
                    LogUtil.log(fileName)
                    try FileUtil(folderName: ["test02_LargeFile_Cancel"]).saveData(data, fileName: fileName)
                }catch{
                    XCTAssertNil(error)
                }
            }
            expectation.fulfill()
        }
        test.stopConnection()
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
    }
    
}