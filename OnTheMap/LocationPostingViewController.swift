//
//  LocationPostingView.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-18.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class LocationPostingViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {

    // MARK: Properties

    var callingViewControllerIsMap: Bool?
    var coordinates: CLLocationCoordinate2D?
    var mapString: String?

    let labelURL = UILabel()
    let labelPlease = UILabel()
    var wide = false
    let topLabelWidth = CGFloat(125.0)
    let labelURLWidth = CGFloat(43.0)
    
    // MARK: Outlets
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        // add the text labels
        labelPlease.font = UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        labelPlease.text = "Please enter an"
        self.view.addSubview(labelPlease)
        labelURL.textAlignment = .Center
        labelURL.font = UIFont.boldSystemFontOfSize(18)
        labelURL.text = "URL"
        self.view.addSubview(labelURL)

        configureActivityIndicatorView()

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // we don't evaluate screenSize in the evaluateIfWide method because
        // it may be called by willTransitionToSize which will pass it
        // the size that *will* be active after the transition.
        let screenSize: CGSize = view.frame.size
        let wide = evaluateIfWide(screenSize)
        setTextLabelsForUI(screenSize, wide: wide)
        let latitudeDelta = CLLocationDegrees(1.0)
        let longitudeDelta = CLLocationDegrees(1.0)
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let region = MKCoordinateRegionMake(coordinates!, span)
        mapView.setRegion(region, animated: true)
    }

    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        let wide = evaluateIfWide(size)
        setTextLabelsForUI(size, wide: wide)
    }
    
    // MARK: Actions from user
    
    @IBAction func userPressedSubmit(sender: AnyObject) {
        
        // GUARD: check to see if the textField is empty
        guard let mediaUrl = urlTextField.text where !mediaUrl.isEmpty else {
            presentAlertMessage("Empty URL", message: "Please enter an URL to share")
            return
        }
        
        guard let mapString = mapString else {
            print("Empty mapString in LocationPostingViewController")
            return
        }
        
        guard let latitude = coordinates?.latitude, longitude = coordinates?.longitude  else {
            print("Cannot unwrap coordinates options in LocationPostingViewController")
            return
        }
        
        // update user information with new data from user
        Model.sharedInstance().userInformation?.mapString = mapString
        Model.sharedInstance().userInformation?.mediaUrl = mediaUrl
        Model.sharedInstance().userInformation?.latitude = latitude
        Model.sharedInstance().userInformation?.longitude = longitude
        
        // unwrap userInformation before passing it to postStudentLocation
        guard let studentLocation = Model.sharedInstance().userInformation else {
            print("Could not unwrap Model.sharedInstance().userInformation in LocationPostingViewController")
            return
        }
        
        // Starts an activity indicator while we send the geocode request
        activityIndicator.startAnimating()

        // check to see if there is an objectId, which means this will be an update and not
        // a new posting. So newPosting is true if the objectId is empty.
        let newPosting = Model.sharedInstance().userInformation?.objectId == ""
        API.sharedInstance().postStudentLocation(newPosting, studentLocation: studentLocation) { (objectId, createdAt, error) -> Void in
            performUIUpdatesOnMain {
                if error == nil {
                    self.completePosting(newPosting, objectId: objectId, createdAt: createdAt)
                } else {
                    print("Error returned by postStudentLocation: \(error)")
                    self.presentAlertMessage("Error", message: "There was an error sending your information, please try again.")
                }
            }

        }
        
        
    }
    
    func completePosting(isNewPosting: Bool, objectId: String?, createdAt: String?) {

        // Here the parameter 'createdAt' contains either the createdAt date if
        // isNewPosting is true, or updatedAt date if isNewPosting is false.
        
        guard let createdAt = createdAt else {
            print("Could not unwrap createdAt in LocationPostingViewController")
            return
        }
        if isNewPosting {
            if let objectId = objectId {
                Model.sharedInstance().userInformation?.objectId = objectId
            }
            Model.sharedInstance().userInformation?.createdAt = createdAt
        } else {
            Model.sharedInstance().userInformation?.updatedAt = createdAt
        }
        // Stop the activity indicator
        activityIndicator.stopAnimating()

        // Now that we're done, segue back to the calling ViewController
        if callingViewControllerIsMap! {
            performSegueWithIdentifier("unwindBackToMapVC", sender: "locationPostingVC")
        } else {
            performSegueWithIdentifier("unwindBackToTableVC", sender: "locationPostingVC")
        }
        
    }
    
    @IBAction func userPressedCancel(sender: AnyObject) {
   
//        activityIndicator.stopAnimating()
        
        self.dismissViewControllerAnimated(true, completion: nil )

    }
    
    
    // MARK: MapView Delegates
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.blueColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }

    // MARK: Utilities functions
    
    func evaluateIfWide(size: CGSize) -> Bool {
        return size.width > topLabelWidth + labelURLWidth
    }
    
    func setTextLabelsForUI(size: CGSize, wide: Bool) {
        
        // Setting the labels positions depending on screen width
        
        let screenHalfWidth = size.width / 2

        labelPlease.textAlignment = wide ? .Right : .Center

        if wide {
            // Landscape mode
            let totalWidth = topLabelWidth + labelURLWidth
            let topOrigin = screenHalfWidth - totalWidth / 2.0
            labelURL.frame = CGRectMake(topOrigin + topLabelWidth, 65, labelURLWidth, 25)
            labelPlease.frame = CGRectMake(topOrigin, 65, topLabelWidth, 25)
            
        } else {
            // portrait mode (on smaller phones)
            labelPlease.frame = CGRectMake(screenHalfWidth - topLabelWidth / 2.0, 43, topLabelWidth, 25)
            labelURL.frame = CGRectMake(screenHalfWidth - labelURLWidth / 2.0, 65, labelURLWidth, 25)
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

}
