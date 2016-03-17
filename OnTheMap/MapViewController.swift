//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-14.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    var appDelegate: AppDelegate!
    var studentLocations = [StudentLocation]()
    var annotations = [MKPointAnnotation]()
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: VIEW CONTROLLER
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "On the map"

        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // MARK: Get the student location informations from Parse API
        
        // 1 set the parameters
        // There are none
        
        // 2/3 Build URL and configure the request
        let url = NSURL(string: Constants.PARSE.baseUrl)
        
        let request = NSMutableURLRequest(URL: url!)
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        
        // 4. Make the request
        let task = appDelegate.sharedSession.dataTaskWithRequest(request) { (data, response, error) in
            
            // MARK: Utility function
            func sendError(error: String) {
                print(error)
            }
            
            // GUARD: was there an error?
            guard (error == nil) else {
                sendError("There was an error with the request to Parse API: \(error)")
                return
            }
            
            // GUARD: did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                let theStatusCode = (response as? NSHTTPURLResponse)?.statusCode
                sendError("Your request to Parse returned a status code outside the 200 range: \(theStatusCode)")
                return
            }
            
            // GUARD: was there data returned?
            guard let data = data else {
                sendError("No data was returned by the Parse request!")
                return
            }
            
            // 5 Parse the data
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data returned by Parse getStudentLocation: \(data)")
            }
            
            // 6. use the data
            
            // GUARD: get the locations data from result
            guard let locationsArray = parsedResult[Constants.PARSE.results] as? [[String:AnyObject]] else {
                sendError("Could not parse location results")
                // TODO: display alert to user
                return
            }
  

            for myDictionary in locationsArray {
                
                let studentLocation = StudentLocation(dictionary: myDictionary)

                self.studentLocations.append(studentLocation)

                let lat = CLLocationDegrees(studentLocation.latitude)
                let long = CLLocationDegrees(studentLocation.longitude)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
                annotation.subtitle = studentLocation.mediaUrl
                
                // Finally we place the annotation in an array of annotations.
                self.annotations.append(annotation)


            }
    
    
            
            performUIUpdatesOnMain {
                self.completeGetLocationData()
            }
            
        }
        
        // 7. Start the request
        task.resume()
        
    }

    // MARK: USER ACTIONS
    
    @IBAction func userTappedRefresh(sender: AnyObject) {
        viewWillAppear(true)
    }
    
    @IBAction func userTappedAddLocation(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationView") as! LocationViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func userTappedLogout(sender: AnyObject) {
    }
    
    
    
    // MARK: UTILITIES FUNCTIONS
    
    func completeGetLocationData() {

        self.mapView.addAnnotations(annotations)
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
