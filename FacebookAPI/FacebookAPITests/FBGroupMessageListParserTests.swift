//
//  FBGroupMessageListParserTests.swift
//  FacebookAPI
//
//  Created by yuya on 2016/05/28.
//  Copyright © 2016年 yuya. All rights reserved.
//
import XCTest
@testable import FacebookAPI

class FBGroupMessageListParserTests: XCTestCase {
    override func setUp() {
        super.setUp()
        LogUtil.log("---------------------------------------------")
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test00(){
        let expectation = expectationWithDescription("")
        let groupId = "147169992355159"
        let api = FBGroupMessageListParser(groupId: groupId, accessToken:FacebookAPITests.SharedAccessToken)
        api.startAPICall { (result, error) -> () in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            LogUtil.log(result)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
    }
}
