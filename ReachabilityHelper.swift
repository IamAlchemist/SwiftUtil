//
//  ReachabilityHelper.swift
//  H5Cache
//
//  Created by wizard lee on 9/2/16.
//  Copyright © 2016 wizard lee. All rights reserved.
//

import Foundation
#if !ASSRC
import CleanroomLogger
#endif

protocol ReachabilityHelperDelegate: class {
    func reachabilityChanged(reachability:Reachability)
}

class ReachabilityHelper {
    static let defaultHelper = ReachabilityHelper()
    
    private var reachability : Reachability?
    
    weak var delegate : ReachabilityHelperDelegate?
    
    var whenReachable : Reachability.NetworkReachable? {
        get {
            return reachability?.whenReachable
        }
        
        set {
            reachability?.whenReachable = newValue
        }
    }
    
    var whenUnreachable : Reachability.NetworkUnreachable? {
        get {
            return reachability?.whenUnreachable
        }
        
        set {
            reachability?.whenUnreachable = newValue
        }
    }
    
    var currentReachabilityStatus : Reachability.NetworkStatus {
        return reachability?.currentReachabilityStatus ?? .NotReachable
    }
    
    init(hostName hostName: String? = nil) {
        do {
            if let hostName = hostName {
                reachability = try Reachability(hostname: hostName)
            }
            else {
                reachability = try Reachability.reachabilityForInternetConnection()
            }
        } catch ReachabilityError.FailedToCreateWithAddress(let address) {
            Log.error?.message("Unable to create\nReachability with address:\n\(address)")
            return
        } catch {}
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: ReachabilityChangedNotification, object: reachability)
    }
    
    func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            Log.error?.message("Unable to start\nnotifier")
        }
    }
    
    func stopNotifier() {
        reachability?.stopNotifier()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    
    @objc public func reachabilityChanged(note: NSNotification) {
        let reachability = note.object as! Reachability
        
        delegate?.reachabilityChanged(reachability)
    }
    
    deinit {
        stopNotifier()
    }
}