//
//  ViewController.swift
//  TweetCurrentPlayingSongInfoApp
//
//  Created by Cyanoa on 2017/07/09.
//  Copyright © 2017年 Cyanoa. All rights reserved.
//

import UIKit
import MediaPlayer
import UserNotifications
import Social

class ViewController: UIViewController {

    private let NOTIFICATION_MUSIC_CHANGE_REQUEST_IDENTIFIER = "music_did_changed"
    private let NOTIFICATION_ATTACHMENT_IDENTIFIER = "artwork_image_attachment"
    
    @IBOutlet weak var tweetTextView: UITextView!
    
    let player = MPMusicPlayerController.systemMusicPlayer()
    
    var mediaItem: MPMediaItem?
    
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
        
        notificationCenter.addObserver(self,
                                       selector: #selector(type(of: self).tweetActionSelected(notification:)),
                                       name: .tweetActionSelected,
                                       object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(type(of: self).closeActionSelected(notification:)),
                                       name: .closeActionSelected,
                                       object: nil)
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
        notificationCenter.removeObserver(self, name: .tweetActionSelected, object: nil)
        notificationCenter.removeObserver(self, name: .closeActionSelected, object: nil)
    }
    
    func musicDidChanged(notification: Notification) {
        if let item = player.nowPlayingItem {
            mediaItem = item
            notifyMusicChanged()
        }
    }

    func notifyMusicChanged() {
        guard let item = mediaItem else { return }
        
        let content = UNMutableNotificationContent()
        content.title = item.title ?? ""
        content.subtitle = item.artist ?? ""
        content.body = item.albumTitle ?? ""
        
        if let artwork = item.artwork,
            let url = saveArtworkImageTemporary(artwork: artwork),
            let attachment = try? UNNotificationAttachment(identifier: NOTIFICATION_ATTACHMENT_IDENTIFIER, url: url, options: nil) {
            
            content.attachments.append(attachment)
        }

        content.categoryIdentifier = Const.NOTIFICATION_CATEGORY_TWEET

        // fire after 1 second
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: NOTIFICATION_MUSIC_CHANGE_REQUEST_IDENTIFIER, content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: {(error) in
            if let e = error {
                print(e)
            }
        })
    }
    
    func saveArtworkImageTemporary(artwork: MPMediaItemArtwork) -> URL? {
        if let image = artwork.image(at: artwork.bounds.size),
            let pngImageData = UIImagePNGRepresentation(image),
            let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("artwork_temp.png") {
            
            do {
                try pngImageData.write(to: url)
                return url
            } catch {
                print(error)
            }
        }
        
        return nil
    }
    
    func tweetActionSelected(notification: Notification) {
        guard SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) else {
            promptSetTwitterAccount()
            return
        }
        
        guard let composeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter) else {
            return
        }
        
        composeViewController.setInitialText(createTweetText())

        if needToUploadArtwork() {
            if let item = mediaItem, let artwork = item.artwork, let image = artwork.image(at: artwork.bounds.size) {
                composeViewController.add(image)
            }
        }
        
        // if you handle the result
//        composeViewController.completionHandler = {(result: SLComposeViewControllerResult) in
//            switch result {
//            case .done:
//                print("done")
//            case .cancelled:
//                print("canceled")
//            }
//        }
        
        present(composeViewController, animated: true, completion: nil)
    }
    
    func promptSetTwitterAccount() {
        let alert = UIAlertController(title: "Twitter service is not available",
                                      message: "To tweet song information, please set your twitter account.",
                                      preferredStyle: .alert)
        
        let settingAction = UIAlertAction(title: "Setting", style: .default, handler: {(action: UIAlertAction!) in
            // open twitter setting screen
            if let url = URL(string:"App-Prefs:root=TWITTER") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(settingAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func createTweetText() -> String {
        guard let item = mediaItem else { return "" }

        // TODO: retrieve texts from app setting.
        var tweetText = ""
        
        return tweetText
    }
    
    func needToUploadArtwork() -> Bool {
        // TODO: check if uploading artwork is necessary, by retrieve the flag from app setting.
        return true
    }
    
    func closeActionSelected(notification: Notification) {
        // do nothing
    }
}
