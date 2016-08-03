//
//  API.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-18.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import FBSDKCoreKit
import FBSDKLoginKit

/// All networking code interfacing with APIs is contained in this class. Access through
/// `API.sharedInstance().methodName`.
/// ### Methods
/// **authenticateWithUdacity**:
/// to first login to Udacity, create a session, and get the user's
/// public information.
///
/// **getLocationsData**:
/// to get an array of students location informations.
///
/// ### Internal Methods
/// **getUserPublicData**:
/// called by `authenticateWithUdacity` to complete the login process and get the user's data.
class API: NSObject {

    /// This contains the NSURL shared session. All code requiring the shared session has been
    /// put into this class.
    var session = NSURLSession.sharedSession()

    override init() {
        super.init()
    }
    
    // MARK: - UDACITY API

    // First we create a session with Udacity API to authenticate the user and get a uniqueKey
    
    /// Uses REST API from Udacity to authenticate a valid user. It will then call `getUserPublicData`
    /// which will store the user's informations in *Model.swift*.
    /// - note: uses keys defined in struct *Constants.swift*. **Expects non-optional Strings** so
    /// unwrap before calling this method.
    /// - parameters:
    ///    - userEmail: the user's email address used to login to Udacity.
    ///    - userPassword: the user's password to login to Udacity.
    ///    - completionHandlerForAuth: this will be passed to `getUserPublicData`
    /// - returns:
    ///    - success is `true` and error `nil` if login was successful and no error was returned from the API
    ///    - success is `false` and an `NSError` if the login attempt failed
    func authenticateWithUdacity(userEmail: String, userPassword: String, completionHandlerForAuth: (success: Bool, error: NSError?) -> Void) {
        
        // 1. set up the parameters
        
        let bodyObject = [
            "udacity": [
                "username": userEmail,
                "password": userPassword
            ]
        ]
        
        // 2./3. Build URL and configure the request
        let url = NSURL(string: Constants.UDACITY.baseUrl)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(bodyObject, options: [])
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // Utility function
            func sendError(error: String, code: Int) {
                print("error: \(error), code: \(code)")
                // Build an informative NSError to return
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForAuth(success: false, error: NSError(domain: "authenticateWithUdacity", code: code, userInfo: userInfo))
            }
            
            // GUARD: was there an error?
            guard (error == nil) else {
                sendError("There was an error with the request to Udacity API: \(error)", code: Constants.UDACITY.networkError)
                return
            }
            
            // GUARD: did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                let theStatusCode = (response as? NSHTTPURLResponse)?.statusCode
                if theStatusCode == 403 {
                    sendError("Your request to Udacity returned a status code outside the 200 range: \(theStatusCode)", code: Constants.UDACITY.authenticationError)
                } else {
                    sendError("Your request to Udacity returned a status code outside the 200 range: \(theStatusCode)", code: Constants.UDACITY.networkError)
                }
                return
            }
            
            // GUARD: was there data returned?
            guard let data = data else {
                sendError("No data was returned by the request!", code: Constants.UDACITY.networkError)
                return
            }
            
            // Remove first character in response to get clean JSON data - specific to Udacity's API
            let usefulData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            // 5. Parse the data
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(usefulData, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data returned by Udacity create session: \(usefulData)", code: Constants.UDACITY.networkError)
            }
            
            // 6. Use the data
            
            // GUARD: is the user registered?
            guard let isRegistered = parsedResult[Constants.UDACITY.account]!![Constants.UDACITY.registered] as? Bool else {
                sendError("Account is unregistered", code: Constants.UDACITY.authenticationError)
                return
            }
            
