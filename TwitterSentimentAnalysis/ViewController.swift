//
//  ViewController.swift
//  TwitterSentimentAnalysis
//
//  Created by Konstantin on 27/03/2019.
//  Copyright © 2019 Konstantin. All rights reserved.
//

import UIKit
import SwifteriOS

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    var swifter: Swifter?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "APIKey", ofType: "plist") {
            let aPIKeyDictonary = NSDictionary(contentsOfFile: path)
            
            let aPIKey = aPIKeyDictonary?.value(forKey: "API Key") as! String
            let aPISecret = aPIKeyDictonary?.value(forKey: "API Secret") as! String
            
            swifter = Swifter(consumerKey: aPIKey, consumerSecret: aPISecret)
            
        }
        
        swifter?.searchTweet(using: "@Apple", lang: "en", count: 100, tweetMode: .extended, success: { (results, metadata) in
            print(results)
        }, failure: { (error) in
            print("There was an error with the Twitter API Request, \(error.localizedDescription)")
        })
        
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        
        
    }
    
}

