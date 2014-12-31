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
	
	func testImageIfResolved() {
		let ex = self.expectationWithDescription("wait")
		
		NSURLConnection.request("https://www.google.co.jp/images/srpr/logo11w.png")
			.done { (image: UIImage) in
				println("done: " + image.description)
				XCTAssertTrue(image.size != CGSizeZero)
			}
			.fail { error in
				println("fail: " + error.description)
				XCTFail()
			}
			.always {
				ex.fulfill()
		}
		
		self.waitForExpectationsWithTimeout(10) { error -> Void in
		}
	}
	
	func testImageIfRejected() {
		let ex = self.expectationWithDescription("wait")
		
		NSURLConnection.request("http://google.com/invalid.jpg")
			.done { (image: UIImage) in
				XCTFail()
			}
			.fail { error in
				println("fail: " + error.localizedDescription)
			}
			.always {
				ex.fulfill()
			}
		
		self.waitForExpectationsWithTimeout(10) { error -> Void in
		}
	}
	
}
