//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-11.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit

/// Holds the information about a single student location. Takes a dictionary for initialization
/// build with keys defined in *Constants.swift*: `Constants.PARSE.keyName`.
/// - parameters:
///   - uniqueKey: String that is returned by the Udacity API upon successful login
///   - firstName: String that contains the student's first name
///   - lastName: String that contains the student's last name
///   - mapString: the location string that the student used to describe his/her location
///   - mediaUrl: String that contains the URL that the student shared
///   - latitude: Double that contains the latitude returned by forward geocoding the
///   `mapString` submitted by the student
///   - longitude: Double that contains the longitude returned by forward geocoding the
///   `mapString` submitted by the student
///   - createdAt: String - used by Parse when creating (posting) a new location.
///   - updatedAt: String - used by Parse when updating (posting) a new location.
///   - imageUrl: String - used to hold the user's image URL for futur development.
struct StudentLocation {
    
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaUrl: String
    var latitude: Double
    var longitude: Double
    var createdAt: String
    var updatedAt: String
    var imageUrl: String


    init(dictionary: [String:AnyObject]) {
         uniqueKey = dictionary[Constants.PARSE.uniqueKey] as! String
         firstName = dictionary[Constants.PARSE.firstName] as! String
         lastName = dictionary[Constants.PARSE.lastName] as! String
         mapString = dictionary[Constants.PARSE.mapString] as! String
         mediaUrl = dictionary[Constants.PARSE.mediaURL] as! String
         latitude = dictionary[Constants.PARSE.latitude] as! Double
         longitude = dictionary[Constants.PARSE.longitude] as! Double
         createdAt = dictionary[Constants.PARSE.createdAt] as! String
         updatedAt = dictionary[Constants.PARSE.updatedAt] as! String
         imageUrl = ""

    }
}