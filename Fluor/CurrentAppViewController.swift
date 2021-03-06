//
//  CurrentAppView.swift
//  Fluor
//
//  Created by Pierre TACCHI on 02/09/16.
//  Copyright © 2016 Pyrolyse. All rights reserved.
//

import Cocoa

class CurrentAppViewController: NSViewController {
    private struct AppData {
        let bundleIdentifier: String?
        let bundleURL: URL?
        
        init(from app: NSRunningApplication) {
            self.bundleIdentifier = app.bundleIdentifier
            self.bundleURL = app.bundleURL
        }
    }
    
    @IBOutlet weak var appIconView: NSImageView!
    @IBOutlet weak var appNameLabel: NSTextField!
    @IBOutlet weak var behaviorSegment: NSSegmentedControl!
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var segmentedHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var spaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageConstraint: NSLayoutConstraint!
    
    internal var currentSwitchMethod = SwitchMethod.windowSwitch
    
    private var currentApp: AppData?
    
    /// Change the current running application presented by the view.
    ///
    /// - parameter app:      The running application.
    /// - parameter behavior: The behavior for the application. Either from the rules collection or infered if none.
    func setCurrent(app: NSRunningApplication, behavior: AppBehavior) {
        currentApp = AppData(from: app)
        behaviorSegment.setSelected(true, forSegment: behavior.rawValue)
        appIconView.image = app.icon
        if let name = app.localizedName {
            appNameLabel.stringValue = name
        } else {
            appNameLabel.stringValue = "An app"
        }
    }
    
    
    /// Update the current behavior for the current running application.
    ///
    /// - parameter behavior: The new beavior for the application.
    func updateBehaviorForCurrentApp(_ behavior: AppBehavior) {
        behaviorSegment.setSelected(true, forSegment: behavior.rawValue)
    }
    
    
    /// Enable or disable the entire view.
    ///
    /// - parameter flag: The enabled state of the view.
    func enabled(_ flag: Bool) {
        let controls = [appIconView, appNameLabel, behaviorSegment] as [NSControl]
        controls.forEach { $0.isEnabled = flag }
    }
    
    func shrinkView() {
        currentSwitchMethod = .fnKey
        var newFrame = self.view.frame
        newFrame.size.height = 32
        imageConstraint.constant = 24
        segmentedHeightConstraint.constant = 0
        spaceConstraint.constant = 0
        behaviorSegment.isHidden = true
        self.view.setFrameSize(newFrame.size)
    }
    
    func expandView() {
        currentSwitchMethod = .windowSwitch
        var newFrame = self.view.frame
        newFrame.size.height = 72
        imageConstraint.constant = 64
        segmentedHeightConstraint.constant = 24
        spaceConstraint.constant = 4
        behaviorSegment.isHidden = false
        self.view.setFrameSize(newFrame.size)
    }
    
    /// Change the behavior for the current running application.
    /// It makes sure the behavior manager gets notfified of this change.
    ///
    /// - parameter sender: The object that sent the action.
    @IBAction func behaviorChanged(_ sender: NSSegmentedControl) {
        guard let behavior = AppBehavior(rawValue: sender.selectedSegment),
            let id = currentApp?.bundleIdentifier,
            let url = currentApp?.bundleURL else { return }
        let userInfo = BehaviorController.behaviorDidChangeUserInfoConstructor(id: id, url: url, behavior: behavior)
        let not = Notification(name: .BehaviorDidChangeForApp, object: self, userInfo: userInfo)
        NotificationCenter.default.post(not)
    }
}
