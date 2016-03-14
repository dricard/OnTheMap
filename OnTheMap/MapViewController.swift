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

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        print("ULN: \(appDelegate.userInformation!.lastName)")
        print("UFN: \(appDelegate.userInformation!.firstName)")
        print("UIU: \(appDelegate.userInformation!.imageUrl)")
        
        var studentLocations = Locations()
        studentLocations.getStudentLocations()
        
        
    }
}
