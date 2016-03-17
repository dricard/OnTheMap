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

    // MARK: VARIABLES
    
    let labelInformation = UILabel()
    let labelLocation = UILabel()
    let labelPlease = UILabel()
    var wide = false
    let topLabelWidth = CGFloat(150.0)
    let middleLabelWidth = CGFloat(75.0)
    let bottomLabelWidth = CGFloat(100.0)

    
    // MARK: Outlets
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    
    // MARK: Text Properties
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
 
        // add the text labels
        labelPlease.textAlignment = .Right
        labelPlease.font = UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        labelPlease.text = "Please enter your"
        self.view.addSubview(labelPlease)
        labelLocation.textAlignment = .Center
        labelLocation.font = UIFont.boldSystemFontOfSize(18)
        labelLocation.text = "location"
        self.view.addSubview(labelLocation)
        labelInformation.textAlignment = .Left
        labelInformation.font =  UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        labelInformation.text = "information"
        self.view.addSubview(labelInformation)

    }
    
    override func viewWillAppear(animated: Bool) {
        let screenSize: CGSize = view.frame.size
        evaluateIfWide(screenSize)
        setTextLabelsForUI(screenSize)
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {

        evaluateIfWide(size)
        setTextLabelsForUI(size)
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
    
    // MARK: Utilities functions
    
    func evaluateIfWide(size: CGSize) {
        wide = size.width > topLabelWidth + middleLabelWidth + bottomLabelWidth
    }
    
    func setTextLabelsForUI(size: CGSize) {
 

        // Setting the labels positions depending on screen width
        
        let screenHalfWidth = size.width / 2
        
        if wide {
            // Landscape mode
            let totalWidth = topLabelWidth + middleLabelWidth + bottomLabelWidth
            let topOrigin = screenHalfWidth - totalWidth / 2.0
            labelLocation.frame = CGRectMake(topOrigin + topLabelWidth, 65, middleLabelWidth, 25)
            labelPlease.frame = CGRectMake(topOrigin, 65, topLabelWidth, 25)
            labelInformation.frame = CGRectMake(topOrigin + topLabelWidth + middleLabelWidth, 65, bottomLabelWidth, 25)
           
        } else {
            // portrait mode (on smaller phones)
            labelPlease.frame = CGRectMake(screenHalfWidth - topLabelWidth / 2.0, 43, topLabelWidth, 25)
            labelLocation.frame = CGRectMake(screenHalfWidth - middleLabelWidth / 2.0, 65, middleLabelWidth, 25)
            labelInformation.frame = CGRectMake(screenHalfWidth - bottomLabelWidth / 2.0, 87, bottomLabelWidth, 25)
        }
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
