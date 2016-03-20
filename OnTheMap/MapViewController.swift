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

    var studentLocations = [StudentLocation]()
    var annotations = [MKPointAnnotation]()
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "On the map"

     }
    
    override func viewWillAppear(animated: Bool) {
        
        refreshData()
        
    }

    // MARK: Data functions
    
    func refreshData() {
 
        API.sharedInstance().getLocationsData { (studentLocations, annotations, error) -> Void in
            
            guard (error == nil) else {
                print("Error returned by getLocationData in MapViewController: \(error)")
                // TODO: alert user
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
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func userTappedLogout(sender: AnyObject) {
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
    
}
