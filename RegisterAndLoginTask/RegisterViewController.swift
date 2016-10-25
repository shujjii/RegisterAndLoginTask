//
//  RegisterViewController.swift
//  RegisterAndLoginTask
//
//  Created by Shuja Hasan on 25/10/2016.
//  Copyright © 2016 Shuja Hasan. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        postSampleDataToBackendServer()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func postSampleDataToBackendServer() {
        
        let email:NSString = "me@me.com"
        let password:NSString = "me"
        let prefs:UserDefaults = UserDefaults.standard
        
        if ( email.isEqual(to: "") || password.isEqual(to: "") ) {
            
            let alertView:UIAlertView = UIAlertView()
            alertView.title = "Register Failed!"
            alertView.message = "Please enter Email and Password"
            alertView.delegate = self
            alertView.addButton(withTitle: "OK")
            alertView.show()
        }
        else {
            
            let post:NSString = "email=\(email)&password=\(password)" as NSString
            let url:URL = URL(string: "https://aqueous-river-46656.herokuapp.com/api/v1/register")!
            let postData:Data = post.data(using: String.Encoding.ascii.rawValue)!
            let postLength:NSString = String( postData.count ) as NSString
            let request:NSMutableURLRequest = NSMutableURLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = postData
            request.setValue(postLength as String, forHTTPHeaderField: "Content-Length")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            var reponseError: NSError?
            var response: URLResponse?
            
            var urlData: Data?
            do {
                urlData = try NSURLConnection.sendSynchronousRequest(request as URLRequest, returning:&response)
            } catch let error as NSError {
                reponseError = error
                urlData = nil
            }
            
            if ( urlData != nil ) {
                let res = response as! HTTPURLResponse!;
                
                if ((res?.statusCode)! >= 200 && (res?.statusCode)! < 300)
                {
                    let responseData:NSString  = NSString(data:urlData!, encoding:String.Encoding.utf8.rawValue)!
                    
                    NSLog("Response ==> %@", responseData);
                    
                    let jsonData:NSDictionary = (try! JSONSerialization.jsonObject(with: urlData!, options:JSONSerialization.ReadingOptions.mutableContainers )) as! NSDictionary
                    let accessToken:NSString = jsonData.value(forKey: "accessToken") as! NSString
                    
                    if(accessToken.length > 0)
                    {
                        prefs.set(accessToken, forKey: "accessToken")
                        self.moveToWelcomeScreenOnSuccessfullRegistration()
                    }
                    else {
                        
                        let alertView:UIAlertView = UIAlertView()
                        alertView.title = "Registeration Failed!"
                        alertView.message = ""
                        alertView.delegate = self
                        alertView.addButton(withTitle: "OK")
                        alertView.show()
                    }
                } else {
                    let alertView:UIAlertView = UIAlertView()
                    alertView.title = "Registeration Failed!"
                    alertView.message = "Connection Failed"
                    alertView.delegate = self
                    alertView.addButton(withTitle: "OK")
                    alertView.show()
                }
            }  else {
                let alertView:UIAlertView = UIAlertView()
                alertView.title = "Registeration Failed!"
                alertView.message = "Connection Failure"
                if let error = reponseError {
                    alertView.message = (error.localizedDescription)
                }
                alertView.delegate = self
                alertView.addButton(withTitle: "OK")
                alertView.show()
            }
        }
    }
    
    func moveToWelcomeScreenOnSuccessfullRegistration() {
        self.performSegue(withIdentifier: "moveToWelcomeScreen", sender: self)
    }
}
