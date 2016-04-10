//
//  Constants.swift
//  OnTheMap
//
//  Created by Denis Ricard on 2016-03-11.
//  Copyright © 2016 Denis Ricard. All rights reserved.
//

import UIKit

/// Holds all the URLs and keys of the Udacity and Parse APIs. This way if
/// the APIs change in the futur only this files needs to be updated.
///
/// Use `Constants.UDACITY.parameter` to access Udacity's API parameters and
/// `Constants.PARSE.parameter` to access Parse API parameters.
struct Constants {
    
    // UDACITY
    
    struct UDACITY {
        
        // opening a session
        static let baseUrl = "https://www.udacity.com/api/session"
        
        // session response
        static let account = "account"
        static let registered = "registered"
        static let key = "key"
        
        static let session = "session"
        static let expiration = "expiration"
        static let id = "id"
        
        // getting user public data
        static let userDataUrl = "https://www.udacity.com/api/users/"
        // user data response
        static let user = "user"
        static let lastName = "last_name"
        static let firstName = "first_name"
        static let imageUrl = "_image_url"
        
        // Error codes
        static let networkError = 1
        static let authenticationError = 2
        
    }
    
    struct PARSE {
        
        // getting student locations
        static let baseUrl = "https://api.parse.com/1/classes/StudentLocation"
        // Parameters
        static let order = "order"
        // location data response
        static let results = "results"
        
        static let createdAt = "createdAt"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let updatedAt = "updatedAt"
    }
    
    struct COLOR {
        static let udacity = UIColor(red:0.012,  green:0.706,  blue:0.898, alpha:1)
        static let apple = UIColor(red:0.715,  green:0.744,  blue:0.939, alpha:1)
        static let google = UIColor(red:0.988,  green:0.741,  blue:0.016, alpha:1)
        static let twitter = UIColor(red:0.608,  green:0.935,  blue:0.446, alpha:1)
        static let hexaedre = UIColor(red:0.857,  green:0.168,  blue:0, alpha:1)
    }
}