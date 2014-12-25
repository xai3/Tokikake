//
//  Deferred.swift
//  Tokikake
//
//  Created by yushan on 2014/12/25.
//  Copyright (c) 2014年 yukiame. All rights reserved.
//

import Foundation

internal var queue: dispatch_queue_t = dispatch_queue_create("me.yukia.Tokikake", nil)

public class Deferred<V, E> {
    
    private var _promise: Promise<V, E>
    
    public var promise: Promise<V, E> {
        get { return _promise }
    }
    
    public init() {
        _promise = Promise<V, E>()
    }
    
    public func fulfill(value: V) -> Self {
        promise.fulfill(value)
        return self
    }
    
    public func reject(error: E) -> Self {
        promise.reject(error)
        return self
    }
    
}

private enum State {
    
    case Fulfilled
    case Rejected
    case Pending
    case Cancelled
    
}

public class Promise<V, E> {
    
    typealias Handler = () -> ()
    
    var value: V?
    var error: E?
    
    private var state: State = .Pending
    
    public var fulfilled: Bool { return state == .Fulfilled }
    public var rejected: Bool { return state == .Rejected }
    public var pending: Bool { return state == .Pending }
    
    private var pendingHandler: Handler?
    
    internal init() {
    }
    
    internal func fulfill(v: V) {
        if state != .Pending {
            return
        }
        value = v
        state = .Fulfilled
        handleIfNeeded()
    }
    
    internal func reject(e: E) {
        if state != .Pending {
            return
        }
        error = e
        state = .Rejected
        handleIfNeeded()
    }
    
    private func handle(handler: Handler) {
        dispatch_async(queue) {
            if self.state == .Pending {
                self.pendingHandler = handler
                return
            }
            handler()
        }
    }
    
    private func handleIfNeeded() {
        dispatch_async(queue) {
            self.pendingHandler?()
            self.pendingHandler = nil
        }
    }
    
    // MARK: Done
    
    public func done<V2>(clousure: (V) -> V2) -> Promise<V2, E> {
        let deferred = Deferred<V2, E>()
        self.handle {
            switch self.state {
            case .Fulfilled:
                let value2 = clousure(self.value!)
                deferred.fulfill(value2)
            case .Rejected:
                deferred.reject(self.error!)
            default:
                break
            }
        }
        return deferred.promise
    }
    
    // MARK: Fail
    
    public func fail<E2>(clousure: (E) -> E2) -> Promise<V, E2> {
        let deferred = Deferred<V, E2>()
        self.handle {
            switch self.state {
            case .Fulfilled:
                deferred.fulfill(self.value!)
            case .Rejected:
                let error2 = clousure(self.error!)
                deferred.reject(error2)
            default:
                break
            }
        }
        return deferred.promise
    }
    
    // MARK: Then
    
    public func then<V2, E2>(clousure: (V?, E?) -> (value2: V2?, error2: E2?)) -> Promise<V2, E2> {
        let deferred = Deferred<V2, E2>()
        self.handle {
            switch self.state {
            case .Fulfilled:
                if let value2 = clousure(self.value!, nil).value2 {
                    deferred.fulfill(value2)
                }
            case .Rejected:
                if let error2 = clousure(nil, self.error!).error2 {
                    deferred.reject(error2)
                }
            default:
                break
            }
        }
        return deferred.promise
    }
    
    public func then(clousure: (V?, E?) -> Void) -> Promise<V, E> {
        let deferred = Deferred<V, E>()
        self.handle {
            switch self.state {
            case .Fulfilled:
                clousure(self.value!, nil)
                deferred.fulfill(self.value!)
            case .Rejected:
                clousure(nil, self.error!)
                deferred.reject(self.error!)
            default:
                break;
            }
        }
        return deferred.promise
    }
    
    public func then<V2, E2>(clousure: (V?, E?) -> Promise<V2, E2>) -> Promise<V2, E2> {
        let deferred = Deferred<V2, E2>()
        self.handle {
            let promise = clousure(self.value, self.error)
            promise
                .done { value2 -> Void in
                    deferred.fulfill(value2)
                    return
                }
                .fail { error -> Void in
                    deferred.reject(error)
                    return
            }
            return
        }
        return deferred.promise
    }
    
    // MARK: Finally
    
    public func finally(clousure: () -> ()) -> Promise<V, E> {
        let deferred = Deferred<V, E>()
        self.handle {
            clousure()
        }
        return deferred.promise
    }
    
    // MARK: When
    
    public class func when(promises: Promise<V, E> ...) -> Promise<[V], E> {
        return when(promises)
    }
    
    public class func when(promises: [Promise<V, E>]) -> Promise<[V], E> {
        let deferred = Deferred<[V], E>()
        let totalCount = promises.count
        var successCount = 0
        for promise in promises {
            promise
                .done { value -> Void in
                    sync(self) {
                        if ++successCount < totalCount {
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
