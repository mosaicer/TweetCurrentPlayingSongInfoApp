//
//  ViewController.swift
//  TweetCurrentPlayingSongInfoApp
//
//  Created by Cyanoa on 2017/07/09.
//  Copyright © 2017年 Cyanoa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tweetTextView: UITextView!
    
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
}

