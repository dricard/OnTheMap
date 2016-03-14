//
//  Locations.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-14.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit
import MapKit

class Locations: NSObject {

    var appDelegate: AppDelegate! = UIApplication.sharedApplication().delegate as! AppDelegate
    
    func getStudentLocations() {

        var studentLocations = [StudentLocation]()
        
        
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
                
                let uniqueKey = myDictionary[Constants.PARSE.uniqueKey] as! String
                let firstName = myDictionary[Constants.PARSE.firstName] as! String
                let lastName = myDictionary[Constants.PARSE.lastName] as! String
                let mapString = myDictionary[Constants.PARSE.mapString] as! String
                let mediaUrl = myDictionary[Constants.PARSE.mediaURL] as! String
                let latitude = myDictionary[Constants.PARSE.latitude] as! Float
                let longitude = myDictionary[Constants.PARSE.longitude] as! Float
                let createdAt = myDictionary[Constants.PARSE.createdAt] as! String
                let updatedAt = myDictionary[Constants.PARSE.updatedAt] as! String
                let imageUrl = ""
                
                let studentLocation = StudentLocation(uniqueKey: uniqueKey, firstName: firstName, lastName: lastName, mapString: mapString, mediaUrl: mediaUrl, latitude: latitude, longitude: longitude, createdAt: createdAt, updatedAt: updatedAt, imageUrl: imageUrl)
                
                studentLocations.append(studentLocation)
            }
            
            print(studentLocations)
            
//            self.appDelegate.userInformation = userData
//            
//            
//            // TODO: here segue into tab view controller passing user data collected so far
//            self.completeLogin()
            
        }
        
        // 7. Start the request
        task.resume()
        

    }
    
}
