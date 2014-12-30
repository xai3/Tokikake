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
    
    public class func request(url: String, _ method: String, _ body: NSData? = nil) -> Promise<NSData, NSError, Float> {
        let deferred = Deferred<NSData, NSError, Float>()
        
        let request = NSMutableURLRequest()
        request.URL = NSURL(string: url)!
        request.HTTPMethod = method
        request.HTTPBody = body
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            if let error = error {
                deferred.reject(error)
                return
            }
            
            deferred.resolve(data!)
        }
        return deferred.promise
    }
	
	public class func request(url: String) -> Promise<UIImage, NSError, Float> {
		let deferred = Deferred<UIImage, NSError, Float>()
		
		let request = NSMutableURLRequest()
		request.URL = NSURL(string: url)!
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
			if let error = error {
				deferred.reject(error)
				return
			}
			
			let image = UIImage(data: data!)
			deferred.resolve(image!)
		}
		return deferred.promise
	}
	
}
