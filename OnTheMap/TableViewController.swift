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
    
    // MARK: Life Cycle
    
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
                self.presentAlertMessage("Communication error", message: "Unable to connect to server, please check your internet connection")
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