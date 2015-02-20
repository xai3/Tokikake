//
//  AVAudioPlayer+Deferred.swift
//  Tokikake
//
//  Created by yushan on 2015/02/20.
//  Copyright (c) 2015年 yukiame. All rights reserved.
//

import UIKit
import AVFoundation
import ObjectiveC

public typealias AudioPlayerProgress = (currentTime: NSTimeInterval, duration: NSTimeInterval)
public typealias AudioPlayerPromise = Promise<Bool, NSError, AudioPlayerProgress>
typealias AudioPlayerDeferred = Deferred<Bool, NSError, AudioPlayerProgress>

private var proxyKey: UInt8 = 0


extension AVAudioPlayer: AVAudioPlayerDelegate {
    
    private var proxy: AudioPlayerProxy {
        set {
            objc_setAssociatedObject(self, &proxyKey, newValue, UInt(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
        get {
            return objc_getAssociatedObject(self, &proxyKey) as AudioPlayerProxy
        }
    }
    
    public func playAsync(progressInterval: NSTimeInterval = 1) -> AudioPlayerPromise? {
        let result = play()
        if !result {
            return nil
        }
        
        proxy = AudioPlayerProxy(player: self)
        delegate = proxy
        return proxy.deferred.promise
    }
    
}

class AudioPlayerProxy: NSObject, AVAudioPlayerDelegate {
    
    var deferred: AudioPlayerDeferred = AudioPlayerDeferred()
    
    weak var player: AVAudioPlayer?
    
    init(player: AVAudioPlayer) {
        self.player = player
        super.init()
        
        startPlaybackTimer()
    }
    
    deinit {
    }
   
    private var playbackTimer: NSTimer?
    private func startPlaybackTimer() {
        if playbackTimer != nil {
            stopPlaybackTimer()
        }
        playbackTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "playbackTimerTick:", userInfo: nil, repeats: true)
        playbackTimer?.fire()
    }
    
    private func stopPlaybackTimer() {
        playbackTimer?.invalidate()
        playbackTimer = nil
    }
    
    func playbackTimerTick(timer: NSTimer) {
        if player == nil {
            stopPlaybackTimer()
            return
        }
        deferred.notify((player!.currentTime, player!.duration))
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        deferred.resolve(flag)
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer!, error: NSError!) {
        deferred.reject(error)
    }
}