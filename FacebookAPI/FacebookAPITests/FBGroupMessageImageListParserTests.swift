//
//  FBGroupMessageImageListParserTests.swift
//  FacebookAPI
//
//  Created by yuya on 2016/05/29.
//  Copyright © 2016年 yuya. All rights reserved.
//

import XCTest
import XCTest
@testable import FacebookAPI

class FBGroupMessageImageListParserTests: XCTestCase {
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
        let msgIds = ["147169992355159_147171732354985", "147169992355159_149805615424930"]
        let api = FBGroupMessageImageListParser(msgIds: msgIds, accessToken: FacebookAPITests.SharedAccessToken)
        api.startAPICall { (result:[FBPicture], error) -> () in
            XCTAssertNil(error)
            XCTAssertNotNil(result)
            LogUtil.log(result)
            LogUtil.log("メッセージ数:\(result.count)")
            for r in result{
                LogUtil.log("URL数:\(r.urls.count)")
            }
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(600.0) { (error:NSError?) -> Void in
            XCTAssertNil(error)
        }
    }
}