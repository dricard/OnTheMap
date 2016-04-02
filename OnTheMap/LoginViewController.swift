//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-10.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

/// This is the first View that appears when the app is launched. It
/// lets the user enter his/her credentials and then attempt to 
/// authenticate with Udacity's API.
///
/// The user has the option to:
/// - login: with credentials,
/// - signup: to Udacity (this presents a web view), or
/// - login using Facebook (this presents a web view)
class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {

    /// MARK: properties
    
    var userLastName: String = ""
    var userFirstName: String = ""
    var userImageUrl: String = ""
    
    // MARK: outlets
    
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginFBButton: FBSDKLoginButton!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setting the text fields attributes
        userEmail.defaultTextAttributes = myTextAttributes
        userPassword.defaultTextAttributes = myTextAttributes
        // setting the text fields delegates
        userEmail.delegate = self
        userPassword.delegate = self
        // setting the login with Facebook button delegate
        loginFBButton.delegate = self
        // configure the activity indicator we'll use while geocoding
        configureActivityIndicatorView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardShowNotifications()
        blurView.alpha = 0
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardShowNotifications()
    }
    
    
    // MARK: user actions (and related methods)
    
    /// This is called when the user presses the *login* button. If both credentials are valid
    /// this calls the `authenticateWithUdacity` method on the *API* class which stores the result
    /// in the *Model* class. The completion handler then performs a segue to the TabBarController
    /// which displays the map with the pins if the login was successful or an error message if
    /// unsuccessful.
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
        // and we need non-optionals for the method call anyways)
        if let userEmailString = userEmail.text, userPasswordString = userPassword.text {
            // visual feedback for activity
            blurView.alpha = 0.5
            activityIndicator.startAnimating()
            // call the authenticate method
            API.sharedInstance().authenticateWithUdacity(userEmailString, userPassword: userPasswordString) { (success, error) in
                performUIUpdatesOnMain {
                    if success {
                        self.completeLogin()
                    } else {
                        // reset interface
                        self.blurView.alpha = 0
                        self.activityIndicator.stopAnimating()
                        print("Error returned by authenticateWithUdacity: \(error)")
                        if let error = error {
                            if error.code == Constants.UDACITY.networkError {
                                self.presentAlertMessage("Network error", message: "There was a problem with the network connection, please make sure that you have a connection to the internet.")
                              
                            } else {
                                self.presentAlertMessage("Authentication error", message: "Your credentials were refused, please check your email and password and try again or signup.")
                            }
                        }
                    }
                }
            }
        } else {
            // this should never happen since we checked for empty credentials but extra safety never hurts
            print("failed to unwrap optionals (userEmail or userPassword)")
            presentAlertMessage("Missing credential", message: "Please enter both an email address and a password")
        }
     }
    
    /// This completes the login process once the asynchronous authenticate methods terminates successfuly.
    /// It performs a segue to the TabBarController. Students location data was stored in the *Model* class
    /// if successful as well as an array of map annotations.
    func completeLogin() {
        // reset interface
        blurView.alpha = 0
        activityIndicator.stopAnimating()
        performUIUpdatesOnMain {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationTabBarController") as! UITabBarController
            self.presentViewController(controller, animated: true, completion: nil)
        }

    }
    
    @IBAction func signUpPressed(sender: AnyObject) {
        let signupURL = NSURL(string: "https://www.udacity.com/account/auth#!/signup")
        if let signupURL = signupURL {
            UIApplication.sharedApplication().openURL(signupURL)
        } else {
            print("unable to unwrap NSURL for Udacity signup url")
        }
        
    }
    
    
    // MARK: appearance and enabling/disabling of UI elements
    
    /// Sets the text attributes for the text fields.
    let myTextAttributes : [ String : AnyObject ] = [
        NSForegroundColorAttributeName: UIColor.whiteColor()
    ]

    /// Configures the activity indicator that is used when the geocode request is sent
    func configureActivityIndicatorView() {
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
        
        activityIndicator.hidesWhenStopped = true
        
        activityIndicator.color = UIColor.blueColor()
        
    }
    

    /// Sets a blur on/off over the View to indicate that we're geocoding the location
    func setBlur(turnBlurOn: Bool) {
        if turnBlurOn {
            // here we set the blur over the view
            UIView.animateWithDuration(0.5, animations: {
                self.blurView.alpha = 0.5
            })
        } else {
            // here we remove the blur
            UIView.animateWithDuration(0.5, animations: {
                self.blurView.alpha = 0
            })
        }
    }
    
    // MARK: textfield delegate
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Facebook delegate
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        // visual feedback for activity
        blurView.alpha = 0.5
        activityIndicator.startAnimating()
        guard error == nil else {
            print("FB returned an error: \(error.localizedDescription)")
            return
        }
        
        if let userToken = result.token {
            // Do something with the data
            Model.sharedInstance().loggedInWithFacebook = true
            API.sharedInstance().authenticateWithUdacityFB(userToken.tokenString) { (success, error) in
                    performUIUpdatesOnMain {
                        if success {
                            self.completeLogin()
                        } else {
                            // reset interface
                            self.blurView.alpha = 0
                            self.activityIndicator.stopAnimating()
                            print("Error returned by authenticateWithUdacityFB: \(error)")
                            if let error = error {
                                if error.code == Constants.UDACITY.networkError {
                                    self.presentAlertMessage("Network error", message: "There was a problem with the network connection, please make sure that you have a connection to the internet.")
                                    
                                } else {
                                    self.presentAlertMessage("Authentication error", message: "Your credentials were refused, please check your email and password and try again or signup.")
                                }
                            }
                        }
                    }
                }
        }

    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        // reset boolean
        Model.sharedInstance().loggedInWithFacebook = false
    }
    
    func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
        // visual feedback for activity
        blurView.alpha = 0.5
        activityIndicator.startAnimating()
        return true
    }
    
    
    // MARK: utilities functions
    
    /// Tests if the provided textField is the first responder and, if so,
    /// resign it as first responder. You should call this with both textFields
    /// to make sure you resigned before processing the login.
    func resignIfFirstResponder(textField: UITextField) {
        if textField.isFirstResponder() {
            textField.resignFirstResponder()
        }
    }
    
    /// Display a one button alert message to communicate errors to the user. Display a title, a messge, and
    /// an 'OK' button.
    func presentAlertMessage(title: String, message: String) {
        let controller = UIAlertController()
        controller.title = title
        controller.message = message
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in self.dismissViewControllerAnimated(true, completion: nil ) })
        controller.addAction(okAction)
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    /// Provides basic validation of email string to make sure it conforms to 
    /// _@_._ pattern. **This was adapted from something found on stack overflow**
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
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
    }

    func unsubscribeToKeyboardShowNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    }
    
    func subscribeToKeyboardHideNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardHideNotification() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }

}
