//
//  TokikakeTests.swift
//  TokikakeTests
//
//  Created by yushan on 2014/12/25.
//  Copyright (c) 2014年 yukiame. All rights reserved.
//

import UIKit
import XCTest

import Tokikake

class BasicTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testDone() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String>()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            sleep(1)
            deferred.fulfill("ok")
        }
        
        deferred.promise
            .done { value -> Void in
                XCTAssertEqual(value, "ok")
            }
            .fail { error -> Void in
                XCTFail()
            }
            .finally {
                ex.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testDoneChain() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String>()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            sleep(1)
            deferred.fulfill("ok")
        }
        
        deferred.promise
            .done { value -> Int in
                XCTAssertEqual(value, "ok")
                return 1
            }
            .done { value -> Void in
                XCTAssertEqual(value, 1)
            }
            .fail { error -> Void in
                XCTFail()
            }
            .finally {
                ex.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testFail() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String>()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            sleep(1)
            deferred.reject("ng")
        }
        
        deferred.promise
            .done { value -> Void in
                XCTFail()
            }
            .fail { error -> Void in
                XCTAssertEqual(error, "ng")
            }
            .finally {
                ex.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testFailChain() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String>()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            sleep(1)
            deferred.reject("ng")
        }
        
        deferred.promise
            .done { value -> Void in
                XCTFail()
            }
            .fail { error -> Int in
                XCTAssertEqual(error, "ng")
                return 999
            }
            .fail { error -> Void in
                XCTAssertEqual(error, 999)
            }
            .finally {
                ex.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testThenIfFulfilled() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String>()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            sleep(1)
            deferred.fulfill("ok")
        }
        
        deferred.promise
            .then { value, error -> Void in
                XCTAssertNotNil(value)
                XCTAssertNil(error)
                
                XCTAssertEqual(value!, "ok")
            }
            .finally {
                ex.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testThenIfRejected() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String>()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            sleep(1)
            deferred.reject("ng")
        }
        
        deferred.promise
            .then { value, error -> Void in
                XCTAssertNil(value)
                XCTAssertNotNil(error)
                
                XCTAssertEqual(error!, "ng")
            }
            .finally {
                ex.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testThenChainIfFulfilled() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String>()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            sleep(1)
            deferred.fulfill("ok")
        }
        
        deferred.promise
            .then { value, error -> (Int?, Int?) in
                XCTAssertNotNil(value)
                XCTAssertNil(error)
                XCTAssertEqual(value!, "ok")
                return (1, nil)
            }
            .then { value, error -> Void in
                XCTAssertNotNil(value)
                XCTAssertNil(error)
                XCTAssertEqual(value!, 1)
            }
            .finally {
                ex.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testDoneThenChainIfFulfilled() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String>()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            sleep(1)
            deferred.fulfill("ok")
        }
        
        deferred.promise
            .done { value -> String in
                XCTAssertEqual(value, "ok")
                return value
            }
            .fail { error -> String in
                XCTFail()
                return error
            }
            .then { value, error -> Void in
                XCTAssertNotNil(value)
                XCTAssertNil(error)
                XCTAssertEqual(value!, "ok")
            }
            .finally {
                ex.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testPromiseChainIfFulfilled() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String>()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            sleep(1)
            deferred.fulfill("ok")
        }
        
        deferred.promise
            .done { (value: String) -> String in
                XCTAssertEqual(value, "ok")
                return value
            }
            .fail { (error: String) -> String in
                XCTFail()
                return error
            }
            .then { (value: String?, error: String?) -> Promise<Int, Int> in
                if error != nil {
                    XCTFail()
                    return Deferred<Int, Int>().reject(999).promise
                }
                
                let deferred2 = Deferred<Int, Int>()
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                    sleep(1)
                    deferred2.fulfill(1)
                }
                return deferred2.promise
            }
            .done { (value: Int) -> Void in
                XCTAssertEqual(value, 1)
            }
            .fail { (error: Int) -> Void in
                XCTFail()
            }
            .finally {
                ex.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testPromiseChainIfRejectedButComebackFulfill() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String>()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            sleep(1)
            deferred.reject("ng")
        }
        
        deferred.promise
            .done { (value: String) -> String in
                XCTFail()
                return value
            }
            .fail { (error: String) -> String in
                XCTAssertEqual(error, "ng")
                return error
            }
            .then { (value: String?, error: String?) -> Promise<Int, Int> in
                if error != nil {
                    return Deferred<Int, Int>().fulfill(1).promise
                }
                
                XCTFail()
                let deferred2 = Deferred<Int, Int>()
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                    sleep(1)
                    deferred2.fulfill(1)
                }
                return deferred2.promise
            }
            .done { (value: Int) -> Void in
                XCTAssertEqual(value, 1)
            }
            .fail { (error: Int) -> Void in
                XCTFail()
            }
            .finally {
                ex.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
}
