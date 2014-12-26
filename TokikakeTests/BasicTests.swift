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
    
    func testSyncDone() {
        Deferred<String, String, Int>().fulfill("ok").promise
            .done { value in
                XCTAssertEqual(value, "ok")
            }
            .fail { error in
                XCTFail()
            }
            .always {
            }
    }
    
    func testSyncFail() {
        Deferred<String, String, Int>().reject("ng").promise
            .done { value in
                XCTAssertEqual(value, "ok")
            }
            .fail { error in
                XCTFail()
            }
            .always {
        }
    }
    
    func testDone() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String, Int>()
        performInBackground(after: 0.1) {
            deferred.fulfill("ok")
            return
        }
        
        deferred.promise
            .done { value in
                XCTAssertEqual(value, "ok")
            }
            .fail { error in
                XCTFail()
            }
            .always {
                ex.fulfill()
            }
        
        self.waitForExpectationsWithTimeout(100) { error in
            XCTAssertNil(error)
        }
    }
   
    func testFail() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String, Float>()
        performInBackground(after: 0.1) {
            deferred.reject("ng")
            return
        }
        
        deferred.promise
            .done { value in
                XCTFail()
            }
            .fail { error in
                XCTAssertEqual(error, "ng")
            }
            .always {
                ex.fulfill()
            }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testProgress() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String, Int>()
        performInBackground(after: 0.1) {
            for i in 0..<10 {
                deferred.notify(i)
            }
            deferred.fulfill("ok")
        }
        
        deferred.promise
            .progress { progress in
                println("progress: " + String(progress))
            }
            .done { value in
                XCTAssertEqual(value, "ok")
            }
            .fail { error in
                XCTFail()
            }
            .always {
                ex.fulfill()
            }
        
        self.waitForExpectationsWithTimeout(100) { error in
            XCTAssertNil(error)
        }
    }
    
    func testThenIfFulfilled() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String, Float>()
        performInBackground(after: 0.1) {
            deferred.fulfill("ok")
            return
        }
        
        deferred.promise
            .then { value, error -> Void in
                XCTAssertNotNil(value)
                XCTAssertNil(error)
                
                XCTAssertEqual(value!, "ok")
            }
            .always {
                ex.fulfill()
            }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testThenIfRejected() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String, Float>()
        performInBackground(after: 0.1) {
            deferred.reject("ng")
            return
        }
        
        deferred.promise
            .then { value, error in
                XCTAssertNil(value)
                XCTAssertNotNil(error)
                
                XCTAssertEqual(error!, "ng")
            }
            .always {
                ex.fulfill()
            }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testDoneThenChainIfFulfilled() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String, Float>()
        performInBackground(after: 0.1) {
            deferred.fulfill("ok")
            return
        }
        
        deferred.promise
            .done { value in
                XCTAssertEqual(value, "ok")
            }
            .fail { error in
                XCTFail()
            }
            .then { value, error in
                XCTAssertNotNil(value)
                XCTAssertNil(error)
                XCTAssertEqual(value!, "ok")
            }
            .always {
                ex.fulfill()
            }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testPromiseChainIfFulfilled() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String, Float>()
        performInBackground(after: 0.1) {
            deferred.fulfill("ok")
            return
        }
        
        deferred.promise
            .done { (value: String) in
                XCTAssertEqual(value, "ok")
            }
            .fail { (error: String) in
                XCTFail()
            }
            .then { (value: String?, error: String?) -> Promise<Int, Int, Float> in
                if error != nil {
                    XCTFail()
                    return Deferred<Int, Int, Float>().reject(999).promise
                }
                
                let deferred2 = Deferred<Int, Int, Float>()
                self.performInBackground(after: 0.1) {
                    deferred2.fulfill(1)
                    return
                }
                return deferred2.promise
            }
            .done { (value: Int) in
                XCTAssertEqual(value, 1)
            }
            .fail { (error: Int) in
                XCTFail()
            }
            .always {
                ex.fulfill()
            }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testPromiseChainIfRejectedButComebackFulfill() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred = Deferred<String, String, Float>()
        performInBackground(after: 0.1) {
            deferred.reject("ng")
            return
        }
        
        deferred.promise
            .done { (value: String) in
                XCTFail()
            }
            .fail { (error: String) in
                XCTAssertEqual(error, "ng")
            }
            .then { (value: String?, error: String?) -> Promise<Int, Int, Float> in
                if error != nil {
                    return Deferred<Int, Int, Float>().fulfill(1).promise
                }
                
                XCTFail()
                let deferred2 = Deferred<Int, Int, Float>()
                self.performInBackground(after: 0.1) {
                    deferred2.fulfill(1)
                    return
                }
                return deferred2.promise
            }
            .done { (value: Int) in
                XCTAssertEqual(value, 1)
            }
            .fail { (error: Int) in
                XCTFail()
            }
            .always {
                ex.fulfill()
            }
        
        self.waitForExpectationsWithTimeout(10) { error in
            XCTAssertNil(error)
        }
    }
    
    func testWhenIfFulfilled() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred1 = Deferred<String, String, Float>()
        performInBackground(after: 0.1) {
            deferred1.fulfill("ok1")
            return
        }
        
        let deferred2 = Deferred<String, String, Float>()
        performInBackground(after: 0.2) {
            deferred2.fulfill("ok2")
            return
        }
        
        let deferred3 = Deferred<String, String, Float>()
        performInBackground(after: 0.3) {
            deferred3.fulfill("ok3")
            return
        }
        
        Promise.when(deferred1.promise, deferred2.promise, deferred3.promise)
            .progress { count, total in
                println(String(count) + "/" + String(total))
            }
            .done { values in
                println(values)
            }
            .always {
                ex.fulfill()
            }
        
        self.waitForExpectationsWithTimeout(100) { error in
        }
    }
    
    func testWhenIfRejectd() {
        let ex = self.expectationWithDescription("wait")
        
        let deferred1 = Deferred<String, String, Float>()
        performInBackground(after: 0.1) {
            deferred1.fulfill("ok")
            return
        }
        
        let deferred2 = Deferred<String, String, Float>()
        performInBackground(after: 0.2) {
            deferred2.reject("ng")
            return
        }
        
        Promise.when(deferred1.promise, deferred2.promise)
            .progress { count, total in
                println(String(count) + "/" + String(total))
            }
            .done { values in
                println(values)
                XCTFail()
            }
            .fail { error in
                XCTAssertEqual(error, "ng")
            }
            .always {
                ex.fulfill()
            }
        
        self.waitForExpectationsWithTimeout(100) { error in
        }
    }
    
    private func performInBackground(after delay: Double, _ handler: () -> Void) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))),
            dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
            handler)
    }
}
