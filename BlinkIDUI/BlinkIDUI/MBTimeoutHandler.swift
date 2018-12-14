//
//  MBTimeoutHandler.swift
//  BlinkIDUI
//
//  Created by Jure Čular on 28/11/2018.
//  Copyright © 2018 Microblink. All rights reserved.
//

import Foundation

/// This protocol can be used to define how to handle various events.
/// By default it's used to capture events to stop/start timeout timer.
/// - See: `MBDefaultTimeoutHandler` to understand how this can be used
@objc public protocol MBTimeoutHandler: AnyObject {
    
    /// Needed to present alert view controller once the timeout it out.
    @objc weak var overlayViewController: MBBlinkIdOverlayViewController? { get set }
    
    /// Called everytime scanning is started
    @objc func onScanStart()
    
    /// Called once the scanning is done
    @objc func onScanDone()
    
    /// Called once the scanning is paused
    @objc func onScanPaused()
    
    /// Called once the scanning is resumed
    @objc func onScanResumed()
    
}

/// `MBDefaultTimeoutHandler` is used to present the user with an `UIAlertController`
/// that notifes them that they can change the Country/Document being scanned.
/// If *timerTimeout* number of seconds pass without any successfull results this class will present
/// a `UIAlertController` with a message to user to try changing the Country.
@objc public class MBDefaultTimeoutHandler: NSObject, MBTimeoutHandler {
    
    /// Needed to present alert view controller once the timeout it out.
    @objc public weak var overlayViewController: MBBlinkIdOverlayViewController?
    
    private var _timeoutTimer: Timer?
    private let _startTimerTimeout: TimeInterval
    private var _currentTimerTimeout: TimeInterval
    
    @objc public required init(timerTimeout: TimeInterval = 16) {
        _startTimerTimeout = timerTimeout
        _currentTimerTimeout = timerTimeout
    }
    
    /// Called everytime scanning is started
    @objc public func onScanStart() {
        _currentTimerTimeout = _startTimerTimeout
        _destroyTimer()
        _createTimer()
    }
    
    /// Called once the scanning is done
    @objc public func onScanDone() {
        _destroyTimer()
    }
    
    /// Called once the scanning is paused
    @objc public func onScanPaused() {
        _destroyTimer()
    }
    
    /// Called once the scanning is resumed
    @objc public func onScanResumed() {
        _createTimer()
    }
    
    private func _destroyTimer() {
        _timeoutTimer?.invalidate()
        _timeoutTimer = nil
    }
    
    private func _createTimer() {
        _timeoutTimer = Timer.scheduledTimer(timeInterval: _currentTimerTimeout, target: self, selector: #selector(onTimeout), userInfo: nil, repeats: false)
    }
    
    @objc func onTimeout() {
        _destroyTimer()
        overlayViewController?.recognizerRunnerViewController?.pauseScanning()
        _currentTimerTimeout = 2 * _currentTimerTimeout

        let alertController = _createAlertController()
        
        overlayViewController?.present(alertController, animated: true, completion: nil)
    }
    
    private func _createAlertController() -> UIAlertController {
        let languageSettings = MBBlinkSettings.sharedInstance.languageSettings
        let recognizerRunnerViewController = self.overlayViewController?.recognizerRunnerViewController
        
        let alertController = UIAlertController(title: languageSettings.timeoutAlertTitleText, message: languageSettings.timeoutAlertMessageText, preferredStyle: .alert)
        alertController.view.tintColor = UIColor.mb_primaryColor
        
        let continueButton = UIAlertAction(title: languageSettings.continueActionText, style: .cancel) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self._createTimer()
            recognizerRunnerViewController?.resumeScanningAndResetState(false)
        }
        
        let changeCountryButton = UIAlertAction(title: languageSettings.changeCountryActionText, style: .default) { (_) in
            if let documentChooserViewController = self.overlayViewController?.documentChooserViewController {
                MBBlinkSettings.sharedInstance.documentChooserSettings.didTapChooseCountry(documentChooserViewController: documentChooserViewController)
            }
            recognizerRunnerViewController?.resumeScanningAndResetState(false)
        }
        
        alertController.addAction(continueButton)
        alertController.addAction(changeCountryButton)
        
        alertController.preferredAction = continueButton
        return alertController
    }
}