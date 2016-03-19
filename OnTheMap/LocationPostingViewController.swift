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


    // MARK: VARIABLES

    var coordinates: CLLocationCoordinate2D?

    let labelURL = UILabel()
    let labelPlease = UILabel()
    var wide = false
    let topLabelWidth = CGFloat(150.0)
    let labelURLWidth = CGFloat(43.0)
    
    // MARK: Outlets
    
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        // add the text labels
        labelPlease.textAlignment = .Right
        labelPlease.font = UIFont.systemFontOfSize(18, weight: UIFontWeightThin)
        labelPlease.text = "Please enter an"
        self.view.addSubview(labelPlease)
        labelURL.textAlignment = .Center
        labelURL.font = UIFont.boldSystemFontOfSize(18)
        labelURL.text = "URL"
        self.view.addSubview(labelURL)
        
        print("Posting view loaded with coordinates: \(coordinates)")
        
//        configureActivityIndicatorView()

    }
    
    override func viewWillAppear(animated: Bool) {
        let screenSize: CGSize = view.frame.size
        evaluateIfWide(screenSize)
        setTextLabelsForUI(screenSize)
        let latitudeDelta = CLLocationDegrees(1.0)
        let longitudeDelta = CLLocationDegrees(1.0)
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        let region = MKCoordinateRegionMake(coordinates!, span)
        mapView.setRegion(region, animated: true)
    }

    // MARK: Actions from user
    
    @IBAction func userPressedSubmit(sender: AnyObject) {
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
    
    func evaluateIfWide(size: CGSize) {
        wide = size.width > topLabelWidth + labelURLWidth
    }
    
    func setTextLabelsForUI(size: CGSize) {
        
        // Setting the labels positions depending on screen width
        
        let screenHalfWidth = size.width / 2
        
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

}