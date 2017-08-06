//
//  Const.swift
//  TweetCurrentPlayingSongInfoApp
//
//  Created by Cyanoa on 2017/07/23.
//  Copyright © 2017年 Cyanoa. All rights reserved.
//

import UserNotifications

struct Const {
    static let NOTIFICATION_CATEGORY_TWEET = "category_tweet"    
}

extension Notification.Name {
    static let tweetActionSelected = Notification.Name("TweetActionSelected")
    static let closeActionSelected = Notification.Name("CloseActionSelected")
}
