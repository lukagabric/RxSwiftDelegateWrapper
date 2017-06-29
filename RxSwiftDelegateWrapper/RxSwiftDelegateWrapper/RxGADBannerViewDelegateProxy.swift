//
//  RxGADBannerViewDelegateProxy.swift
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

extension Reactive where Base: GADBannerView {
    
    public var didReceiveAd: Observable<GADBannerView> {
        let delegateProxy = RxGADBannerViewDelegateProxy.proxyForObject(base)
        
        let didReceiveAd = delegateProxy
            .methodInvoked(#selector(GADBannerViewDelegate.adViewDidReceiveAd(_:)))
            .map { $0[0] as! GADBannerView }

        let didFailToReceiveAd = delegateProxy
            .methodInvoked(#selector(GADBannerViewDelegate.adView(_:didFailToReceiveAdWithError:)))
            .flatMap { input -> Observable<GADBannerView> in
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

public class RxGADBannerViewDelegateProxy: DelegateProxy, DelegateProxyType, GADBannerViewDelegate {
    
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let bannerView = object as! GADBannerView
        return bannerView.delegate
    }
    
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let bannerView = object as! GADBannerView
        bannerView.delegate = delegate as? RxGADBannerViewDelegateProxy
    }

    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let bannerView = object as! GADBannerView
        return RxGADBannerViewDelegateProxy(parentObject: bannerView)
    }
    
}
