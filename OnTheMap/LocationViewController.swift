//
//  LocationViewController.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-16.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit

class LocationViewController: UIViewController, UITextFieldDelegate {

    var appDelegate: AppDelegate!

    // MARK: Outlets
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    
    // MARK: Text Properties
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Label
        let labelPlease = UILabel()
        labelPlease.frame = CGRectMake(120, 40, 150, 25)
        labelPlease.font = UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        labelPlease.text = "Please enter your"
        
        self.view.addSubview(labelPlease)
 
        // Label
        let labelLocation = UILabel()
        labelLocation.frame = CGRectMake(155, 62, 150, 25)
        labelLocation.font = UIFont.boldSystemFontOfSize(18)
        labelLocation.text = "location"
        
        self.view.addSubview(labelLocation)

        // Label
        let labelInformation = UILabel()
        labelInformation.frame = CGRectMake(145, 84, 150, 25)
        labelInformation.font =  UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        labelInformation.text = "information"
        
        self.view.addSubview(labelInformation)

    }
    
    // MARK: User Actions
    
    
    @IBAction func userPressedFindLocation(sender: AnyObject) {
    }
    
    
    @IBAction func userPressedCancel(sender: AnyObject) {
    }
    
    // MARK: Textfield Delegates
    
    func textFieldDidBeginEditing(textField: UITextField) {
        print("did begin editing with UITextField: \(textField)")
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: KEYBOARD FUNCTIONS
    
    func keyboardWillShow(notification: NSNotification) {
        //get screen height
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenHeight = screenSize.height
        // get Keyboard height
        let keyboardHeight = getKeyboardHeight(notification)
        // check to see if bottom of password text field will be hidden by the keyboard and move view if so
        if (screenHeight-keyboardHeight) < locationTextField.frame.maxY {
            view.frame.origin.y = -(locationTextField.frame.maxY - (screenHeight-keyboardHeight) + 5)
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
