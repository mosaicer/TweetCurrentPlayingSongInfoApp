//
//  AppDelegate.swift
//  TweetCurrentPlayingSongInfoApp
//
//  Created by Cyanoa on 2017/07/09.
//  Copyright © 2017年 Cyanoa. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    private let ACTION_TWEET = "action_tweet"
    private let ACTION_CLOSE = "action_close"
    
    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let category = UNNotificationCategory(identifier: Const.NOTIFICATION_CATEGORY_TWEET,
                                              actions: createActions(),
                                              intentIdentifiers: [],
                                              options: [])
        
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([category])
        center.delegate = self
        center.requestAuthorization(options: [.alert], completionHandler: {(granted, error) in
            if granted {
                print("Allowed")
            } else {
                print("Didn't allowed")
            }
        })
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        var bgTaskId: UIBackgroundTaskIdentifier = 0
        bgTaskId = UIApplication.shared.beginBackgroundTask(expirationHandler: {() in
            UIApplication.shared.endBackgroundTask(bgTaskId)
        })
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case ACTION_TWEET:
            let center = NotificationCenter.default
            center.post(name: .tweetActionSelected, object: nil)
        case ACTION_CLOSE:
            let center = NotificationCenter.default
            center.post(name: .closeActionSelected, object: nil)
        // do nothing when notification dialog itself is clicked
        default:
            break
        }
        
        completionHandler()
    }
    
    func createActions() -> [UNNotificationAction] {
        // add option ".foreground", if you want to open this app by tapping tweetAction button when the device is locked.
        let tweetAction = UNNotificationAction(identifier: ACTION_TWEET,
                                               title: "Tweet",
                                               options: [.destructive])
        
        let closeAction = UNNotificationAction(identifier: ACTION_CLOSE,
                                               title: "Close",
                                               options: [])
        
        return [tweetAction, closeAction]
    }
}

