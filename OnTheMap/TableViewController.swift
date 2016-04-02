//
//  TableViewController.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-25.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

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

        if Model.sharedInstance().loggedInWithFacebook {
            let fbManager = FBSDKLoginManager()
            fbManager.logOut()
            Model.sharedInstance().loggedInWithFacebook = false
            Model.sharedInstance().fbToken = nil
            Model.sharedInstance().fbUserId = nil
            performUIUpdatesOnMain({
                if let tabBarController = self.tabBarController {
                    tabBarController.dismissViewControllerAnimated(true, completion: nil)
                }})
            
        } else {

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

    /// Display a two-button alert message to communicate choices to the user. Display a title, a message, and
    /// an 'OK' button.
    func presentAlertMessageWithOption(title: String, message: String, url: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: { action in  })
        controller.addAction(cancelAction)
        let goAheadAction = UIAlertAction(title: "Try URL", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.showUrl(url)
        })
        controller.addAction(goAheadAction)
        self.presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func showUrl(url: String) {
        UIApplication.sharedApplication().openURL(NSURL(string: url)!)
    }
    
    func colorFromURL(url: NSURL) -> UIColor {
        guard let urlString = url.host else {
            print("could not unwrap baseURL in colorFromURL: \(url)")
            return UIColor.whiteColor()
        }

        switch urlString {
        case "www.udacity.com", "udacity.com":
            return Constants.COLOR.udacity
        case "www.apple.com", "apple.com":
           return Constants.COLOR.apple
        case "www.google.com", "google.com", "www.google.ca", "google.ca":
            return Constants.COLOR.google
        case "www.twitter.com", "twitter.com":
            return Constants.COLOR.twitter
        case "www.hexaedre.com", "hexaedre.com":
            return Constants.COLOR.hexaedre
        default:
            return UIColor.whiteColor()
        }
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
            if location.mediaUrlIsValid {
                detailTextLabel.text = "URL: \(location.mediaUrl)"
                cell.backgroundColor = colorFromURL(location.mediaNSURL)
            } else {
                detailTextLabel.text = "URL: invalid URL (\(location.mediaUrl))"
                cell.backgroundColor = UIColor.lightGrayColor()
            }
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

        if location.mediaUrlIsValid {
            showUrl(location.mediaUrl)
        } else {
            // url is not valid, offer a choice to user
            presentAlertMessageWithOption("Invalid URL", message: "The URL \"\(location.mediaUrl)\" appears to be invalid, are you sure you want to open it?", url: location.mediaUrl)
        }
        
    }
}
