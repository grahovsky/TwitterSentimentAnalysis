//
//  ViewController.swift
//  TwitterSentimentAnalysis
//
//  Created by Konstantin on 27/03/2019.
//  Copyright © 2019 Konstantin. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    var swifter: Swifter?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.path(forResource: "APIKey", ofType: "plist") {
            let aPIKeyDictonary = NSDictionary(contentsOfFile: path)
            
            let aPIKey = aPIKeyDictonary?.value(forKey: "API Key") as! String
            let aPISecret = aPIKeyDictonary?.value(forKey: "API Secret") as! String
            
            swifter = Swifter(consumerKey: aPIKey, consumerSecret: aPISecret)
            
        }
        
        swifter?.searchTweet(using: "@apple", lang: "en", count: 100, tweetMode: .extended, success: { (results, metadata) in
            //print(results)
            
            var tweets = [TweetSentimentClassifierInput]()
            
            for i in 0..<100 {
                if let tweet = results[i]["full_text"].string {
                    let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                    tweets.append(tweetForClassification)
                }
            }
            
            //print(tweets)
            
            do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
               
                var sentimentScore = 0
                
                for prediction in predictions {

                    let sentiment = prediction.label
                    
                    if sentiment == "Pos" {
                        sentimentScore += 1
                    } else if sentiment == "Neg" {
                        sentimentScore -= 1
                    }
                    
                }
                
                print(sentimentScore)
                
            } catch {
                print("There was an error with making a prediction, \(error.localizedDescription)")
            }
                
                
        }, failure: { (error) in
            print("There was an error with the Twitter API Request, \(error.localizedDescription)")
        })
        
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        
        
    }
    
}

