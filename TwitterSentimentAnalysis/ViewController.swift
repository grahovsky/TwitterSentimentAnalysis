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

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    var swifter: Swifter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.delegate = self
        
        hideKeyboardWhenTappedAround()
        
        if let path = Bundle.main.path(forResource: "APIKey", ofType: "plist") {
            let aPIKeyDictonary = NSDictionary(contentsOfFile: path)
            
            let aPIKey = aPIKeyDictonary?.value(forKey: "API Key") as! String
            let aPISecret = aPIKeyDictonary?.value(forKey: "API Secret") as! String
            
            swifter = Swifter(consumerKey: aPIKey, consumerSecret: aPISecret)
            
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        fetchTweets()
        return false
    }
    
    @IBAction func predictPressed(_ sender: Any) {
        
        fetchTweets()
        
    }
    
    func fetchTweets() {
       
        if let searchText = textField.text {
            
            swifter?.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                //print(results)
                
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                self.makePrediction(with: tweets)
                
        
            }, failure: { (error) in
                print("There was an error with the Twitter API Request, \(error.localizedDescription)")
            })
            
        }
        
    }
    
    func makePrediction(with tweets: [TweetSentimentClassifierInput]) {
    
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
            
            updateUI(with: sentimentScore)
            
        } catch {
            print("There was an error with making a prediction, \(error.localizedDescription)")
        }
        
    }
    
    func updateUI(with sentimentScore: Int) {
    
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😍"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "😄"
        } else if sentimentScore > 0 {
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore == 0 {
            self.sentimentLabel.text = "😐"
        } else if sentimentScore > -10 {
            self.sentimentLabel.text = "😕"
        } else if sentimentScore > -20 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤮"
        }
        
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
}

