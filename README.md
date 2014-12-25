# Tokikake

Tokikae is a [JQuery.Deferred](http://api.jquery.com/category/deferred-object/)-like API written in Swift.

## Requirements

- iOS 7.0+
- Xcode 6.1

## Usage

### Basic

- `promise.done` will be called by `deferred.fulfill`.
- `promise.fail` will be called by `deferred.reject`.

```swift
let deferred = Deferred<String, String>()
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
    deferred.fulfill("ok")
//    deferred.reject("ng")
}

deferred.promise
    .done { (value: String) in
      // do something
    }
    .fail { (error: String) in
      // do something
    }
```


- `promise.then` will be called by `deferred.fulfill` or `deferred.reject`.
- `promise.finally` is always called.

```swift
let deferred = Deferred<String, String>()
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
//    deferred.fulfill("ok")
    deferred.reject("ng")
}

deferred.promise
    .then { (value: String?, error: String?) in
      // do something
    }
    .finally {
      // do something
    }
```

### Chaining

It is possible to return the new promise in `then`, so that you can be chained to the next operation.

```swift
let deferred = Deferred<String, String>()
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
    deferred.fulfill("ok")
}

deferred.promise
    .then { (value: String?, error: String?) -> Promise<Int, Int> in
        if error != nil {
            return Deferred<Int, Int>().reject(999).promise
        }
        
        let deferred2 = Deferred<Int, Int>()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            deferred2.fulfill(1)
        }
        return deferred2.promise
    }
    .done { (value: Int) in
      // do something
    }
    .fail { (error: Int) in
      // do something
    }
    .finally {
      // do something
    }
```
