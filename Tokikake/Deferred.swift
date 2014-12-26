//
//  Deferred.swift
//  Tokikake
//
//  Created by yushan on 2014/12/25.
//  Copyright (c) 2014年 yukiame. All rights reserved.
//

import Foundation

internal var queue: dispatch_queue_t = dispatch_queue_create("me.yukia.Tokikake", nil)

public class Deferred<V, E, P> {
    private var _promise: Promise<V, E, P>
    public var promise: Promise<V, E, P> {
        get { return _promise }
    }
    
    public init() {
        _promise = Promise<V, E, P>()
    }
    
    public func fulfill(value: V) -> Self {
        promise.fulfill(value)
        return self
    }
    
    public func reject(error: E) -> Self {
        promise.reject(error)
        return self
    }
    
    public func notify(progress: P) -> Self {
        promise.notify(progress)
        return self
    }
}

private enum State {
    case Fulfilled
    case Rejected
    case Pending
}

public class Promise<V, E, P> {
    
    public typealias BulkProgress = (Int, Int)
    
    typealias Handler = () -> ()
    
    typealias DoneHandler = (V) -> ()
    typealias FailHandler = (E) -> ()
    typealias ThenHandler = (V?, E?) -> ()
    typealias ProgressHandler = (P) -> ()
    
    var value: V?
    var error: E?
    
    private var state: State = .Pending
    
    public var fulfilled: Bool { return state == .Fulfilled }
    public var rejected: Bool { return state == .Rejected }
    public var pending: Bool { return state == .Pending }
   
    private var pendingHandlers: [Handler] = []
    private var progressHandlers: [ProgressHandler] = []
    
    internal init() {
    }
    
    internal func fulfill(value: V) {
        dispatch_async(queue) {
            if !self.pending {
                return
            }
            self.value = value
            self.state = .Fulfilled
            
            for handler in self.pendingHandlers {
                handler()
            }
            self.pendingHandlers.removeAll()
        }
    }
    
    internal func reject(error: E) {
        dispatch_async(queue) {
            if !self.pending {
                return
            }
            self.error = error
            self.state = .Rejected
            
            for handler in self.pendingHandlers {
                handler()
            }
            self.pendingHandlers.removeAll()
        }
    }
    
    internal func notify(progress: P) {
        dispatch_async(queue) {
            if !self.pending {
                return
            }
            
            for handler in self.progressHandlers {
                handler(progress)
            }
        }
    }
    
    private func handle(handler: Handler) {
        dispatch_async(queue) {
            if self.pending {
                self.pendingHandlers.append(handler)
                return
            }
            handler()
        }
    }
    
    // MARK: Done
    
    public func done(handler: DoneHandler) -> Self {
        handle {
            if self.fulfilled {
                handler(self.value!)
            }
        }
        return self
    }
    
    // MARK: Fail
    
    public func fail(handler: FailHandler) -> Self {
        handle {
            if self.rejected {
                handler(self.error!)
            }
        }
        return self
    }
    
    // MARK: Progress
    
    public func progress(handler: ProgressHandler) -> Self {
        dispatch_async(queue) {
            self.progressHandlers.append(handler)
        }
        return self
    }
    
    // MARK: Always
    
    public func always(handler: () -> ()) -> Self {
        handle {
            handler()
        }
        return self
    }
    
    // MARK: Then
    
    public func then(handler: ThenHandler) -> Self {
        handle {
            handler(self.value, self.error)
        }
        return self
    }
    
    public func then<V2, E2, P2>(handler: (V?, E?) -> Promise<V2, E2, P2>) -> Promise<V2, E2, P2> {
        let deferred = Deferred<V2, E2, P2>()
        
        handle {
            let promise = handler(self.value, self.error)
            promise
                .progress { progress in
                    deferred.notify(progress)
                    return
                }
                .done { value in
                    deferred.fulfill(value)
                    return
                }
                .fail { error in
                    deferred.reject(error)
                    return
                }
        }
        
        return deferred.promise
    }
    
    // MARK: When
    
    public class func when(promises: Promise<V, E, P> ...) -> Promise<[V], E, BulkProgress> {
        return when(promises)
    }
    
    public class func when(promises: [Promise<V, E, P>]) -> Promise<[V], E, BulkProgress> {
        let deferred = Deferred<[V], E, BulkProgress>()
        let totalCount = promises.count
        var successCount = 0
        for promise in promises {
            promise
                .done { value -> Void in
                    sync(self) {
                        successCount++
                        deferred.notify((successCount, totalCount))
                        if successCount < totalCount {
                            return
                        }
                        
                        let values = promises.map { $0.value! }
                        deferred.fulfill(values)
                        return
                    }
                }
                .fail { error -> Void in
                    sync(self) {
                        deferred.reject(error)
                        //TODO: Cancel all
                        return
                    }
                }
        }
        return deferred.promise
    }
}

internal func sync(object: AnyObject, handler: (Void) -> Void) {
    objc_sync_enter(object)
    handler()
    objc_sync_exit(object)
}
