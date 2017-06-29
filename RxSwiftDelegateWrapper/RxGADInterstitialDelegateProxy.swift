//
//  RxGADInterstitialDelegateProxy.swift
//  Shortcuts
//
//  Created by Luka Gabric on 07/04/2017.
//  Copyright © 2017 PROGOS. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
import RxSwift
import RxCocoa

extension Reactive where Base: GADInterstitial {
    
    public var didReceiveAd: Observable<GADInterstitial> {
        let delegateProxy = RxGADInterstitialDelegateProxy.proxyForObject(base)
        
        let didReceiveAd = delegateProxy
            .methodInvoked(#selector(GADInterstitialDelegate.interstitialDidReceiveAd(_:)))
            .map { $0[0] as! GADInterstitial }
        
        let didFailToReceiveAd = delegateProxy
            .methodInvoked(#selector(GADInterstitialDelegate.interstitial(_:didFailToReceiveAdWithError:)))
            .flatMap { input -> Observable<GADInterstitial> in
                var error: NSError? = nil
                
                if input.count == 2, let inputError = input[1] as? NSError {
                    error = inputError
                }
                
                return Observable.error(error ?? NSError(domain: "", code: 0, userInfo: nil))
        }
        
        let merged = Observable.of(didReceiveAd, didFailToReceiveAd).merge().take(1).shareReplay(1)
        return merged
    }
    
}

public class RxGADInterstitialDelegateProxy: DelegateProxy, DelegateProxyType, GADInterstitialDelegate {
    
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let interstitial = object as! GADInterstitial
        return interstitial.delegate
    }
    
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let interstitial = object as! GADInterstitial
        interstitial.delegate = delegate as? RxGADInterstitialDelegateProxy
    }

    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let interstitial = object as! GADInterstitial
        return RxGADInterstitialDelegateProxy(parentObject: interstitial)
    }
    
}
