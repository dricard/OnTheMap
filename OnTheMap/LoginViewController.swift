//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-10.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

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
        
        // authenticate with Udacity API but first check if there is a valid email and a password
        if userEmail.text!.isEmpty || userPassword.text!.isEmpty {
            presentAlertMessage("Missing credential", message: "Please enter both an email address and a password")
        } else {
            if !isEmailValid(userEmail.text!) {
                presentAlertMessage("Invalid email address", message: "Please enter a valid email address")
            } else {
                let userEmailString = userEmail.text!
                let userPasswordString = userPassword.text!
                // call the authenticate method
                API.sharedInstance().authenticateWithUdacity(userEmailString, userPassword: userPasswordString) { (success, error) in
                    performUIUpdatesOnMain {
                        if success {
                            self.completeLogin()
                        } else {
                            print("Error returned by authenticateWithUdacity: \(error)")
                            // TODO display error to user
                        }
                    }
                }
            }
        }
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

}
