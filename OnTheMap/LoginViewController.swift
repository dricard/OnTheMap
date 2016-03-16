//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-10.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    var appDelegate: AppDelegate!

    var userLastName: String = ""
    var userFirstName: String = ""
    var userImageUrl: String = ""
    
    // MARK: OUTLETS
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    // MARK: LOADING AND SET-UP
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        userEmail.defaultTextAttributes = myTextAttributes
        userPassword.defaultTextAttributes = myTextAttributes
        userEmail.delegate = self
        userPassword.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        loginButton.enabled = true
        subscribeToKeyboardShowNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardShowNotifications()
    }
    
    
    // MARK: APPEARANCE AND ENABLING/DISABLING OF UI ELEMENTS
    
    let myTextAttributes : [ String : AnyObject ] = [
        NSForegroundColorAttributeName: UIColor.whiteColor()
    ]

    // MARK: TEXTFIELD DELEGATE
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: ACTIONS FROM THE INTERFACE
    
    @IBAction func loginPressed(sender: AnyObject) {
        resignIfFirstResponder(userEmail)
        resignIfFirstResponder(userPassword)
        
        
        // First we create a session with Udacity API to authenticate the user and get a uniqueKey
        if userEmail.text!.isEmpty || userPassword.text!.isEmpty {
            presentAlertMessage("Missing credential", message: "Please enter both an email address and a password")
        } else {
            if !isEmailValid(userEmail.text!) {
                presentAlertMessage("Invalid email address", message: "Please enter a valid email address")
            } else {

                // Step 1: set up the parameters

                let bodyObject = [
                    "udacity": [
                        "username": "\(userEmail.text!)",
                        "password": "\(userPassword.text!)"
                    ]
                ]
                
                // 2/3 Build URL and configure the request
                let url = NSURL(string: Constants.UDACITY.baseUrl)
                let request = NSMutableURLRequest(URL: url!)
                request.HTTPMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(bodyObject, options: [])

                // 4. Make the request
                let task = appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
                    
                    // MARK: Utility function
                    func sendError(error: String) {
                        print(error)
                    }
                    
                    // GUARD: was there an error?
                    guard (error == nil) else {
                        sendError("There was an error with the request to Udacity API: \(error)")
                        return
                    }
                    
                    // GUARD: did we get a successful 2XX response?
                    guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                        let theStatusCode = (response as? NSHTTPURLResponse)?.statusCode
                        sendError("Your request to Udacity returned a status code outside the 200 range: \(theStatusCode)")
                        return
                    }
                    
                    // GUARD: was there data returned?
                    guard let data = data else {
                        sendError("No data was returned by the request!")
                        return
                    }
                    
                    // Remove first character in response to get clean JSON data
                    let usefulData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                    
                    // 5 Parse the data
                    var parsedResult: AnyObject!
                    do {
                        parsedResult = try NSJSONSerialization.JSONObjectWithData(usefulData, options: .AllowFragments)
                    } catch {
                        sendError("Could not parse the data returned by Udacity create session: \(usefulData)")
                    }

                    // 6. use the data

                    // GUARD: is the user registered?
                    guard let isRegistered = parsedResult[Constants.UDACITY.account]!![Constants.UDACITY.registered] as? Bool else {
                        sendError("Account is unregistered")
                        // TODO: display alert to user
                        return
                    }
                    
                    if isRegistered {
                        if let uniqueKey = parsedResult[Constants.UDACITY.account]!![Constants.UDACITY.key] as? String {
                            self.getUserPublicData(uniqueKey)
                        } else {
                            sendError("Could not parse unique key from user data")
                        }
                    }

                }
                
                // 7. Start the request
                task.resume()
            }
        }
    }

    func getUserPublicData(uniqueKey: String) {
        
        // 1 set the parameters
        // There are none
        
        // 2/3 Build URL and configure the request
        let baseUrl = NSURL(string: Constants.UDACITY.userDataUrl)
        let url = baseUrl?.URLByAppendingPathComponent(uniqueKey)
        let request = NSURLRequest(URL: url!)

        // 4. Make the request
        let task = appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            // MARK: Utility function
            func sendError(error: String) {
                print(error)
            }
            
            // GUARD: was there an error?
            guard (error == nil) else {
                sendError("There was an error with the request to Udacity API: \(error)")
                return
            }
            
            // GUARD: did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                let theStatusCode = (response as? NSHTTPURLResponse)?.statusCode
                sendError("Your request to Udacity returned a status code outside the 200 range: \(theStatusCode)")
                return
            }
            
            // GUARD: was there data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Remove first character in response to get clean JSON data
            let usefulData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            // 5 Parse the data
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(usefulData, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data returned by Udacity getUserPublicData: \(usefulData)")
            }
            
            // 6. use the data
            
            // GUARD: get the user last name
            guard let lastName = parsedResult[Constants.UDACITY.user]!![Constants.UDACITY.lastName] as? String else {
                sendError("Could not parse user last name")
                // TODO: display alert to user
                return
            }
 
            // GUARD: get the user first name
            guard let firstName = parsedResult[Constants.UDACITY.user]!![Constants.UDACITY.firstName] as? String else {
                sendError("Could not parse user first name")
                // TODO: display alert to user
                return
            }

            // GUARD: get the user image URL
            guard let userImage = parsedResult[Constants.UDACITY.user]!![Constants.UDACITY.imageUrl] as? String else {
                sendError("Could not parse user image URL")
                // TODO: display alert to user
                return
            }

            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let stringDate: String = formatter.stringFromDate(NSDate())
            
            let userData = StudentLocation(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: "", mediaUrl: "", latitude: 0.0, longitude: 0.0, createdAt: stringDate, updatedAt: stringDate, imageUrl: userImage)
            
            self.appDelegate.userInformation = userData

            
            // TODO: here segue into tab view controller passing user data collected so far
            self.completeLogin()
            
        }
        
        // 7. Start the request
        task.resume()

    }
    
    func completeLogin() {
        performUIUpdatesOnMain {

            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        }

    }
    
    
    @IBAction func signUpPressed(sender: AnyObject) {
        
        // TODO: Load web page to signup to Udacity
        
    }
    
    // MARK: UTILITIES FUNCTIONS
    
    func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    func presentAlertMessage(title: String, message: String) {
        let controller = UIAlertController()
        controller.title = title
        controller.message = message
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in self.dismissViewControllerAnimated(true, completion: nil ) })
        controller.addAction(okAction)
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func isEmailValid(email: String) -> Bool {
        
        let filterString = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"

        let emailTest = NSPredicate(format: "SELF MATCHES %@", filterString)
        
        return emailTest.evaluateWithObject(email)
        
    }
    
    // MARK: KEYBOARD FUNCTIONS

    func keyboardWillShow(notification: NSNotification) {
        //get screen height
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenHeight = screenSize.height
        // get Keyboard height
        let keyboardHeight = getKeyboardHeight(notification)
        // check to see if bottom of password text field will be hidden by the keyboard and move view if so
        if (screenHeight-keyboardHeight) < userPassword.frame.maxY {
            view.frame.origin.y = -(userPassword.frame.maxY - (screenHeight-keyboardHeight) + 5)
        }
        subscribeToKeyboardHideNotification()
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
        unsubscribeToKeyboardHideNotification()
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    
    func subscribeToKeyboardShowNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }

    func unsubscribeToKeyboardShowNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func subscribeToKeyboardHideNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardHideNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
