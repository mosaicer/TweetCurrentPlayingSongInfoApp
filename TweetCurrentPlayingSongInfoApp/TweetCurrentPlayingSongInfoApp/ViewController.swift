//
//  ViewController.swift
//  TweetCurrentPlayingSongInfoApp
//
//  Created by Cyanoa on 2017/07/09.
//  Copyright © 2017年 Cyanoa. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController {

    @IBOutlet weak var tweetTextView: UITextView!
    
    let player = MPMusicPlayerController.systemMusicPlayer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // register NotificationCenter
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(type(of: self).applicationDidBecomeActive(notification:)),
                                       name: .UIApplicationDidBecomeActive,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(type(of: self).applicationWillTerminate(notification:)),
                                       name: .UIApplicationWillTerminate,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(type(of: self).musicDidChanged(notification:)),
                                       name: .MPMusicPlayerControllerNowPlayingItemDidChange,
                                       object: player)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyBorderToTextView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func applyBorderToTextView() {
        tweetTextView.layer.borderColor = UIColor.black.cgColor
        tweetTextView.layer.borderWidth = 1.0
        tweetTextView.layer.cornerRadius = 10.0
        tweetTextView.layer.masksToBounds = true
    }
    
    func applicationDidBecomeActive(notification: Notification) {
        checkMediaLibraryPermissions(MPMediaLibrary.authorizationStatus())
    }
    
    func checkMediaLibraryPermissions(_ authorizationStatus: MPMediaLibraryAuthorizationStatus) {
        switch authorizationStatus {
            // this app is launched for the first time
        case MPMediaLibraryAuthorizationStatus.notDetermined:
            MPMediaLibrary.requestAuthorization({[weak self] (authorizationStatus: MPMediaLibraryAuthorizationStatus) in
                // re-check authorization status after dismissing request dialog
                self?.checkMediaLibraryPermissions(authorizationStatus)
            })
            // this app can't permit access
        case MPMediaLibraryAuthorizationStatus.restricted:
            fallthrough
        case MPMediaLibraryAuthorizationStatus.denied:
            let alertController = UIAlertController(title: "Access to Media and Apple Music is not permitted",
                                                    message: "Do you mind moving to SettingApp?",
                                                    preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "Move", style: .default, handler: {(action: UIAlertAction!) in
                if let url = URL(string: UIApplicationOpenSettingsURLString), UIApplication.shared.canOpenURL(url) {
                    // move to SettingApp
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {[weak self] (action: UIAlertAction!) in
                // re-check authorization status after dismissing alert dialog
                self?.checkMediaLibraryPermissions(MPMediaLibrary.authorizationStatus())
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        case MPMediaLibraryAuthorizationStatus.authorized:
            player.beginGeneratingPlaybackNotifications()
        }
    }
    
    func applicationWillTerminate(notification: Notification) {
        // unregister NotificationCenter
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: .UIApplicationDidBecomeActive, object: nil)
        notificationCenter.removeObserver(self, name: .UIApplicationWillTerminate, object: nil)
        notificationCenter.removeObserver(self, name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
    }
    
    func musicDidChanged(notification: Notification) {
        let mediaItem: MPMediaItem? = player.nowPlayingItem
        if let item = mediaItem {
            // do something by using `item`
        }
    }
}

