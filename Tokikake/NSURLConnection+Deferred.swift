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
    
    public class func request(url: String, _ method: String = "GET", _ body: NSData? = nil) -> Promise<NSData, NSError, Float> {
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
			
			if data == nil {
				deferred.reject(self.invalidDataError())
				return
			}
			
            deferred.resolve(data!)
        }
        return deferred.promise
    }
	
	public class func request(url: String) -> Promise<UIImage, NSError, Float> {
		let deferred = Deferred<UIImage, NSError, Float>()
		
		request(url, "GET")
			.done { data in
				if let image = UIImage(data: data) {
					deferred.resolve(image)
					return
				}
				
				deferred.reject(self.invalidDataError())
				return
			}
			.fail { error in
				deferred.reject(error)
				return
			}
		
		return deferred.promise
	}
	
	private class func invalidDataError() -> NSError {
		return NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: [NSLocalizedDescriptionKey: "Response data is invalid."])
	}
	
}