            if isRegistered {
                if let uniqueKey = parsedResult[Constants.UDACITY.account]!![Constants.UDACITY.key] as? String {
                    self.getUserPublicData(uniqueKey, completionHandlerForAuth: completionHandlerForAuth)
                } else {
                    sendError("Could not parse unique key from user data", code: Constants.UDACITY.authenticationError)
                }
            }
            
        }
        
        // 7. Start the request
        task.resume()
    }

    /// Uses REST API from Udacity to authenticate a valid user with a **Facebook access token**
    /// instead of user's email and password. It will then call `getUserPublicData`
    /// which will store the user's informations in *Model.swift*.
    /// - note: uses keys defined in struct *Constants.swift*. **Expects non-optional Strings** so
    /// unwrap before calling this method.
    /// - parameters:
    ///    - userToken: a valid user token returned by FB after successful login.
    ///    - completionHandlerForAuthFB: this will be passed to `getUserPublicData`
    /// - returns:
    ///    - success is `true` and error `nil` if login was successful and no error was returned from the API
    ///    - success is `false` and an `NSError` if the login attempt failed
    func authenticateWithUdacityFB(userToken: String, completionHandlerForAuthFB: (success: Bool, error: NSError?) -> Void) {
        
        // 1. set up the parameters
        
        // Pass in the user token as dictionary
        let bodyObject = [
            "facebook_mobile": [
                "access_token": userToken
            ]
        ]
        
        // 2./3. Build URL and configure the request
        let url = NSURL(string: Constants.UDACITY.baseUrl)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(bodyObject, options: [])
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // Utility function
            func sendError(error: String, code: Int) {
                print("error: \(error), code: \(code)")
                // Build an informative NSError to return
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForAuthFB(success: false, error: NSError(domain: "authenticateWithUdacity", code: code, userInfo: userInfo))
            }
            
            // GUARD: was there an error?
            guard (error == nil) else {
                sendError("There was an error with the request to Udacity API: \(error)", code: Constants.UDACITY.networkError)
                return
            }
            
            // GUARD: did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                let theStatusCode = (response as? NSHTTPURLResponse)?.statusCode
                if theStatusCode == 403 {
                    sendError("Your request to Udacity returned a status code outside the 200 range: \(theStatusCode)", code: Constants.UDACITY.authenticationError)
                } else {
                    sendError("Your request to Udacity returned a status code outside the 200 range: \(theStatusCode)", code: Constants.UDACITY.networkError)
                }
                return
            }
            
            // GUARD: was there data returned?
            guard let data = data else {
                sendError("No data was returned by the request!", code: Constants.UDACITY.networkError)
                return
            }
            
            // Remove first character in response to get clean JSON data - specific to Udacity's API
            let usefulData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            // 5. Parse the data
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(usefulData, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data returned by Udacity create session: \(usefulData)", code: Constants.UDACITY.networkError)
            }
            
            // 6. Use the data
            
            // GUARD: is the user registered?
            guard let isRegistered = parsedResult[Constants.UDACITY.account]!![Constants.UDACITY.registered] as? Bool else {
                sendError("Account is unregistered", code: Constants.UDACITY.authenticationError)
                return
            }
            
            if isRegistered {
                if let uniqueKey = parsedResult[Constants.UDACITY.account]!![Constants.UDACITY.key] as? String {
                    self.getUserPublicData(uniqueKey, completionHandlerForAuth: completionHandlerForAuthFB)
                } else {
                    sendError("Could not parse unique key from user data", code: Constants.UDACITY.authenticationError)
                }
            }
            
        }
        
        // 7. Start the request
        task.resume()
    }

    /// Uses REST API from Udacity to get the user's public information (i.e., his or her name)
    /// and will store this in *Model.swift*.
    ///
    /// If successful the user data will be accessible from `Model.sharedInstance().userInformation`
    /// - note: uses keys defined in struct *Constants.swift*. **Do not call this directly**
    /// this method is called by `authenticateWithUdacity` or `authenticateWithUdacityFB`
    /// - parameters:
    ///    - uniqueKey: the user's unique Key returned from login to Udacity.
    ///    - completionHandlerForAuth: this is the completion handler passed from either `authenticateWithUdacity` 
    ///    or `authenticateWithUdacityFB`.
    internal func getUserPublicData(uniqueKey: String, completionHandlerForAuth: (success: Bool, error: NSError?) -> Void) {
        
        // 1. set the parameters
        // There are none
        
        // 2./3. Build URL and configure the request
        let baseUrl = NSURL(string: Constants.UDACITY.userDataUrl)
        let url = baseUrl?.URLByAppendingPathComponent(uniqueKey)
        let request = NSURLRequest(URL: url!)
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // Utility function
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForAuth(success: false, error: NSError(domain: "getUserPublicData", code: 1, userInfo: userInfo))
            }
            
            // GUARD: was there an error?
            guard (error == nil) else {
                sendError("There was an error with the request to Udacity API: \(error)")
                return
            }
            
            // GUARD: did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                let theStatusCode = (response as? NSHTTPURLResponse)?.statusCode
                sendError("Your request to Udacity returned a status code outside the 200 range: \(theStatusCode)")
                return
            }
            
            // GUARD: was there data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Remove first character in response to get clean JSON data
            let usefulData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            // 5. Parse the data
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(usefulData, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data returned by Udacity getUserPublicData: \(usefulData)")
            }
            
            // 6. use the data
            
            // GUARD: get the user last name
            guard let lastName = parsedResult[Constants.UDACITY.user]!![Constants.UDACITY.lastName] as? String else {
                sendError("Could not parse user last name")
                return
            }
            
            // GUARD: get the user first name
            guard let firstName = parsedResult[Constants.UDACITY.user]!![Constants.UDACITY.firstName] as? String else {
                sendError("Could not parse user first name")
                return
            }
            
            // GUARD: get the user image URL
            guard let userImage = parsedResult[Constants.UDACITY.user]!![Constants.UDACITY.imageUrl] as? String else {
                sendError("Could not parse user image URL")
                return
            }
            
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let stringDate: String = formatter.stringFromDate(NSDate())
            
            // Here we store the userInformation in our model
            // Create a dictionary with the data
            let userInfo: [String:AnyObject] = [
                Constants.PARSE.uniqueKey: uniqueKey,
                Constants.PARSE.firstName: firstName,
                Constants.PARSE.lastName: lastName,
                Constants.PARSE.mapString: "",
                Constants.PARSE.mediaURL: "",
                Constants.PARSE.latitude: 0.0,
                Constants.PARSE.longitude: 0.0,
                Constants.PARSE.createdAt: stringDate,
                Constants.PARSE.updatedAt: stringDate,
                Constants.PARSE.objectId: "",
                "imageUrl": userImage
            ]
            
            let userData = StudentLocation(dictionary: userInfo)
            
            Model.sharedInstance().userInformation = userData
            
            completionHandlerForAuth(success: true, error: nil)

            
        }
        
        // 7. Start the request
        task.resume()
        
    }

    /// Uses REST API from Udacity to logout.
    /// - note: uses keys defined in struct *Constants.swift*. **Expects non-optional Strings** so
    /// unwrap before calling this method.
    /// - parameters:
    ///    - completionHandlerForLogout: this will called with either success or failure
    /// - returns:
    ///    - success is `true` and error `nil` if login was successful and no error was returned from the API
    ///    - success is `false` and an `NSError` if the logout attempt failed
    func logoutFromUdacity(completionHandlerForLogout: (success: Bool, error: NSError?) -> Void) {
        
        // 1. set up the parameters
        // there are none
        
        // 2./3. Build URL and configure the request
        let url = NSURL(string: Constants.UDACITY.baseUrl)
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "DELETE"

        // 4. Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // Utility function
            func sendError(error: String) {
                print(error)
                // Build an informative NSError to return
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForLogout(success: false, error: NSError(domain: "logoutFromUdacity", code: 1, userInfo: userInfo))
            }
            
            // GUARD: was there an error?
            guard (error == nil) else {
                sendError("There was an error with the logout request to Udacity API: \(error)")
                return
            }
            
            // GUARD: did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                let theStatusCode = (response as? NSHTTPURLResponse)?.statusCode
                sendError("Your request to Udacity returned a status code outside the 200 range: \(theStatusCode)")
                return
            }
            
            // GUARD: was there data returned?
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            // Remove first character in response to get clean JSON data - specific to Udacity's API
            let usefulData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            
            // 5. Parse the data
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(usefulData, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data returned by Udacity logout of session: \(usefulData)")
            }
            
            // 6. Use the data
            
            // GUARD: do we have a session dictionary?
            guard let sessionDictionary = parsedResult[Constants.UDACITY.session]!! as? [String:AnyObject] else {
                sendError("Error loging out: no session dictionary")
                return
            }
            
            if sessionDictionary[Constants.UDACITY.id] != nil {
                    completionHandlerForLogout(success: true, error: nil)
                } else {
                    sendError("Could not parse session ID from logout response")
                }
            
        }
        
        // 7. Start the request
        task.resume()
    
    }

    // MARK: PARSE API
    
    /// Uses the REST API from Parse using Udacity's API Key to get students' location data
    /// and build an array of annotations to display on the map.
    ///
    /// If successful the users data will be accessible from `Model.sharedInstance().studentLocations`
    /// - note: uses keys defined in struct *Constants.swift*.
    /// - parameters:
    ///    - completionHandlerForGetLocations: this is the completion handler called on completion.
    /// - returns:
    ///    - studentLocations: an array of StudentLocations
    ///    - annotations: an array of MKPointAnnotations
    ///    - error: a NSError which is `nil` if the method was successful
    func getLocationsData(completionHandlerForGetLocations: (studentLocations: [StudentLocation]?, annotations: [MKPointAnnotation]?, error: NSError?) -> Void) {
  
        // Get the student location informations from Parse API
        
        // 1. set the parameters
        // Set the sort order to get the most recently updated locations
        var methodParameters = [String:AnyObject]()
        methodParameters[Constants.PARSE.order] = "-" + Constants.PARSE.updatedAt
        
        // 2./3. Build URL and configure the request
        let urlString = Constants.PARSE.baseUrl + escapedParameters(methodParameters)
        
        guard var url = NSURL(string: urlString) else {
            print("could not unwrap NSURL in getStudentLocation")
            return
        }
        
        let request = NSMutableURLRequest(URL: url)
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // Utility function
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGetLocations(studentLocations: nil, annotations: nil, error: NSError(domain: "getLocationsData", code: 1, userInfo: userInfo))
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
            
            // 5. Parse the data
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
                return
            }
            
            var studentLocations = [StudentLocation]()
            var annotations = [MKPointAnnotation]()
            
            for myDictionary in locationsArray {
                
                let studentLocation = StudentLocation(dictionary: myDictionary)
                
                studentLocations.append(studentLocation)
                
                let lat = CLLocationDegrees(studentLocation.latitude)
                let long = CLLocationDegrees(studentLocation.longitude)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = "\(studentLocation.firstName) \(studentLocation.lastName)"
                if studentLocation.mediaUrlIsValid {
                    annotation.subtitle = studentLocation.mediaUrl
                } else {
                    annotation.subtitle = "?:" + studentLocation.mediaUrl
                }
                
                // Finally we place the annotation in an array of annotations.
                annotations.append(annotation)
                
            }
            
            completionHandlerForGetLocations(studentLocations: studentLocations, annotations: annotations, error: nil)
            
        }
        
        // 7. Start the request
        task.resume()

    }
    
    /// This post a student location to the Parse API with the user provided data and 
    /// the data collected from the authentication from Udacity.
    ///
    /// Takes a non-optional student location, so unwrap before passing the parameter.
    /// Normally this would be unwrapping the `Model.sharedLocation().userInformation`
    /// variable which is a StudentLocation?
    ///
    /// If `isNewPosting` is true then this the first time the user posts a location, otherwise we update
    /// the data with the new information.
    func postStudentLocation(isNewPosting: Bool, studentLocation: StudentLocation, completionHandlerForPostLocation: (objectId: String?, createdAt: String?, error: NSError?) -> Void) {
        
        // 1. set the parameters
        // there a re none
        
        // 2./3. Build URL and configure the request
        var url = NSURL(string: Constants.PARSE.baseUrl)

        if !isNewPosting {
            url = url!.URLByAppendingPathComponent(studentLocation.objectId)
        }

        let request = NSMutableURLRequest(URL: url!)
        if isNewPosting {
            request.HTTPMethod = "POST"
        } else {
            request.HTTPMethod = "PUT"
        }
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // JSON Body
        
        let bodyObject = [
            "uniqueKey": studentLocation.uniqueKey,
            "firstName": studentLocation.firstName,
            "lastName": studentLocation.lastName,
            "mediaURL": studentLocation.mediaUrl,
            "longitude": studentLocation.longitude,
            "latitude": studentLocation.latitude,
            "mapString": studentLocation.mapString
        ]
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(bodyObject, options: [])

        // 4. Make the request
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            // Utility function
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPostLocation(objectId: nil, createdAt: nil, error: NSError(domain: "postStudentLocation", code: 1, userInfo: userInfo))
            }
            
            // GUARD: was there an error?
            guard (error == nil) else {
                sendError("An error was returned from the Parse API: \(error)")
                return
            }
            
            // GUARD: did we get a successful 2XX response?
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                let theStatusCode = (response as? NSHTTPURLResponse)?.statusCode
                sendError("Your request to Parse returned a status code outside the 2XX range: \(theStatusCode)")
                return
            }
            
            // GUARD: was there data returned?
            guard let data = data else {
                sendError("No data was returned from the Parse API request!")
                return
            }
            
            // 5. parse the result
            var parsedResult: AnyObject!
            do {
                parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
            } catch {
                sendError("Could not parse the data returned by Parse in postStudentLocation: \(data)")
            }
            
            // 6. Use the data
 
            var key = ""
            if isNewPosting {
                key = Constants.PARSE.createdAt
            } else {
                key = Constants.PARSE.updatedAt
            }
            
            // although it is named 'createdAt', it actually contains either that or updatedAt depending
            // on isNewPosting.
            guard let createdAt = parsedResult[key] as? String else {
                sendError("Could not parse (createdAt or updatedAt) from data returned from Parse: \(parsedResult)")
                return
            }

            if isNewPosting {
                // If this is a new posting the API returns the object's id. Otherwise we
                // already have it.
                guard let objectId = parsedResult[Constants.PARSE.objectId] as? String else {
                    sendError("Could not parse objectId from data returned from Parse: \(parsedResult)")
                    return
                }
                // now we have everything
                completionHandlerForPostLocation(objectId: objectId, createdAt: createdAt, error: nil)
                
            } else {
                completionHandlerForPostLocation(objectId: studentLocation.objectId, createdAt: createdAt, error: nil)
            }
            
        }
        
        // 7. Start the request
        task.resume()
        
    }
    
    private func escapedParameters(parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                // make sure that it is a string value
                let stringValue = "\(value)"
                
                // escape it
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                // append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            
            return "?\(keyValuePairs.joinWithSeparator("&"))"
        }
    }

    // MARK: Facebook Login
    
    
    
    // MARK: Shared Instance
    
    /// This is a Singleton used to hold all the networking code
    class func sharedInstance() -> API {
        struct Singleton {
            static var sharedInstance = API()
        }
        return Singleton.sharedInstance
    }

}
