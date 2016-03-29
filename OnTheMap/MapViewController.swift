//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-14.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit
import MapKit

/// This displays a map with pins corresponding to student locations
/// as returned by a Parse API.
class MapViewController: UIViewController, MKMapViewDelegate {

    // MARK: Properties
    
    var studentLocations = [StudentLocation]()
    var annotations = [MKPointAnnotation]()
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        // setting the Navigation bar
        // setting the title
        title = "On the map"
     }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()
    }

    // MARK: Data functions
    
    func refreshData() {
 
        API.sharedInstance().getLocationsData { (studentLocations, annotations, error) -> Void in
            
            guard (error == nil) else {
                print("Error returned by getLocationData in MapViewController: \(error)")
                self.presentAlertMessage("Communication error", message: "Unable to connect to server, please check your internet connection")
                return
            }
            
            if let studentLocations = studentLocations, annotations = annotations {
                self.studentLocations = studentLocations
                self.annotations = annotations
                performUIUpdatesOnMain {
                    self.completeGetLocationData(annotations)
                }
            } else {
                print("studentLocations or annotation is nil, error was \(error)")
            }
            
        }
        
    }
 
    func completeGetLocationData(annotations: [MKPointAnnotation]) {
        
        self.mapView.addAnnotations(annotations)
        
    }

    
    // MARK: user actions
    
    @IBAction func userTappedRefresh(sender: AnyObject) {
        
        refreshData()
        
    }
    
    @IBAction func userTappedAddLocation(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationView") as! LocationViewController
        controller.callingViewControllerIsMap = true
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func userTappedLogout(sender: AnyObject) {

        API.sharedInstance().logoutFromUdacity { (success, error) in
            
            guard (error == nil) else {
                print("There was an error with loging out of Udacity: \(error)")
                self.presentAlertMessage("Credentials", message: "Username or password invalid. Use the 'sign up' button below to register")
                return
            }
            
            if success {

                performUIUpdatesOnMain({
                    if let tabBarController = self.tabBarController {
                        tabBarController.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func unwindToMap(unwindSegue: UIStoryboardSegue) {
        if let postingViewController = unwindSegue.sourceViewController as? LocationPostingViewController {

            if Model.sharedInstance().userInformation?.objectId != "" {

                // first, fetch new data from Parse API
                refreshData()
                // then change the span to center on the newly posted area
                let latitudeDelta = CLLocationDegrees(1.0)
                let longitudeDelta = CLLocationDegrees(1.0)
                let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
                let coordinate = CLLocationCoordinate2D(latitude: (Model.sharedInstance().userInformation?.latitude)!, longitude: (Model.sharedInstance().userInformation?.longitude)!)
                let region = MKCoordinateRegionMake(coordinate, span)
                mapView.setRegion(region, animated: true)
               
            }
            
        }
        else if let locationViewController = unwindSegue.sourceViewController as? LocationViewController {
            print("Coming from location")
        }
    }

    // MARK: MapView Delegates
    
    //Opens the mediaURL in Safari when the annotation info box is tapped.
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        
        UIApplication.sharedApplication().openURL(NSURL(string: view.annotation!.subtitle!!)!)
    }

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
    
    // MARK: utilities
    
    func enterLocation() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationView") as! LocationViewController
        self.presentViewController(controller, animated: true, completion: nil)
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
    

}
