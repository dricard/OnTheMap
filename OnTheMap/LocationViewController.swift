//
//  LocationViewController.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-16.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit
import CoreLocation


/// This presents the user with a textField where s/he should enter a
/// location string for the forward geocode. No check is made on the string
/// itself except to check if it's empty.
///
/// On a successful geocode the user is presented with the `LocationPosting` View.
class LocationViewController: UIViewController, UITextFieldDelegate {


    // MARK: Properties
    
    var callingViewControllerIsMap: Bool?
    let labelInformation = UILabel()
    let labelLocation = UILabel()
    let labelPlease = UILabel()
    let labelPleaseWidth = CGFloat(150.0)
    let labelLocationWidth = CGFloat(75.0)
    let labelInformationWidth = CGFloat(100.0)

    
    // MARK: Outlets
    
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var findLocationButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add the text labels and set properties that will not change depending
        // on screen width (orientation). Other properties are set in
        // setTextLabelsForUI.
        labelPlease.font = UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        labelPlease.text = "Please enter your"
        self.view.addSubview(labelPlease)
        // the middle label is always centered so we set that here
        labelLocation.textAlignment = .Center
        labelLocation.font = UIFont.boldSystemFontOfSize(18)
        labelLocation.text = "location"
        self.view.addSubview(labelLocation)
        labelInformation.font =  UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        labelInformation.text = "information"
        self.view.addSubview(labelInformation)

        // configure the activity indicator we'll use while geocoding
        configureActivityIndicatorView()
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // we don't put screenSize in the evaluateIfWide method because
        // it may be called by willTransitionToSize which will pass it
        // the size that will be active after the transition.
        let screenSize: CGSize = view.frame.size
        let wide = evaluateIfWide(screenSize)
        setTextLabelsForUI(screenSize, wide: wide)
        
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        let wide = evaluateIfWide(size)
        setTextLabelsForUI(size, wide: wide)
    }
    
    
    // MARK: User Actions
    
    /// Tries to forward geocode a location from a user supplied string. If successful, the
    /// completion handler calls `didReceiveGeocodeAddress` with the coordinates found.
    @IBAction func userPressedFindLocation(sender: AnyObject) {
        
        // GUARD: check for an empty location string
        guard let locationString = locationTextField.text else {
            presentAlertMessage("No location information", message: "Please enter a location")
            return
        }
        
        let geocoder = CLGeocoder()
        
        // Starts an activity indicator while we send the geocode request
        activityIndicator.startAnimating()

        geocoder.geocodeAddressString(locationString) { (data, error) -> Void in
            
            // GUARD: checks to see if there is an error
            guard error == nil else {
                self.presentAlertMessage("Cannot find location", message: "Could not identify location, please try to add more information and be sure to include at least a city name and a state or country.")
                print("Geocoder returned an error: \(error)")
                return
            }

            // GUARD: checks to see if there is data returned
            guard let data = data else {
                self.presentAlertMessage("Cannot find location", message: "Could not identify location, please try to add more information and be sure to include at least a city name and a state or country.")
                print("Data returned from Geocoder is nil")
                return
            }
            
            // GUARD: unwraps first location returned
            guard let location = data[0].location else {
                self.presentAlertMessage("Cannot find location", message: "Could not identify location, please try to add more information and be sure to include at least a city name and a state or country.")
               print("Invalid or null location data in returned placemark")
               return
            }
            
            // Create coordinates from lat/long returned
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            
            // send coordinates to didReceiveGeocodeAddress to segue to URL input
            self.didReceiveGeocodeAddress(coordinates)
        }
    }
    
    /// User cancelled the attempt to geocode the string.
    @IBAction func userPressedCancel(sender: AnyObject) {

        // TODO: need to use cancelGeocode?

        activityIndicator.stopAnimating()

        self.dismissViewControllerAnimated(true, completion: nil )
    }

    // MARK: GOECODE Utilities

    /// This is called once a successful forward geocode on the supplied string is
    /// returned. This segue to the `LocationPostingViewController` to ask for an
    /// URL while passing the coordinates to be displayed.
    func didReceiveGeocodeAddress(coordinates: CLLocationCoordinate2D) {
        // stop the activity indicator
        activityIndicator.stopAnimating()
        performUIUpdatesOnMain {
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationPostingView") as! LocationPostingViewController
            controller.coordinates = coordinates
            controller.mapString = self.locationTextField.text!
            controller.callingViewControllerIsMap = self.callingViewControllerIsMap!
            self.presentViewController(controller, animated: true, completion: nil)
        }
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
    
    /// This checks if the labels prompting the user can be displayed on a single line
    /// or not.
    /// - returns:
    ///   - true: if all the text labels can fit on a single line
    ///   - false: if we should instead put them on above the other (on smaller screen sizes).
    func evaluateIfWide(size: CGSize) -> Bool {
        return size.width > labelPleaseWidth + labelLocationWidth + labelInformationWidth
    }
    
    /// This displays text labels to prompt the user to enter a location. We separate the 
    /// prompt into three parts to be able to set the middle one to bold and also so we can
    /// arrange the labels vertically for smaller screen sizes.
    func setTextLabelsForUI(size: CGSize, wide: Bool) {
 
        // Setting the labels positions depending on screen width
        // get the middle of the screen
        let screenHalfWidth = size.width / 2
 
        // if wide then center label is centered and those on each side are
        // right (for the leading) and left (for the following) aligned
        // otherwise they are one above the other and so are all centered
        labelPlease.textAlignment = wide ? .Right : .Center
        labelInformation.textAlignment = wide ? .Left : .Center

        if wide {
            // Landscape mode
            // get the total width of all labels side by side
            let totalWidth = labelPleaseWidth + labelLocationWidth + labelInformationWidth
            // topOrigin if the origin of the first label (top when portrait mode)
            let topOrigin = screenHalfWidth - totalWidth / 2.0
            labelLocation.frame = CGRectMake(topOrigin + labelPleaseWidth, 65, labelLocationWidth, 25)
            labelPlease.frame = CGRectMake(topOrigin, 65, labelPleaseWidth, 25)
            labelInformation.frame = CGRectMake(topOrigin + labelPleaseWidth + labelLocationWidth, 65, labelInformationWidth, 25)
           
        } else {
            // portrait mode (on smaller phones)
            labelPlease.frame = CGRectMake(screenHalfWidth - labelPleaseWidth / 2.0, 43, labelPleaseWidth, 25)
            labelLocation.frame = CGRectMake(screenHalfWidth - labelLocationWidth / 2.0, 65, labelLocationWidth, 25)
            labelInformation.frame = CGRectMake(screenHalfWidth - labelInformationWidth / 2.0, 87, labelInformationWidth, 25)
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

    /// Configures the activity indicator that is used when the geocode request is sent
    func configureActivityIndicatorView() {
        activityIndicator.activityIndicatorViewStyle = .WhiteLarge
 
        activityIndicator.hidesWhenStopped = true

        activityIndicator.color = UIColor.blueColor()
        
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
