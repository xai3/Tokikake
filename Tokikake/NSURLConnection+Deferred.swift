//
//  NSURLConnection+Deferred.swift
//  Tokikake
//
//  Created by yushan on 2014/12/25.
//  Copyright (c) 2014年 yukiame. All rights reserved.
//

import Foundation

import Tokikake

extension NSURLConnection {
    
    public class func request(url: String, _ method: String, _ body: NSData? = nil) -> Promise<NSData, NSError> {
        let deferred = Deferred<NSData, NSError>()
        
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: url)!
        request.HTTPMethod = method
        request.HTTPBody = body
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if let error = error {
                deferred.reject(error)
                return
            }
            
            deferred.fulfill(data!)
        }
        return deferred.promise
    }
    
}
