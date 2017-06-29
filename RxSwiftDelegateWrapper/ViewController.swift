//
//  ViewController.swift
//  RxSwiftDelegateWrapper
//
//  Created by Luka Gabric on 21/05/2017.
//  Copyright © 2017 PROGOS. All rights reserved.
//

import UIKit
import GoogleMobileAds
import RxSwift
import RxCocoa

class ViewController: UIViewController {
	
	@IBOutlet private weak var bannerContainer: UIView!
	@IBOutlet private weak var bannerContainerBottom: NSLayoutConstraint!
	@IBOutlet private weak var showInterstitialButton: UIButton!
	
	private let bannerAdUnitID = "ca-app-pub-3940256099942544/6300978111"
	private let interstitialAdUnitID = "ca-app-pub-3940256099942544/1033173712"
	
	private let disposeBag = DisposeBag()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.showInterstitialButton.rx.tap.asDriver().drive(onNext: { [weak self] in self?.showInterstitial() }).disposed(by: self.disposeBag)
		self.configureBanner()
	}
	
	private func configureBanner() {
		let bannerView = GADBannerView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
		bannerView.adUnitID = self.bannerAdUnitID
		bannerView.rootViewController = self
		
		let request = GADRequest()
		request.testDevices = [kGADSimulatorID]
		bannerView.load(request)
		
		self.bannerContainer.addSubview(bannerView)
		
		self.bannerContainerBottom.constant = -50
		self.view.layoutIfNeeded()
		
		bannerView.rx.didReceiveAd.subscribe(
			onNext: { [weak self] _ in
				UIView.animate(withDuration: 0.5) {
					guard let sself = self else { return }
					
					sself.bannerContainerBottom.constant = 0
					sself.view.layoutIfNeeded()
				}
		}).disposed(by: self.disposeBag)
	}
	
	private func showInterstitial() {
		let interstitial = GADInterstitial(adUnitID: self.interstitialAdUnitID)
		let request = GADRequest()
		request.testDevices = [kGADSimulatorID]
		interstitial.load(request)
		
		let didReceiveAd = interstitial.rx.didReceiveAd
		didReceiveAd.subscribe(onCompleted: { interstitial.present(fromRootViewController: self) }).disposed(by: self.disposeBag)
		
		let buttonEnabled = didReceiveAd
			.map { _ in true }
			.catchErrorJustReturn(true)
			.startWith(false)
		buttonEnabled.bind(to: self.showInterstitialButton.rx.isEnabled).disposed(by: self.disposeBag)
	}
	
}
