//
//  NSURLConnectionTests.swift
//  Tokikake
//
//  Created by yushan on 2014/12/25.
//  Copyright (c) 2014年 yukiame. All rights reserved.
//

import UIKit
import XCTest

import Tokikake

class NSURLConnectionTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test1() {
        let ex = self.expectationWithDescription("wait")
        
        NSURLConnection.request("http://github.com", "GET")
            .done { data in
                println("done: " + String(data.length))
            }
            .fail { error in
                println("fail: " + error.description)
            }
            .always {
                ex.fulfill()
            }
        
        self.waitForExpectationsWithTimeout(10) { error -> Void in
        }
    }
}
