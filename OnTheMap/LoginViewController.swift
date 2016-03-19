//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-10.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    /// MARK: properties
    
    var userLastName: String = ""
    var userFirstName: String = ""
    var userImageUrl: String = ""
    
    // MARK: outlets
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setting the text fields attributes
        userEmail.defaultTextAttributes = myTextAttributes
        userPassword.defaultTextAttributes = myTextAttributes
        // setting the text fields delegates
        userEmail.delegate = self
        userPassword.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loginButton.enabled = true
        subscribeToKeyboardShowNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardShowNotifications()
    }
    
    
    // MARK: user actions (and related methods)
    
    @IBAction func loginPressed(sender: AnyObject) {
        // first resign first responder if a text field was active
        resignIfFirstResponder(userEmail)
        resignIfFirstResponder(userPassword)
        
        // GUARD: first check if the user entered an email and a password
        guard !userEmail.text!.isEmpty && !userPassword.text!.isEmpty else {
            presentAlertMessage("Missing credential", message: "Please enter both an email address and a password")
            return
        }
        // GUARD: check if the user entered a valid email address
        guard isEmailValid(userEmail.text!) else {
            presentAlertMessage("Invalid email address", message: "Please enter a valid email address")
            return
        }
        // unwrap the parameters (even if they should not be nil at this point, but to be extra sure
        // and we need non-optionals for the method call)
        if let userEmailString = userEmail.text, userPasswordString = userPassword.text {
        // call the authenticate method
            API.sharedInstance().authenticateWithUdacity(userEmailString, userPassword: userPasswordString) { (success, error) in
                performUIUpdatesOnMain {
                    if success {
                        self.completeLogin()
                    } else {
                        print("Error returned by authenticateWithUdacity: \(error)")
                        // TODO: display error to user
                    }
                }
            }
        } else {
            print("failed to unwrap optionals (userEmail or userPassword)")
            // TODO: display error to user
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
    
    // MARK: appearance and enabling/disabling of UI elements
    
    let myTextAttributes : [ String : AnyObject ] = [
        NSForegroundColorAttributeName: UIColor.whiteColor()
    ]
    
    // MARK: textfield delegate
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: utilities functions
    
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
    
    // MARK: keyboard functions

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
