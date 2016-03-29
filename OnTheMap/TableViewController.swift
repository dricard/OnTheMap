//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-25.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: Properties
    
    var studentLocations = [StudentLocation]()
    
    // MARK: Outlets
    
    @IBOutlet var locationTableView: UITableView!
    
    // Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTableView.delegate = self
        locationTableView.dataSource = self
        
        // setting the Navigation bar
        // setting the title
        title = "On the map"
       
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refreshData()

    }
    
    // MARK: Data function(s)
    
    func refreshData() {
        
        API.sharedInstance().getLocationsData { (studentLocations, annotations, error) -> Void in
            
            guard (error == nil) else {
                print("Error returned by getLocationData in MapViewController: \(error)")
                // TODO: alert user
                return
            }
            
            if let studentLocations = studentLocations {
                self.studentLocations = studentLocations
                performUIUpdatesOnMain({ 
                    self.locationTableView.reloadData()
                })
            } else {
                print("Error getting student locations in TableViewController")
            }
        }
        
    }

    // MARK: User actions
    
    @IBAction func userTappedRefresh(sender: AnyObject) {
        
        refreshData()
        
    }
    
    @IBAction func userTappedAddLocation(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationView") as! LocationViewController
        controller.callingViewControllerIsMap = false
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func userTappedLogout(sender: AnyObject) {
    }
    
    @IBAction func unwindToTable(unwindSegue: UIStoryboardSegue) {
        if let postingViewController = unwindSegue.sourceViewController as? LocationPostingViewController {

            if Model.sharedInstance().userInformation?.objectId != "" {
                
                // first, fetch new data from Parse API
                refreshData()                
            }
            
        }
        else if let locationViewController = unwindSegue.sourceViewController as? LocationViewController {
            print("Coming from location")
        }
    }

    // MARK: utilities
    
    func logout() {
        print("loging out")
    }
    
    func enterLocation() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LocationView") as! LocationViewController
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // MARK: TableView Delegates
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get cell type
        let cellReuseIdentifier = "LocationTableViewCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath)
        
        let location = studentLocations[indexPath.row]

        // Set-up the cell
        cell.textLabel!.text = location.firstName + " " + location.lastName
        // If the cell has a detail label, we will put the mediaURL in.
        if let detailTextLabel = cell.detailTextLabel {
            detailTextLabel.text = "URL: \(location.mediaUrl)"
        }

        cell.imageView!.image = UIImage(named: "GenericLocation")
        cell.imageView!.contentMode = UIViewContentMode.ScaleAspectFit
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return studentLocations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let location = studentLocations[indexPath.row]

        UIApplication.sharedApplication().openURL(NSURL(string: location.mediaUrl)!)
        
    }
}
